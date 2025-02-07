# Reproduzir tabelas SIDRA para os dez estratos geográficos de Minas Gerais.
# Tabelas referentes à fontes de rendimento: 7426, 7429, 7437.
# ---------------------------------------------------------------------

# Preparar ambiente
pacotes <- c("PNADcIBGE", "survey")
install.packages(setdiff(pacotes, rownames(installed.packages())))
lapply(pacotes, library, character.only = TRUE)
source("utilitarios.R")     # objetos e funções utilizados abaixo

pnadc_ano = 2023
pnadc_dir = "Microdados"
desenho <- gerar_desenho(tabelas_fontes)

# ---------------------------------------------------------------------

# Criar colunas necessárias

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

# renda domiciliar per capita (RDPC)
desenho$variables <- add_rdpc(
	desenho$variables,
	c("VD4019", "VD4048", "V5004A2", "Outros.Rendimentos")
)

vars_def = c("VD4052", "VD4019", "VD4020", "VD4048", "V5004A2",
	"V5007A2", "V5006A2", "Outros.Rendimentos")

desenho$variables <- deflacionar(
	desenho$variables,
	vars = vars_def[-1],    # VD4052 = VD4019 (habitual) + VD4020 (efetivo)
	ano.base = 1
)
desenho$variables <- transform(
	desenho$variables,
	VD4052.Real = rowSums(
		cbind(VD4019.Real, VD4048.Real),
		na.rm = TRUE
	)
)
desenho$variables <- transform(
	desenho$variables,
	VD4052.Real = ifelse(is.na(VD4019) & is.na(VD4048), NA, VD4052.Real)
)

# ---------------------------------------------------------------------

# 7426 - População residente com rendimento, por fonte de rendimento

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

pop_fontes <- pop_fontes[-c(1:16 * 2)]
colnames(pop_fontes) <- c(
	"Estrato.Geo",
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

tab_7426 <- pop_fontes[1:9]
cv_7426  <- pop_fontes[-1 * 2:9]

write.csv(tab_7426, "tabelas/tab_7426.csv")
write.csv(cv_7426,  "tabelas/cv_7426.csv")

# 7429 - participação % de cada fonte no rendimento médio domiciliar per capita

participacao_rdpc <- svyby(
	~VD5008 + VD4019.DPC + VD4048.DPC + V5004A2.DPC + Outros.Rendimentos.DPC,
	by = ~Estrato.Geo,
	denominator = ~VD5008,    # rendimento total dom. per capita
	design = subset(desenho, V2005.Rendimento == 1),    # incluídos na renda dom.
	FUN = svyratio,
	vartype = "cv",
	keep.names = FALSE,
	drop.empty.groups = FALSE,
	na.rm = TRUE
)

participacao_rdpc[-1] <- participacao_rdpc[-1] * 100    # [1] não é numérica
colnames(participacao_rdpc) <- c(
	"Estrato.Geo",
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

tab_7429 <- participacao_rdpc[c(1, 2:6)]
cv_7429  <- participacao_rdpc[c(1, 7:11)]

write.csv(tab_7429, "tabelas/tab_7429.csv")
write.csv(cv_7429, "tabelas/cv_7429.csv")

# 7437 - RMe da pop. com rendimento, por fonte de rendimento

rme_fontes <- lapply(
	vars_def,
	function(var) {
		estimar_medias(
			subset(desenho, get(var) > 0),        # apenas pop. com rendimento
			as.formula(paste0("~", var, ".Real"))
		)
	}
)

# juntar dataframes da lista em um único
rme_fontes <- Reduce(function(...) merge(..., sort = FALSE), rme_fontes)
# médias e cv's estão intercalados; reordenar
rme_fontes <- rme_fontes[c(1, 1:8 * 2, seq(3, 17, by = 2))]
colnames(rme_fontes) <- c(
	"Estrato.Geo",
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

tab_7437 <- rme_fontes[c(1, 2:9)]
cv_7437  <- rme_fontes[c(1, 10:17)]

write.csv(tab_7437, "tabelas/tab_7437.csv")
write.csv(cv_7437, "tabelas/cv_7437.csv")
