# Tabelas "7543", "7544", "7553", "7554"

pacotes <- c("sidrar", "PNADcIBGE", "survey", "convey")
lapply(pacotes, library, character.only = TRUE)
source("utilitarios.R")

options(scipen = 999)

desenho <- gerar_desenho(tabelas_RMe)

# incluindo variáveis deflacionadas
# (obs: para o último ano, CO1 = CO2 e CO1e = CO2e)
desenho$variables <- transform(
	desenho$variables,
	VD4019.Real1 = ifelse(is.na(VD4019), NA, VD4019 * CO1),
	VD4019.Real2 = ifelse(is.na(VD4019), NA, VD4019 * CO2),
	VD4020.Real1 = ifelse(is.na(VD4020), NA, VD4020 * CO1e),
	VD4020.Real2 = ifelse(is.na(VD4020), NA, VD4020 * CO2e)
)

# Tabela 7441
rme2_cor_raca <- svyby(
	~VD4019.Real2 + VD4020.Real2,
	~V2010 + Estrato.Geo,
	desenho,
	svymean,
	vartype = "cv",
	na.rm = TRUE,
	na.rm.all = TRUE
)

# Tabela 7442
desenho$variables <- transform(
	desenho$variables,
	Grupos.de.Idade = cut(
		V2009,
		breaks = c(13, 17, 19, 24, 29, 39, 49, 59, Inf),
		labels = c(
			"14 a 17 anos",
			"18 e 19 anos",
			"20 a 24 anos",
			"25 a 29 anos",
			"30 a 39 anos",
			"40 a 49 anos",
			"50 a 59 anos",
			"60 anos ou mais"
		),
		right = TRUE
	)
)

rme2_idade <- svyby(
	~VD4019.Real2 + VD4020.Real2,
	~Grupos.de.Idade + Estrato.Geo,
	desenho,
	FUN = svymean,
	vartype = "cv",
	na.rm = TRUE
)

# Tabela 7443
rme2_instrucao <- svyby(
	~VD4019.Real2 + VD4020.Real2,
	~VD3004 + Estrato.Geo,
	desenho,
	svymean,
	vartype = "cv",
	na.rm = TRUE
)

# Tabela 7444
rme2_sexo <- svyby(
	~VD4019.Real2 + VD4020.Real2,
	~V2007 + Estrato.Geo,
	desenho,
	svymean,
	vartype = "cv",
	na.rm = TRUE
)

# Tabela 7445
rme2_area <- svyby(
	~VD4019.Real2 + VD4020.Real2,
	~V1023 + Estrato.Geo,
	desenho,
	svymean,
	vartype = "cv",
	na.rm = TRUE
)

# Tabela 7446
rme2_responsavel <- svyby(
	~VD4019.Real2 + VD4020.Real2,
	~UF,
	subset(
		desenho,
		V2005 == "Pessoa responsável pelo domicílio"
	),
	svymean,
	vartype = "cv",
	na.rm = TRUE
)

# Tabela 7453
rme2_gini <- svyby(
	~VD4019.Real1,
	~Estrato.Geo,
	desenho,
	FUN = svygini,
	vartype = "cv",
	na.rm = TRUE
)

# Tabela 7535
quantis1 <- svyby(
	~VD4019.Real1,
	~Estrato.Geo,
	desenho,
	quantiles = c(0.05, seq(0.10, 0.90, by = 0.10), 0.95, 0.99),
	FUN = svyquantile,
	vartype = "cv",
	na.rm = TRUE
)

desenho$variables <- transform(
	desenho$variables,
	Classe.Simples1 = add_classe_simples(
		desenho$variables,
		"VD4019.Real1",
		quantis1
	)
)

rme1_classe <- svyby(
	~VD4019.Real1,
	~Classe.Simples1 + Estrato.Geo,
	desenho,
	svymean,
	vartype = "cv",
	na.rm = TRUE
)

# Tabela 7538
pop_classes_estrato <- svyby(
	~!is.na(VD4019.Real1),
	~Classe.Simples1 + Estrato.Geo,
	desenho,
	svytotal,
	na.rm = TRUE
)
names(pop_classes_estrato)[4] <- "Populacao"

pop_classes_estrato <- split(
	pop_classes_estrato$Populacao,
	pop_classes_estrato$Estrato.Geo
)

rme1_classe_estrato <- split(rme1_classe$VD4019.Real1, rme1_classe$Estrato.Geo)

rme1_acumul_estrato <- Map(
	function(renda, pop) {
		cumsum(renda * pop) / cumsum(pop)
	},
	renda = rme1_classe_estrato,
	pop   = pop_classes_estrato
)

rme1_acumul <- data.frame(
	Estrato.Geo = rep(estratos_geo, each = 13),
	Classes.Acumuladas = rep(rotulos_cap, 10),
	Renda.Media.Real1  = unlist(rme1_acumul_estrato)
)

# Tabela 7539
quantis_rme2 <- svyby(
	~VD4019.Real2,
	~Estrato.Geo,
	desenho,
	quantiles = c(0.05, seq(0.10, 0.90, by = 0.10), 0.95, 0.99),
	FUN = svyquantile,
	na.rm = TRUE
)

desenho$variables <- transform(
	desenho$variables,
	Classe.Simples2 = add_classe_simples(
		desenho$variables,
		"VD4019.Real2",
		quantis_rme2
	)
)

rme2_classe <- svyby(
	~VD4019.Real2,
	~Classe.Simples2 + Estrato.Geo,
	desenho,
	svymean,
	vartype = "cv",
	na.rm = TRUE
)

# Tabela 7542
pop_classes_estrato <- svyby(
	~!is.na(VD4019.Real2),
	~Classe.Simples2 + Estrato.Geo,
	desenho,
	svytotal,
	na.rm = TRUE
)
names(pop_classes_estrato)[4] <- "Populacao"
pop_classes_estrato <- split(
	pop_classes_estrato$Populacao,
	pop_classes_estrato$Estrato.Geo
)

rme2_classe_estrato <- split(rme2_classe$VD4019.Real2, rme2_classe$Estrato.Geo)
rme2_classe_estrato <- Map(
	function(renda, pop) {
		cumsum(renda * pop) / cumsum(pop)
	},
	renda = rme2_classe_estrato,
	pop   = pop_classes_estrato
)

rme2_acumul <- data.frame(
	Estrato.Geo = rep(estratos_geo, each = 13),
	Classes.Acumuladas = rep(rotulos_cap, 10),
	Renda.Media.Real2  = unlist(rme2_classe_estrato)
)
