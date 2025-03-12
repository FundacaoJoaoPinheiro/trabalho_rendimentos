# Reproduz tabelas SIDRA para os dez estratos geográficos de Minas Gerais.
# Tabelas referentes ao rendimento habitual médio da população, a preços
# médios do ano: 7453, 7535, 7537, 7538, 7545, 7548, 7549, 7552.

# ---------------------------------------------------------------------
# Preparar ambiente

pacotes <- c("PNADcIBGE", "survey", "convey")
#install.packages(setdiff(pacotes, rownames(installed.packages())))
lapply(pacotes, library, character.only = TRUE)

# carregar objetos e funções utilizados no script:
# gerar_desenho(); estimar_quantis(); ad_classes_simples(); estimar_medias();
# estimar_totais(); estimar_cap; reshape_wide();
# `tabelas_RMe1`; `estratos_geo`
source("utilitarios.R")     # objetos e funções utilizados abaixo

# ---------------------------------------------------------------------
# Criar colunas necessárias

desenho <- gerar_desenho(tabelas_RMe1)

desenho$variables <- transform(
	desenho$variables,
	VD4019.Real = VD4019 * CO1,
	VD4020.Real = VD4020 * CO1e
)

desenho$variables <- transform(
	desenho$variables,
	# função definida em utilitarios.R
	Grupo.de.Idade = ad_grupos_idade(idade = V2009)
)

# função definida em utilitarios.R
limites_hab <- estimar_quantis(
	desenho = subset(desenho, VD4019 > 0),
	formula = ~VD4019.Real
)

limites_efet <- estimar_quantis(
	subset(desenho, VD4019 > 0),
	~VD4020.Real
)

desenho$variables <- transform(
	desenho$variables,
	# função definida em utilitarios.R
	VD4019.Classe = ad_classes_simples(
		renda = VD4019.Real,
		geo = Estrato.Geo,
		limites = limites_hab[, 1:13]
	),
	VD4020.Classe = ad_classes_simples(
		renda = VD4020.Real,
		geo = Estrato.Geo,
		limites = limites_efet[, 1:13]
	)
)

# ---------------------------------------------------------------------
# Reproduzir tabelas

# Tabela 7453 - Índice de Gini do rendimento habitual
rme_gini <- svyby(
	~VD4019.Real,
	~Estrato.Geo,
	desenho,
	FUN = svygini,
	vartype = "cv",
	keep.names = FALSE,
	na.rm = TRUE
)

tab_7453 <- rme_gini
tab_7453[, 2] <- round(tab_7453[, 2], 3)        # índices
tab_7453[, 3] <- round(tab_7453[, 3] * 100, 1)  # cv's
tab_7453[[1]] <- estratos_geo
colnames(tab_7453)[2:3] <- c("Indice.de.Gini", "CV")

# Tabela 7535 - Rendimento habitual médio por classe simples de percentual
rme_csp_hab <- estimar_medias(
	desenho = subset(desenho, VD4019 > 0),
	formula = ~VD4019.Real,
	por = ~VD4019.Classe
)

tab_7535 <- reshape_wide(rme_csp_hab[, -4])
cv_7535  <- reshape_wide(rme_csp_hab[, -3])
cv_7535[, -1]  <- round(cv_7535[, -1] * 100, 1)

# Tabela 7537 - População por classe simples de percentual de rendimento habitual
rme_pop_hab <- estimar_totais(
	subset(desenho, VD4019 > 0),
	~VD4019.Classe
)
rme_pop_hab[[1]] <- estratos_geo

tab_7537 <- rme_pop_hab[, c(1, 2:14)]
cv_7537  <- rme_pop_hab[, c(1, 15:27)]
cv_7537[, -1]  <- round(cv_7537[, -1] * 100, 1)
colnames(tab_7537) <- c("Estrato.Geo", classes_simples)
colnames(cv_7537) <- c("Estrato.Geo", classes_simples)

# Tabela 7538 - Rendimento habitual médio por classe acumulada de percentual
rme_cap_hab <- estimar_cap(
	desenho = subset(desenho, VD4019 > 0),
	formula = ~VD4019.Real,
	csp = "VD4019.Classe"
)

tab_7538 <- rme_cap_hab[[1]]
cv_7538  <- rme_cap_hab[[2]]

# Tabela 7545 - Rendimento efetivo médio por classe simples de percentual
rme_csp_efet <- estimar_medias(
	desenho = subset(desenho, VD4020 > 0),
	formula = ~VD4020.Real,
	por = ~VD4020.Classe
)

tab_7545 <- reshape_wide(rme_csp_efet[, -4])
cv_7545  <- reshape_wide(rme_csp_efet[, -3])
cv_7545[, -1]  <- round(cv_7545[, -1] * 100, 1)

# Tabela 7548 - Rendimento habitual médio por classe acumulada de percentual
rme_cap_efet <- estimar_cap(
	subset(desenho, VD4020 > 0),
	~VD4020.Real,
	"VD4020.Classe"
)

tab_7548 <- rme_cap_efet[[1]]
cv_7548  <- rme_cap_efet[[2]]
