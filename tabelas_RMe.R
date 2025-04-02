# Reproduz tabelas SIDRA para os dez estratos geográficos de Minas Gerais.
# Tabelas referentes ao rendimento habitual médio da população,
# 1) a preços médios do ano: 7453, 7535, 7538, 7545, 7548
# 2) a preços médios do último ano: 7441, 7442, 7443, 7444, 7446.

# Observação: como para o ano mais recente não tem diferença entre os deflatores
# do próprio ano e do último ano, estamos considerando a mesma variável de renda
# deflacionada para os dois casos.

# ---------------------------------------------------------------------
# Preparar ambiente

pacotes <- c("PNADcIBGE", "survey", "convey")
#install.packages(setdiff(pacotes, rownames(installed.packages())))
lapply(pacotes, library, character.only = TRUE)

# carregar objetos e funções utilizados no script:
# gerar_desenho(); estimar_quantis(); ad_classes_simples(); estimar_medias();
# estimar_totais(); estimar_cap; reshape_wide();
# `tabelas_RMe`; `estratos_geo`
source("utilitarios.R")     # objetos e funções utilizados abaixo

# ---------------------------------------------------------------------
# Criar colunas necessárias

desenho <- gerar_desenho(tabelas_RMe)

desenho$variables <- transform(
	desenho$variables,
	VD4019.Real = VD4019 * CO1,
	VD4020.Real = VD4020 * CO1e
)

desenho$variables <- transform(
	desenho$variables,
	Grupo.de.Idade = ad_grupos_idade(idade = V2009)
)

# tabela 7536
limites_vd4019real <- estimar_quantis(
	desenho = subset(desenho, VD4019 > 0),
	formula = ~VD4019.Real
)

# tabela 7546
limites_vd4020real <- estimar_quantis(
	subset(desenho, VD4019 > 0),
	~VD4020.Real
)

desenho$variables <- transform(
	desenho$variables,
	VD4019.Classe = ad_classes_simples(
		renda = VD4019.Real,
		geo = Estrato.Geo,
		limites = limites_vd4019real[, 1:13]
	),
	VD4020.Classe = ad_classes_simples(
		renda = VD4020.Real,
		geo = Estrato.Geo,
		limites = limites_vd4020real[, 1:13]
	)
)

# ---------------------------------------------------------------------
# Reproduzir tabelas

# Tabela 7453 - Índice de Gini do rendimento médio habitualmente recebido
gini_vd4019RMe <- svyby(
	~VD4019.Real,
	~Estrato.Geo,
	desenho,
	FUN = svygini,
	vartype = "cv",
	keep.names = FALSE,
	na.rm = TRUE
)

tab_7453 <- gini_vd4019RMe
colnames(tab_7453) <- c("Estrato", "Indice.de.Gini", "CV")

cv_7453 <- gini_vd4019RMe[, -2]
colnames(cv_7453) <- c("Estrato", "cv")

# Tabela 7535 - Rendimento habitual médio por classe simples de percentual
rme_vd4019classe <- estimar_medias(
	desenho = subset(desenho, VD4019 > 0),
	formula = ~VD4019.Real,
	por = ~VD4019.Classe
)

tab_7535 <- reshape_wide(rme_vd4019classe[, -4])
cv_7535  <- reshape_wide(rme_vd4019classe[, -3])

# Tabela 7538 - Rendimento habitual médio por classe acumulada de percentual
rme_vd4019cap <- estimar_cap(
	desenho = subset(desenho, VD4019 > 0),
	formula = ~VD4019.Real,
	FUN = estimar_medias,
	csp = "VD4019.Classe"
)

tab_7538 <- rme_vd4019cap[[1]]
cv_7538  <- rme_vd4019cap[[2]]

# Tabela 7545 - Rendimento efetivo médio por classe simples de percentual
rme_vd4020classe <- estimar_medias(
	desenho = subset(desenho, VD4020 > 0),
	formula = ~VD4020.Real,
	por = ~VD4020.Classe
)

tab_7545 <- reshape_wide(rme_vd4020classe[, -4])
cv_7545  <- reshape_wide(rme_vd4020classe[, -3])

# Tabela 7548 - Rendimento habitual médio por classe acumulada de percentual
rme_vd4020cap <- estimar_cap(
	subset(desenho, VD4020 > 0),
	~VD4020.Real,
	FUN = estimar_medias,
	"VD4020.Classe"
)

tab_7548 <- rme_vd4020cap[[1]]
cv_7548  <- rme_vd4020cap[[2]]

# Tabela 7441 - Rendimento médio real por cor ou raça
rme_cor <- estimar_medias(
	subset(
		desenho,
		VD4019 > 0 & V2010 %in% c("Branca", "Preta", "Parda")
	),
	~VD4019.Real,
	~V2010
)
rme_cor <- subset(rme_cor, V2010 %in% c("Branca", "Preta", "Parda"))
rme_cor$V2010 <- droplevels(rme_cor$V2010)

tab_7441 <- reshape_wide(rme_cor[, -4])
cv_7441  <- reshape_wide(rme_cor[, -3])

# Tabela 7442 - Rendimento médio real por grupo de idade
rme_idade <- estimar_medias(
	subset(desenho, VD4019 > 0),
	~VD4019.Real,
	~Grupo.de.Idade
)

tab_7442 <- reshape_wide(rme_idade[, -4])
cv_7442  <- reshape_wide(rme_idade[, -3])

# Tabela 7443 - Rendimento médio real por nível de instrução
rme_instrucao <- estimar_medias(
	subset(desenho, VD4019 > 0),
	~VD4019.Real,
	~VD3004
)
levels(rme_instrucao) <- niveis_instrucao

tab_7443 <- reshape_wide(rme_instrucao[, -4])
cv_7443  <- reshape_wide(rme_instrucao[, -3])

# Tabela 7444 - Rendimento médio real por sexo
rme_sexo <- estimar_medias(
	subset(desenho, VD4019 > 0),
	~VD4019.Real,
	~V2007
)

tab_7444 <- reshape_wide(rme_sexo[-4])
cv_7444  <- reshape_wide(rme_sexo[-3])

# Tabela 7446 - Rendimento médio real de pessoas responsáveis pelo domícilio
rme_responsavel <- estimar_medias(
	subset(desenho, VD4019 > 0 & V2005 == "Pessoa responsável pelo domicílio"),
	~VD4019.Real
)

tab_7446 <- rme_responsavel
colnames(tab_7446) <- c("Estrato", "Rendimento")

cv_7446 <- rme_responsavel[, -2]
colnames(cv_7446) <- c("Estrato", "cv")

# ---------------------------------------------------------------------
# Formatar tabelas

objetos <- ls(pattern = "_7")

for (obj in objetos) {
	df <- get(obj)
	df[[1]] <- estratos_geo
	assign(obj, df)
}

# passar cv's para %
for (obj in ls(pattern = "cv_7")) {
	df <- get(obj)
	df[, -1] <- round(df[, -1] * 100, 1)
	assign(obj, df)
}

tab_7453[, 2] <- round(tab_7453[, 2], 3)          # índice de gini
tab_7453[, 3] <- round(tab_7453[, 3] * 100, 1)    # cv

objetos <- setdiff(objetos, c("tab_7453", "tab_7446"))

# ---------------------------------------------------------------------
# Salvar arquivos 

for (obj in ls(pattern = "^(cv|tab)_7")) {
	write.csv2(
		get(obj), paste0("saida/RMe/", obj, ".csv"),
		row.names = FALSE
	)
}
