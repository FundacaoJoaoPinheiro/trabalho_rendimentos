# comparar valores estimados para MG na sessão do R com aqueles disponíveis 
# nas tabelas da plataforma SIDRA

pacotes <- c("sidrar", "PNADcIBGE", "survey")
lapply(pacotes, library, character.only = TRUE)
source("testes/utilitarios.R")

options(scipen = 999)

variaveis <- c(
	"V5001A2", "V5002A2", "V5003A2",                          # outras fontes
	"V5004A2", "V5005A2", "V5006A2", "V5007A2", "V5008A2",    # outros rendimentos
	"VD4019", "VD4020", "VD4048", "VD4052",                   # habitual/efetivo
	"V2001", "V2005"                                          # domicílio
)

pnadc_ano = 2023
visita = 1
pnadc_dir = "Microdados"

if (file.exists("desenho_tipo_rend.RDS")) {
	desenho <- readRDS("desenho_tipo_rend.RDS")
} else {
	desenho <- gerar_DA(variaveis)
}
	

# 7426 ------------------------------------------------

sidra_7426 <- get_sidra(x = 7426, variable = 10486, period = "2023", geo = "State",
	geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2)
sidra_7426 <- transform(sidra_7426, Valor = Valor * 1000)

estimar_total <- function(var, desenho) {
	svyby(
		formula = as.formula(var),
		by = ~UF,
		design = desenho,
		FUN = svytotal,
		vartype = "cv",
		keep.names = FALSE,
		na.rm = TRUE
	)
}

# Rendimentos Habitual e Efetivo (V, ?)

rend_trabalho <- svyby(
	~(!is.na(VD4019)) + (!is.na(VD4020)),
	~UF,
	desenho,
	svytotal,
	vartype = "cv",
	keep.names = FALSE,
	na.rm = TRUE
)

View(rend_trabalho[c(1, 3, 7, 5, 9)])
View(sidra_7426[c(7, 4, 3)])

# Aposentadoria..., aluguel..., pensão... (V,V,V)

pop_rendimentos <- estimar_total(~
 	(is.na(V5004A2) +   # aposentadoria
	is.na(V5007A2) +    # aluguel
	is.na(V5006A2)),    # pensão
	desenho
)

View(sidra_7426[c(7, 4, 3)])
View(pop_rendimentos)

# Outros rendimentos (V)
desenho$variables <- transform(
	desenho$variables,
	Outros.Rendimentos = factor(
		ifelse(
			!is.na(V5001A2) | !is.na(V5002A2) | !is.na(V5003A2) |
			!is.na(V5005A2) | !is.na(V5008A2),
			1, NA
		)
	)
)

estimar_total(~Outros.Rendimentos, desenho)
sidra_7426[c(7, 4, 3)]

# Todas as fontes e Outras fontes (V,V)
outras_fontes <- svyby(
	~is.na(VD4052) + is.na(VD4048),
	~UF,
	desenho,
	FUN = svytotal,
	vartype = "cv",
	keep.names = FALSE,
	na.rm = TRUE
)

View(sidra_7426[c(7, 4, 3)])
View(outras_fontes)[c(1, 2, 4)])

# 7429 --------------------------------------
sidra_7429 <- get_sidra(x = 7429, variable = 10497, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2)

# as 3 categorias abaixos são excluídas no cálculo da rendimento domiciliar
desenho$variables <- transform(
	desenho$variables,
	V2005.Incluidas = ifelse(
		V2005 == "Pensionista" |
		V2005 == "Empregado(a) doméstico(a)" |
		V2005 == "Parente do(a) empregado(a) doméstico(a)",
		NA, 1
	)
)

# moradores por domicílio incluídos no cálculo do rendimento domiciliar
desenho$variables <- transform(
	desenho$variables,
	V2001.Incluidos = ave(
		V2005.Incluidas,
		ID_DOMICILIO,
		FUN = sum
	)
)

