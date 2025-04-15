############### RASCUNHO ##################
# comparar valores estimados para MG na sesão do R com aqueles disponíveis 
# nas tabelas da plataforma SIDRA

pacotes <- c("sidrar", "PNADcIBGE", "survey", "convey")
lapply(pacotes, library, character.only = TRUE)
source("utilitarios.R")
options(scipen = 999)

pnadc_ano = 2023
visita = 1
pnadc_dir = "Microdados"

if (file.exists("desenho_RMe.RDS")) {
	desenho <- readRDS("desenho_RMe.RDS")
} else {
	desenho <- gerar_desenho(tabelas_RMe2)
}

# Rendimento médio mensal das pesoas ocupadas ----------------------------

# ÚLTIMO ANO -------------------------------------------------------------

# Deflacionar variáveis de rendimento
desenho$variables <- transform(
	desenho$variables,
	VD4019.Real1 = VD4019 * CO1,
	VD4019.Real2 = VD4019 * CO2
)

# 7441 --> CO2, V2010 ---------------------------------------
# variável 10774 é de rendimento habitual, 10776 é de efetivo
sidra_7441 <- get_sidra(x = 7441, variable = 10774, period = "2023",
	geo = "State", geo.filter = list("State" = c(15,29,31,52)), format = 2)

# estimar_medias() é definida em utilitarios.R, estima as médias por UF
rme_cor_raca2 <- estimar_medias(
	desenho = subset(desenho, V2009 >= 14 & VD4019 > 0),
	formula = ~VD4019.Real2,
	por = ~V2010
)

# comparar resultados estiamos com as tabelas do SIDRA
View(sidra_7441[c(4,7,3)])
View(rme_cor_raca2)

tab_7441 <- reshape_wide(rme_cor_raca2[-4])
tab_7441[, 1] <- unidades_federativas
cv_7441  <- reshape_wide(rme_cor_raca2[-3])
cv_7441[, -1] <- cv_7441[, -1] * 100

# 7442 --> CO2, V2009 ---------------------------------------
# resultados foram bons menos para o primeiro grupo de idade
sidra_7442 <- get_sidra(x = 7442, variable = 10774, period = "2023",
	geo = "State", geo.filter = list("State" = c(15,29,31,52)), format = 2)

desenho$variables <- transform(
	desenho$variables,
	Grupo.de.Idade = ad_grupos_idade(V2009)
)

rme_idade2 <- estimar_medias(
	subset(desenho, V2009 >= 14 & VD4019 > 0),
	~VD4019.Real2,
	~Grupo.de.Idade
)

# comparar resultados estiamos com as tabelas do SIDRA
View(sidra_7442[c(4,7,3)])
View(rme_idade2)

tab_7442 <- reshape_wide(rme_idade2[-4])
cv_7442  <- reshape_wide(rme_idade2[-3])

# 7443 --> CO2, VD3004 ---------------------------------------
sidra_7443 <- get_sidra(x = 7443, variable = 10774, period = "2023",
	geo = "State", geo.filter = list("State" = c(15,29,31,52)), format = 2)

rme_instrucao2 <- estimar_medias(
	subset(desenho, V2009 >= 14 & VD4019 > 0),	
	~VD4019.Real2,
	~VD3004
)

# comparar resultados estiamos com as tabelas do SIDRA
View(sidra_7443[c(4,7,3)])
View(rme_instrucao2)

tab_7443 <- reshape_wide(rme_instrucao2[-4])
cv_7443  <- reshape_wide(rme_instrucao2[-3])

# 7444 --> CO2, V2007 ---------------------------------------
sidra_7444 <- get_sidra(x = 7444, variable = 10774, period = "2023",
	geo = "State", geo.filter = list("State" = c(15,29,31,52)), format = 2)

rme_sexo2 <- estimar_medias(
	subset(desenho, V2009 >= 14 & VD4019 > 0),
	~VD4019.Real2,
	~V2007
)

# comparar resultados estiamos com as tabelas do SIDRA
View(sidra_7444[c(4,7,3)])
View(rme_sexo2)

