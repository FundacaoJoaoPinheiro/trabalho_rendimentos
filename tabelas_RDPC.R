# Tabelas "7543", "7544", "7553", "7554"

pacotes <- c("sidrar", "PNADcIBGE", "survey", "convey")
lapply(pacotes, library, character.only = TRUE)
source("utilitarios.R")

options(scipen = 999)

desenho <- gerar_desenho(tabelas_RDPC)

# as 3 categorias abaixos são excluídas no cálculo da rendimento domiciliar
desenho$variables <- transform(
	desenho$variables,
	V2005.Rendimento = ifelse(
		V2005 == "Pensionista" |
		V2005 == "Empregado(a) doméstico(a)" |
		V2005 == "Parente do(a) empregado(a) doméstico(a)",
		NA, 1
	)
)

# moradores por domicílio incluídos no cálculo do rendimento domiciliar
desenho$variables <- transform(
	desenho$variables,
	V2001.Rendimento = ave(
		V2005.Rendimento,
		ID_DOMICILIO,
		FUN = function(x) sum(x, na.rm=T)
	)
)

# incluindo variáveis deflacionadas
# (obs: para o último ano, CO1 = CO2 e CO1e = CO2e)
desenho$variables <- transform(
	desenho$variables,
	VD4019.Real1 = ifelse(is.na(VD4019), NA, VD4019 * CO1),
	VD4019.Real2 = ifelse(is.na(VD4019), NA, VD4019 * CO2),
	VD4048.Real1 = ifelse(is.na(VD4048), NA, VD4048 * CO1e),
	VD4048.Real2 = ifelse(is.na(VD4048), NA, VD4048 * CO2e)
)

# rendimento de todas as fontes
desenho$variables <- transform(
	desenho$variables,
	VD4052.Real1 =
		ifelse(is.na(VD4019), 0, VD4019.Real1) +
		ifelse(is.na(VD4048), 0, VD4048.Real1),
	VD4052.Real2 =
		ifelse(is.na(VD4019), 0, VD4019.Real2) +
		ifelse(is.na(VD4048), 0, VD4048.Real2)
)

# rendimento domiciliar a preços médios do último ano
desenho$variables <- transform(
	desenho$variables,
	VD5007.Real1 = ave(VD4052.Real1, ID_DOMICILIO, FUN = sum),
	VD5007.Real2 = ave(VD4052.Real2, ID_DOMICILIO, FUN = sum)
)

# rendimento domiciliar per capita a preços médios do último ano
desenho$variables <- transform(
	desenho$variables,
	VD5008.Real1 = ifelse(
		is.na(V2005.Rendimento),
		NA, VD5007.Real1 / V2001.Rendimento
	),
	VD5008.Real2 = ifelse(
		is.na(V2005.Rendimento),
		NA, VD5007.Real2 / V2001.Rendimento
	)
)

# Tabela 7438 - limites superiores
quantis1 <- svyby(
	~VD5008.Real1,
	~Estrato.Geo,
	desenho,
	FUN = svyquantile,
	quantiles = c(0.05, seq(0.10, 0.90, by = 0.10), 0.95, 0.99),
	vartype = "cv",
	na.rm = TRUE
)

# Tabela 7521 - população por classe simples
desenho$variables <- transform(
	desenho$variables,
	Classe.Simples1 = add_classe_simples(
		dt = desenho$variables,
		var = "VD5008.Real1",
		quantis = quantis1
	)
)

pop_simples1 <- svyby(
	~V2005.Rendimento,
	~Classe.Simples1 + Estrato.Geo,
	desenho,
	FUN = svytotal,
	vartype = "cv",
	na.rm = TRUE
)

# 7561 - população por classe acumulada
pop_acumuladas1 <- data.frame(
	Estrato.Geo = rep(estratos_geo, each = 13),
	Classes.Acumuladas = rep(rotulos_cap, times = 10),
	Populacao = ave(
		cumsum(pop_simples1$V2005.Rendimento),
		rep(estratos_geo, each = 13)
	)
)

# 7428 - massa de RDPC
massa_rendimento1 <- svyby(
	~VD5008.Real1,
	~Classe.Simples1 + Estrato.Geo,
	desenho,
	FUN = svytotal,
	vartype = "cv",
	na.rm = TRUE
)

# 7531 - RMeDPC por classe simple
rme_simples1 <- svyby(
	~VD5008.Real1,
	~Classe.Simples1 + Estrato.Geo,
	desenho,
	FUN = svymean,
	vartype = "cv",
	na.rm = TRUE
)

# 7534 - RMeDPC por classe acumulada
rme_simples_estrato1 <- split(
	rme_simples1$VD5008.Real1,
	rme_simples1$Estrato.Geo
)

pop_simples_estrato1 <- split(
	pop_simples1$V2005.Rendimento,
	pop_simples1$Estrato.Geo
)

rme_acumul1 <- Map(
	function(renda, pop) {
		cumsum(renda * pop) / cumsum(pop)
	},
	renda = rme_simples_estrato1,
	pop   = pop_simples_estrato1
)
rme_acumul1$Classes.Acumulada <- rotulos_cap

# 7458 - RMeDPC por tipo de benefício social
rme_progsocial2 <- svybys(
	~VD5008.Real2,
	by = ~interaction(V5001A, Estrato.Geo) +
          interaction(V5002A, Estrato.Geo) +
          interaction(V5003A, Estrato.Geo),
	desenho,
	FUN = svymean,
	vartype = "cv",
	na.rm = TRUE
)

# 7527 - distribuição da massa de RDPC por classe simples
massa_rend_estrato1 = split(
	massa_rendimento1$VD5008.Real1,
	massa_rendimento1$Estrato.Geo
)

distribuicao_estrato1 <- lapply(massa_rend_estrato1, function(x) x * 100/ sum(x))

distribuicao1 <- data.frame(
	Estrato.Geo = rep(estratos_geo, each = 13),
	Classes.Simples = rep(rotulos_csp, times = 10),
	Distribuicao.Simples.RDPC1 = unlist(distribuicao_estrato1)
)

# 7530 - distribuição da massa de RDPC por classe simples
distribuicao_acumulada1 <- lapply(distribuicao_estrato1, cumsum)

distribuicao_acumulada1 <- data.frame(
	Estrato.Geo = rep(estratos_geo, each = 13),
	Classes.Acumulada = rep(rotulos_cap, times = 10),
	Distribuicao.Acumulada.RDPC1 = unlist(distribuicao_acumulada1)
)