# Deflacionar variáveis de rendimento
# (obs: para o ano mais recente, CO1 = CO2 e CO1e = CO2e)
desenho$variables <- transform(
	desenho$variables,
	VD4019.Real = ifelse(is.na(VD4019), NA, VD4019 * CO1),  
	VD4048.Real = ifelse(is.na(VD4048), NA, VD4048 * CO1e),
 	V5004A2.Real = ifelse(is.na(V5004A2), NA, V5004A2 * CO1e),
	Outros.Rendimentos.Real = ifelse(
	   	Outros.Rendimentos == 1,
	 	rowSums(
	 		cbind(V5001A2, V5002A2, V5003A2, V5005A2, V5008A2) * CO1e,
	 		na.rm = TRUE
 		),
	 	NA
   	)
)

# Determinar a renda domiciliar per capita

# rendimento domiciliar a preços médios do último ano
desenho$variables <- transform(
	desenho$variables,
	VD5007.Real = ave(
		ifelse(is.na(VD4019), 0, VD4019.Real) +
		ifelse(is.na(VD4048), 0, VD4048.Real),
		ID_DOMICILIO,
		FUN = sum
	),
	VD4019.Dom.Real = ave(VD4019.Real, ID_DOMICILIO, FUN = sum)
)

# rendimento domiciliar per capita a preços médios do ano
desenho$variables <- transform(
	desenho$variables,
	VD5008.Real = ifelse(
		V2005.Incluidas == 1,
		VD5007.Real / V2001.Incluidos,
		NA
	),
	VD4019.DPC.Real = ifelse(
		V2005.Incluidas == 1,
		VD4019.Dom.Real / V2001.Incluidos,
		NA
	)
)

# Agora calcular as participações na renda domiciliar por tipo de rendimento
rme_dom_percapita <- svyby(
	~VD4019.Dom.Real,
	by = ~UF,
	denominator = ~VD5007.Real,
	design = subset(desenho, V2005.Incluidas == 1),
	FUN = svyratio,
	vartype = "cv",
	keep.names = FALSE,
	na.rm = TRUE
)

View(sidra_7429[c(7, 4, 3)])
View(renda_participacao)

# 7437 ----------------------------------------------
sidra_7437 <- get_sidra(x = 7437, variable = 10750, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2)

desenho$variables <- transform(
	desenho$variables,
	VD4052.Real =VD4019.Real + VD4048.Real,
	VD4052.Real2 = ifelse(
		is.na(VD4019) | is.na(VD4048),
		NA, rowSums(cbind(VD4019 * CO2, VD4048 * CO2e))
	)
)

svymean(~VD4052.Real, subset(desenho, VD4052.Real >0))
svymean(~VD4019.Real, subset(desenho, VD4019.Real >0))
svymean(~VD4020.Real, subset(desenho, VD4020.Real >0))
svymean(~VD4048.Real, subset(desenho, VD4048.Real >0))
svymean(~V5004A2.Real, subset(desenho, V5004A2.Real >0))
svymean(~V5007A2.Real, subset(desenho, V5007A2.Real >0))
svymean(~V5006A2.Real, subset(desenho, V5006A2.Real >0))
svymean(~
	Outros.Rendimentos.Real,
	subset(desenho, Outros.Rendimentos.Real >0)
)

unname(sidra_7437[c(7, 4, 3)])

tipo_rendimento <- c(
	Todas.as.Fontes      = "VD4052",
	Habitual.Trabalhos   = "VD4019",
	Efetivo.Trabalhos    = "VD4020",
	Outras.Fontes        = "VD4048",
	Aposetadoria.Pensao  = "V5004A2",
	Aluguel.Arrendamento = "V5007A2",
	Pensao.Alimenticia   = "V5006A2",
	Outros.Rendimentos   = "Outros.Rendimentos"
)

RMe_por_tipo <- lapply(
	paste0(tipo_rendimento, ".Real"),
	function(var) {
		svyby(
			as.formula(paste0("~", var)),
			~Estrato.Geo,
			subset(desenho, get(var) > 0),
			svymean,
			vartype = "cv"
		)
	}
)

RMe_por_tipo <- Reduce(function(...) merge(...), RMe_por_tipo)

colnames(RMe_por_tipo) <- c(
	"Estrato.Geo",
	c(rbind(names(tipo_rendimento), paste0("cv.", 1:8)))
)
