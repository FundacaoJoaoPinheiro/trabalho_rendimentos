# comparar valores estimados para MG na sessão do R com aqueles disponíveis 
# nas tabelas da plataforma SIDRA

# Preparar ambiente
options(scipen = 999, digits = 2)
pacotes <- c("sidrar", "PNADcIBGE", "survey")
install.packages(setdiff(pacotes, rownames(installed.packages())))
lapply(pacotes, library, character.only = TRUE)
source("utilitarios.R")     # objetos e funções utilizados abaixo

#variaveis <- c(
#	"V5001A2", "V5002A2", "V5003A2",                          # outras fontes
#	"V5004A2", "V5005A2", "V5006A2", "V5007A2", "V5008A2",    # outros rendimentos
#	"VD4019", "VD4020", "VD4048", "VD4052",                   # habitual/efetivo
#	"V2001", "V2005"                                          # domicílio
#)

# ler microdados e gerar desenho amostral
pnadc_ano = 2023
visita = 1
pnadc_dir = "Microdados"

if (file.exists("desenho_fontes.RDS")) {
	desenho <- readRDS("desenho_fontes.RDS")
} else {
	desenho <- gerar_desenho(tabelas_fontes)
}

# 7426 - População residente com rendimento, por fonte de rendimento

# consultar informações sobre a tabela
info_sidra(7426)

# importar tabela SIDRA para as PA, BA, MG e GO
sidra_7426 <- get_sidra(x = 7426, variable = 10486, period = "2023", geo = "State",
	geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2)
names(sidra_7426)

# criar coluna com Outros rendimentos (os que ficaram faltando)
desenho$variables <- transform(
	desenho$variables,
	Outros.Rendimentos = rowSums(
		cbind(V5001A2, V5002A2, V5003A2, V5005A2, V5008A2),
		na.rm = TRUE
	)
)
desenho$variables <- transform(
	desenho$variables,
	Outros.Rendimentos = ifelse(Outros.Rendimentos == 0, NA, Outros.Rendimentos)
)

# estimar totais de população com rendimento por fonte de rendimento
pop_fontes <- estimar_totais(
	desenho,
	formula = ~
		(!is.na(VD4052))  +     # todas as fontes
		(!is.na(VD4019))  +     # trabalho - habitual
		(!is.na(VD4020))  +     # trabalho - efetiva
		(!is.na(VD4048))  +     # outras fontes
	 	(!is.na(V5004A2)) +     # aposentadoria e pensão
		(!is.na(V5007A2)) +     # aluguel e arrendamento
		(!is.na(V5006A2)) +     # pensão alimentícia, doação e mesada
		(!is.na(Outros.Rendimentos))
)

# descartar colunas em que os testes is.na() foram FALSE
pop_fontes <- pop_fontes[-c(1:16 * 2)]

# melhorar os nomes das colunas
colnames(pop_fontes) <- c(
	"UF",
	"Todas.as.Fontes",
	"Trabalho.Habitualmente",
	"Trabalho.Efetiva",
	"Outras.Fontes",
	"Aposentadoria/Pensao",
	"Aluguel/Arrendamento",
	"Pensao.alimenticia",
	"Outros.Rendimentos",
	"cv.Todas.as.Fontes",
	"cv.Trabalho.Habitualmente",
	"cv.Trabalho.Efetiva",
	"cv.Outras.Fontes",
	"cv.Aposentadoria/Pensao",
	"cv.Aluguel/Arrendamento",
	"cv.Pensao.alimenticia",
	"cv.Outros.Rendimentos"
)

# comparar estimativas com a tabela do SIDRA
View(sidra_7426[c(7, 4, 3)])
View(pop_fontes)

# dividir a tabela em duas
tab_7426 <- pop_fontes[1:9]
cv_7426  <- pop_fontes[-1 * 2:9]

# salvar tabelas no formato csv
write.csv(tab_7426, "tabelas/tab_7426.csv")
write.csv(cv_7426,  "tabelas/cv_7426.csv")

# 7429 - participação % de cada fonte no rendimento médio domiciliar per capita

# consultar informações sobre a tabela
info_sidra(7429)

# importar tabela do SIDRA
sidra_7429 <- get_sidra(x = 7429, variable = 10497, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2)
names(sidra_7429)

# Calcular as rendas domiciliares per capita

desenho$variables <- add_rdpc(
	desenho$variables,
	c("VD4019", "VD4048", "V5004A2", "Outros.Rendimentos")
)

