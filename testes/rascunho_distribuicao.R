############### RASCUNHO ##################
# comparar valores estimados para MG na sessão do R com aqueles disponíveis 
# nas tabelas da plataforma SIDRA

pacotes <- c("sidrar", "PNADcIBGE", "survey", "convey")
lapply(pacotes, library, character.only = TRUE)
source("testes/utilitarios.R")
options(scipen = 999)

variaveis <- c("V2009", "VD4002", "VD4019", "VD4020")

if (file.exists("desenho_distribuicao.RDS")) {
	desenho_amostral <- readRDS("desenho_distribuicao.RDS")
} else {
	desenho_amostral <- gerar_DA(variaveis)
}

# Distribuição do rendimento mensal -------------------------------------------

# Deflacionar variáveis de rendimento
desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	VD4019.Real1 = ifelse(is.na(VD4019) | V2009 <= 14, NA, VD4019 * CO1),
	VD4019.Real2 = ifelse(is.na(VD4019) | V2009 <= 14, NA, VD4019 * CO2),
	VD4020.Real1 = ifelse(is.na(VD4020) | V2009 <= 14, NA, VD4020 * CO1e),
	VD4020.Real2 = ifelse(is.na(VD4020) | V2009 <= 14, NA, VD4020 * CO2e)
)

# 7543 --> VD4019 * CO1, classe simples; Resultados muito parecidos
sidra_7543 <- get_sidra(
	x = 7543, variable = 10848, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7543)

# classes simples de percentual (CSP)
rotulos_classe = c(
	"Até P5",
	"Maior que P5 até P10",
	"Maior que P10 até P20",
	"Maior que P20 até P30",
	"Maior que P30 até P40",
	"Maior que P40 até P50",
	"Maior que P50 até P60",
	"Maior que P60 até P70",
	"Maior que P70 até P80",
	"Maior que P80 até P90",
	"Maior que P90 até P95",
	"Maior que P95 até P99",
	"Maior que P99"
)

quantis2 <- svyby(
	~VD4019.Real1,
	~UF,
	desenho_amostral,
	FUN = svyquantile,
	quantiles = c(0.05, seq(0.10, 0.90, by = 0.10), 0.95, 0.99),
	na.rm = TRUE
)

rendimento_UF1 <- split(
	desenho_amostral$variables$VD4019.Real1,
	desenho_amostral$variables$UF
)

quantis_UF1 <-  split(quantis2[2:13], quantis2[[1]])

classes_simples1 <- Map(
	function(renda, breaks) {
		cut(
			renda,
			breaks = c(-Inf, as.numeric(breaks), Inf),
			labels = rotulos_classe,
			right = FALSE
		)
	},
	renda = rendimento_UF1,
	breaks = quantis_UF1
)

# adicionar coluna com as classes simples por percentual (CSP)
desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	CSP.VD4019.Real1 = unsplit(classes_simples1, UF)
)

massa_rendimento1 <- svyby(
	~VD4019.Real1,
	~CSP.VD4019.Real1 + UF,
	desenho_amostral,
	FUN = svytotal,
	na.rm = TRUE
)

massa_rendimento1_UF1 = split(
	massa_rendimento1$VD4019.Real1,
	massa_rendimento1$UF
)

distribuicao_UF1 <- lapply(massa_rendimento1_UF1, function(x) x * 100/ sum(x))

distribuicao1 <- data.frame(
	UF = rep(unidades_federativas, each = 13),
	Classes.Simples = rep(rotulos_classe, times = 4),
	Distribuicao.Simples.RDPC1 = unlist(distribuicao_UF1)
)

View(sidra_7543[c(4,7,4)])
View(distribuicao1)

# 7544 --> VD4019 * CO1, classe acumulada; Resultados muito parecidos
sidra_7544 <- get_sidra(
	x = 7544, variable = 10848, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)

distribuicao_acumulada_UF1 <- lapply(distribuicao_UF1, cumsum)

distribuicao_acumulada1 <- data.frame(
	UF = rep(unidades_federativas, each = 13),
	Classes.Acumuladas = rep(rotulos_cap, times = 4),
	Distribuicao.Simples.RDPC1 = unlist(distribuicao_acumulada_UF1)
)

View(sidra_7544[c(4,7,3)])
View(distribuicao_acumulada1)

# 7553 --> VD4020 * CO1, classe simples; o mesmo que 7543

# 7554 --> VD4020 * CO1, classe acumulada; o mesmo que 7544