tab_7444 <- reshape_wide(rme_sexo2[-4])
cv_7444  <- reshape_wide(rme_sexo2[-3])

# 7445 --> CO2, V1023 ---------------------------------------
# como vamos trabalhar com estratos geográficos, não faz sentido
# reproduzir a divisão territorial da tabela 7445

# 7446 --> CO2, V2005 ---------------------------------------
sidra_7446 <- get_sidra(x = 7446, variable = 10778, period = "2023",
	geo = "State", geo.filter = list("State" = c(15,29,31,52)), format = 2)

rme_responsavel2 <- estimar_medias(
	subset(
		desenho,
		V2009 >= 14 & VD4019 > 0 & V2005 == "Pesoa responsável pelo domicílio"
	),
	~VD4019.Real2,
	~UF
)

# comparar resultados estiamos com as tabelas do SIDRA
View(sidra_7446[c(4,3)])
View(rme_responsavel2)

tab_7446 <- rme_responsavel2

# PRÓPRIO ANO ------------------------------------------------------

# 7453 --> CO1, VD4019 ---------------------------------------
sidra_7453 <- get_sidra(x = 7453, variable = 10806, period = "2023",
	geo = "State", geo.filter = list("State" = c(15,29,31,52)), format = 2)

rme_gini2 <- svyby(
	~VD4019.Real1,
	~UF,
	desenho,
	FUN = svygini,
	vartype = "cv",
	na.rm = TRUE
)

# comparar resultados estiamos com as tabelas do SIDRA
unname(sidra_7453[c(4,3)])
print(rme_gini2)

tab_7453 <- rme_gini2

# 7535 --> CO1, VD4019 ---------------------------------------
sidra_7535 <- get_sidra(x = 7535, variable = 10842, period = "2023",
	geo = "State", geo.filter = list("State" = c(15,29,31,52)), format = 2)

limites_hab <- estimar_quantis(
	desenho = subset(desenho, VD4019 > 0),
	formula = ~VD4019.Real
)

desenho$variables <- transform(
	desenho$variables,
	Classes.Simples = ad_classes_simples(
		renda = VD4019.Real1,
		geo = UF,
		quantis = rme_limites1
	)
)

# verificar se as classes foram criadas corretamente
View(
	subset(
		desenho$variables,
		UF == "Minas Gerais",
	)[, c("UF", "VD4019.Real1", "FSP.VD4019.Real1")]
)
View(t(split(rme_limites1, rme_limites1[[1]])[[3]]))

rme_faixasimples1 <- estimar_medias(
	subset(desenho, V2009 >= 14 & VD4019 > 0),
	~VD4019.Real1,
	~FSP.VD4019.Real1
)

# comparar resultados estiamos com as tabelas do SIDRA
View(sidra_7535[c(4,7,3)])
View(rme_faixasimples1)

# 7536 --> CO1, VD4019
sidra_7536 <- get_sidra(x = 7536, variable = 10841, period = "2023",
	geo = "State", geo.filter = list("State" = c(15,29,31,52)), format = 2)

# comparar resultados estiamos com as tabelas do SIDRA
View(sidra_7536[c(4,7,3)])
View(rme_limites1)

# 7537 --> CO1, VD4019 ---------------------------------------
sidra_7537 <- get_sidra(x = 7537, variable = 10844, period = "2023",
	geo = "State", geo.filter = list("State" = c(15,29,31,52)), format = 2)

pop_faixasimples1 <- estimar_totais(
	subset(desenho, V2009 >= 14 & VD4019 > 0),
	~FSP.VD4019.Real1
)

# comparar resultados estiamos com as tabelas do SIDRA
View(sidra_7537[c(4,7,3)])
View(pop_faixasimples1)

tab_7537 <- pop_faixasimples1[, c(1, 2:14)]
cv_7537  <- pop_faixasimples1[, c(1, 15:27)]

# 7538 --> CO1
sidra_7538 <- get_sidra(x = 7538, variable = 10842, period = "2023",
	geo = "State", geo.filter = list("State" = c(15,29,31,52)), format = 2)

