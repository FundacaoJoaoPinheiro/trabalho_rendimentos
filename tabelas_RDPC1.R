# Reproduzir tabelas SIDRA para os dez estratos geográficos de Minas Gerais.
# Tabelas referentes ao rendimento domiciliar per capita, a preços médios do ano:
# Tabelas 7428, 7438, 7521, 7527, 7530, 7531, 7532 e 7561.

# Observação: no ano mais recente, não há diferença entre os deflatores
# do último ano e do próprio ano.

# ---------------------------------------------------------------------
# Preparar ambiente

pacotes <- c("PNADcIBGE", "survey", "convey")
#install.packages(setdiff(pacotes, rownames(installed.packages())))
lapply(pacotes, library, character.only = TRUE)

# carregar objetos e funções utilizados no script:
# gerar_desenho(); ad_classes_simples(); estimar_quantis(); estimar_totais();
# reshape_wide();
# `tabelas_RDPC1`; `percentis`, `estratos_geo`
source("utilitarios.R")

# ---------------------------------------------------------------------
# Criar colunas necessárias

desenho <- gerar_desenho(tabelas_RDPC1)

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

# rendimento habitual de todos os trabalhos e efetivo de outras fontes
desenho$variables <- transform(
	desenho$variables,
	VD4019.Real = ifelse(is.na(VD4019), NA, VD4019 * CO1),
	VD4048.Real = ifelse(is.na(VD4048), NA, VD4048 * CO1e)
)

# rendimento de todas as fontes
desenho$variables <- transform(
	desenho$variables,
	VD4052.Real =
		ifelse(is.na(VD4019), 0, VD4019.Real) +
		ifelse(is.na(VD4048), 0, VD4048.Real)
)

# rendimento domiciliar a preços médios do último ano
desenho$variables <- transform(
	desenho$variables,
	VD5007.Real = ave(VD4052.Real, ID_DOMICILIO, FUN = sum)
)

# rendimento domiciliar per capita a preços médios do último ano
desenho$variables <- transform(
	desenho$variables,
	VD5008.Real = ifelse(
		is.na(V2005.Rendimento),
		NA, VD5007.Real / V2001.Rendimento
	)
)

# função definida em utilitarios.R, estima `percentis` por estrato geográfico
rdpc_limites <- estimar_quantis(desenho, formula = ~VD5008.Real)

# adiciona coluna com as classes simples de percentual por estrato geográfico
desenho$variables <- transform(
	desenho$variables,
	VD5008.Classes = ad_classes_simples(     # função definida em utilitarios.R
		renda = VD5008.Real,
		geo = Estrato.Geo,
		limites = rdpc_limites
	)
)

# ---------------------------------------------------------------------
# Gerar tabelas de valores e CV's

# Tabela 7428 - Massa de rendimento domiciliar per capita (RDPC) por
# classe simples de percentual (CSP) e estrato geográfico
# função definida em utilitarios.R, estima totais por estrato geográfico
rdpc_massa <- estimar_totais(
	desenho = subset(desenho, V2005.Rendimento == 1),
	formula = ~VD5008.Real,
	por = ~VD5008.Classes
)

tab_7428 <- reshape_wide(rdpc_massa[, -4])
cv_7428  <- reshape_wide(rdpc_massa[, -3])
cv_7428[, -1] <- round(cv_7428[, -1] * 100, 1)

# Tabela 7438 - limites superiores por estrato geográfico
rdpc_limites[[1]] <- estratos_geo

tab_7438 <- rdpc_limites[, c(1, 2:13)]
cv_7438  <- rdpc_limites[, c(1, 14:25)]
cv_7438[, -1] <- round(cv_7438[, -1] * 100, 1)

# Tabela 7521 - População por classe simples de percentual (CSP)
pop_classesimples <- estimar_totais(
	subset(desenho, V2005.Rendimento == 1),
	~VD5008.Classes
)

tab_7521 <- pop_classesimples[, c(1, 2:14)]
cv_7521  <- pop_classesimples[, c(1, 15:27)]
cv_7521[, -1] <- round(cv_7521[, -1] * 100, 1)

# Tabela 7435 - valores próximos, iguais arredondando
rdpc_gini <- svyby(
	~VD5008.Real,
	~Estrato.Geo,
	subset(desenho, V2005.Rendimento == 1),
	FUN = svygini,
	keep.names = FALSE,	
	vartype = "cv",
	na.rm = TRUE
)

tab_7435 <- rdpc_gini
colnames(tab_7435) <- c("Estrato.Geo", "Valor", "CV")
tab_7435[[1]] <- estratos_geo
tab_7435[, 2] <- round(tab_7435[, 2], 3)
tab_7435[, 3] <- round(tab_7435[, 3] * 100, 1)