# estimar as participações na renda domiciliar por tipo de rendimento
participacao_rdpc <- svyby(
	~VD5008 + VD4019.DPC + VD4048.DPC + V5004A2.DPC + Outros.Rendimentos.DPC,
	by = ~UF,
	denominator = ~VD5008,
	design = subset(desenho, V2005.Rendimento == 1),
	FUN = svyratio,
	vartype = "cv",
	keep.names = FALSE,
	drop.empty.groups = FALSE,
	na.rm = TRUE
)

# multiplicar as colunas numéricas por cem
participacao_rdpc[-1] <- participacao_rdpc[-1] * 100

# melhorar os nomes das colunas
colnames(participacao_rdpc) <- c(
	"UF",
	"Todas.as.Fontes",
	"Trabalho.Habitualmente",
	"Aposentadoria/Pensao",
	"Outros.Rendimentos",
	"cv.Todas.as.Fontes",
	"cv.Trabalho.Habitualmente",
	"cv.Outras.Fontes",
	"cv.Aposentadoria/Pensao",
	"cv.Outros.Rendimentos"
)

# comparar estimativas com a tabela do SIDRA
View(sidra_7429[c(7, 4, 3)])
View(participacao_rdpc)

# dividir tabela
tab_7429 <- participacao_rdpc[c(1, 2:6)]
cv_7429  <- participacao_rdpc[c(1, 7:11)]

# salvar tabelas no formato csv
write.csv(tab_7429, "tabelas/tab_7429.csv")
write.csv(cv_7429, "tabelas/cv_7429.csv")

# 7437 ----------------------------------------------
sidra_7437 <- get_sidra(x = 7437, variable = 10750, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2)
names(sidra_7437)

# adicionar variáveis deflacionadas
vars_fontes = c("VD4052", "VD4019", "VD4020", "VD4048", "V5004A2",
	"V5007A2", "V5006A2", "Outros.Rendimentos")

desenho$variables <- deflacionar(
	desenho$variables,
	vars = vars_fontes[-1],    # VD4052 = VD4019 (habitual) + VD4020 (efetivo)
	ano.base = 1
)
desenho$variables <- transform(
	desenho$variables,
	VD4052.Real = rowSums(
		cbind(VD4019.Real, VD4048.Real),
		na.rm = TRUE
	)
)
# inserir NA's nas linhas corretas
desenho$variables <- transform(
	desenho$variables,
	VD4052.Real = ifelse(is.na(VD4019) & is.na(VD4048), NA, VD4052.Real)
)

# criar lista com as estimativas dos rendimentos médios da população com
# rendimento, por fonte de rendimento
rme_fontes <- lapply(
	vars_fontes,
	function(var) {
		estimar_medias(
			subset(desenho, get(var) > 0),
			as.formula(paste0("~", var, ".Real"))
		)
	}
)
# juntar os dataframes da lista por UF
rme_fontes <- Reduce(function(...) merge(..., sort = FALSE), rme_fontes)
# médias e cv's estão intercalados, reordenar
rme_fontes <- rme_fontes[c(1, 1:8 * 2, seq(3, 17, by = 2))]

# melhorar os nomes das colunas
colnames(rme_fontes) <- c(
	"UF",
	"Todas.as.Fontes",
	"Trabalho.Habitualmente",
	"Trabalho.Efetivamente",
	"Outras.Fontes",
	"Aposentadoria/Pensao",
	"Aluguel.arrendamento",
	"Pensao.alimenticia",
	"Outros.Rendimentos",
	"cv.Todas.as.Fontes",
	"cv.Trabalho.Habitualmente",
	"cv.Trabalho.Efetivamente",
	"cv.Outras.Fontes",
	"cv.Aposentadoria/Pensao",
	"cv.Aluguel.arrendamento",
	"cv.Pensao.alimenticia",
	"cv.Outros.Rendimentos"
)

# comparar estimativas com a tabela do SIDRA
View(sidra_7437[c(7, 4, 3)])
View(rme_fontes[1:9])

# dividir a tabela em duas
tab_7437 <- rme_fontes[c(1, 2:9)]
cv_7427  <- rme_fontes[c(1, 10:17)]

# salvar tabelas no formato csv
write.csv(tab_7437, "tabelas/tab_7437.csv")
write.csv(cv_7437, "tabelas/cv_7437.csv")