# isso dá certo, mas ficamos sem os CV's
rme_faixacumulada1 <- acumular_rme(
	rme_faixasimples1[, c(2, 3)],
	pop_faixasimples1[, 1:14]
)

# a outra alternativa seria fazer estimativas para cada classe percentual,
# mantendo assim os CV's estimados por svyby()
# será preenchida com os valores e os CV's. Um item da lista para cada classe
rme_faixacumulada1 <- estimar_cap(
	desenho,
	renda = "VD4019.Real1",
	limites = rme_limites1
)

tab_7538 <- rme_faixacumulada1[[1]]
cv_7538  <- rme_faixacumulada1[[2]]

# comparar resultados estiamos com as tabelas do SIDRA
View(sidra_7538[c(4, 7, 3)])
View(rme_faixacumulada1)

# 7539 --> CO2, VD4019 ---------------------------------------
sidra_7539 <- get_sidra(x = 7539, variable = 10774, period = "2023",
	geo = "State", geo.filter = list("State" = c(15,29,31,52)), format = 2)

quantis_RMe2 <- svyby(
	~VD4019.Real2,
	~UF,
	desenho,
	quantiles = c(0.05, seq(0.10, 0.90, by = 0.10), 0.95, 0.99),
	FUN = svyquantile,
	na.rm = TRUE
)
quantis_RMe2 <- split(quantis_RMe2[2:13], quantis_RMe2[[1]])

VD4019_real2_uf <- split(
	desenho$variables$VD4019.Real2,
	desenho$variables$UF
)

classes_VD4019_real2 <- Map(
	function(renda, breaks) {
		cut(
			renda,
			breaks = c(-Inf, unlist(breaks), Inf),
			labels = faixas_simples,
			right = FALSE
		)
	},
	renda = VD4019_real2_uf,
	breaks = quantis_RMe2
)

desenho$variables <- transform(
	desenho$variables,
	FSP.VD4019.Real2 = unsplit(classes_VD4019_real2, UF)
)

rme_faixasimples2 <- svyby(
	~VD4019.Real2,
	~FSP.VD4019.Real2 + UF,
	desenho,
	svymean,
	vartype = "cv",
	na.rm = TRUE
)

# comparar resultados estiamos com as tabelas do SIDRA
View(sidra_7539[c(7,4,3)])
View(rme_faixasimples2)

# 7542 --> CO2, VD4019 ---------------------------------------
sidra_7542 <- get_sidra(x = 7542, variable = 10774, period = "2023",
	geo = "State", geo.filter = list("State" = c(15,29,31,52)), format = 2)

# classes acumuladas de percentual (CASP)
faixas_faixacumuladaadas = c(paste0("Até P", c(5, 1:9 * 10, 95, 99)), "Total")

pop_faixasimples_uf <- svyby(
	~!is.na(VD4019.Real2),
	~FSP.VD4019.Real2 + UF,
	desenho,
	svytotal,
	na.rm = TRUE
)
names(pop_faixasimples_uf)[4] <- "Populacao"
pop_faixasimples_uf <- split(pop_faixasimples_uf$Populacao, pop_faixasimples_uf$UF)

rme_faixasimples_uf2 <- split(rme_faixasimples2$VD4019.Real2, rme_faixasimples2$UF)
rme_faixasimples_uf2 <- Map(
	function(renda, pop) {
		cumsum(renda * pop) / cumsum(pop)
	},
	renda = rme_faixasimples_uf2,
	pop   = pop_faixasimples_uf
)

rme_faixacumulada2 <- data.frame(
	UF = rep(unidades_federativas, each = 13),
	Classes.Acumuladas = rep(faixas_faixacumuladaadas, 4),
	Renda.Media.Real2  = unlist(rme_faixasimples_uf2)
)

# comparar resultados estiamos com as tabelas do SIDRA
View(sidra_7542[c(4, 7, 3)])
View(rme_faixacumulada2)

# 7545 --> CO1, VD4020 ---------------------------------------

# 7548 --> CO1, VD4020 ---------------------------------------

# 7549 --> CO2, VD4020 ---------------------------------------

# 7552 --> CO2, VD4020 ---------------------------------------

