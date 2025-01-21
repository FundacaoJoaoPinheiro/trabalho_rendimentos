# Tabelas "7543", "7544", "7553", "7554"

pacotes <- c("sidrar", "PNADcIBGE", "survey", "convey")
lapply(pacotes, library, character.only = TRUE)
source("utilitarios.R")

options(scipen = 999)

desenho <- gerar_desenho(tabelas_distribuicao)

# Deflacionar variáveis de rendimento
desenho$variables <- transform(
	desenho$variables,
	VD4019.Real1 = ifelse(is.na(VD4019) | V2009 <= 14, NA, VD4019 * CO1),
	VD4019.Real2 = ifelse(is.na(VD4019) | V2009 <= 14, NA, VD4019 * CO2),
	VD4020.Real1 = ifelse(is.na(VD4020) | V2009 <= 14, NA, VD4020 * CO1e),
	VD4020.Real2 = ifelse(is.na(VD4020) | V2009 <= 14, NA, VD4020 * CO2e)
)

# Rendimento Habitual

# limites superiores (7536)
quantis_habitual1 <- estimar_quantis("~VD4019.Real1", desenho)

# classes simples por percentual (CSP)
desenho$variables$Classes.Simples.H1 <- add_classe_simples(
	desenho$variables,
	"VD4019.Real1",
	quantis_habitual1
)

massa_habitual1 <- svyby(
	~VD4019.Real1,
	~Classes.Simples.H1 + Estrato.Geo,
	desenho_amostral,
	FUN = svytotal,
	vartype = "cv",
	na.rm = TRUE
)

# criar uma lista com um item para cada estrato
massa_hab_estrato1 = split(
	massa_habitual1$VD4019.Real1,
	massa_habitual1$Estrato.Geo
)

distribuicao_estrato1 <- lapply(massa_hab_estrato1, function(x) x * 100/ sum(x))
distrib_acumul_estrato1 <- lapply(distribuicao_estrato1, cumsum)

# Tabela 7543
distribuicao1 <- data.frame(
	Estrato.Geo = rep(estratos_geo, each = 13),
	Classes.Simples = rep(rotulos_csp, times = 10),
	Distribuicao.Simples.RDPC1 = unlist(distribuicao_estrato1)
)

# Tabela 7544
distribuicao_acumulada1 <- data.frame(
	Estrato.Geo = rep(estratos_geo, each = 13),
	Classes.Acumulada = rep(rotulos_cap, times = 10),
	Distribuicao.Acumulada = unlist(distrib_acumul_estrato1)
)

