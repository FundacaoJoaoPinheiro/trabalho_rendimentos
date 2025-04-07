# Reproduzir tabelas SIDRA para os dez estratos geográficos de Minas Gerais.
# Tabelas referentes ao rendimento domiciliar per capita, a preços médios do ano:
# 7428, 7435, 7438, 7521, 7531, 7532 e 7561.

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
limites_vd5008real <- estimar_quantis(desenho, formula = ~VD5008.Real)
colnames(limites_vd5008real) <- c("Estrato", percentis)

# adiciona coluna com as classes simples de percentual por estrato geográfico
desenho$variables <- transform(
	desenho$variables,
	VD5008.Classes = ad_classes_simples(     # função definida em utilitarios.R
		renda = VD5008.Real,
		geo = Estrato.Geo,
		limites = limites_vd5008real
	)
)

# ---------------------------------------------------------------------
# Gerar tabelas de valores e CV's

# Tabela 7428 - Massa de rendimento domiciliar per capita (RDPC) por
# classe simples de percentual (CSP) e estrato geográfico
# função definida em utilitarios.R, estima totais por estrato geográfico
massa_vd5008real <- estimar_totais(
	desenho = subset(desenho, V2005.Rendimento == 1),
	formula = ~VD5008.Real,
	por = ~VD5008.Classes
)

tab_7428 <- reshape_wide(massa_vd5008real[, -4])
cv_7428  <- reshape_wide(massa_vd5008real[, -3])

# Tabela 7438 - limites superiores por estrato geográfico
tab_7438 <- limites_vd5008real[, c(1, 2:13)]
cv_7438  <- limites_vd5008real[, c(1, 14:25)]

# Tabela 7521 - População por classe simples de percentual (CSP)
pop_vd5008classes <- estimar_totais(
	subset(desenho, V2005.Rendimento == 1),
	~VD5008.Classes
)

tab_7521 <- pop_vd5008classes[, c(1, 2:14)]
colnames(tab_7521) <- c("Estrato", classes_simples)
cv_7521  <- pop_vd5008classes[, c(1, 15:27)]
colnames(cv_7521) <- c("Estrato", classes_simples)

# Tabela 7531 - RMe real domiciliar per capita, por classe simples
rme_vd5008classe <- estimar_medias(
	subset(desenho, V2005.Rendimento == 1),
	~VD5008.Real,
	~VD5008.Classes
)

tab_7531 <- reshape_wide(rme_vd5008classe[, -4])
cv_7531  <- reshape_wide(rme_vd5008classe[, -3])

# Tabela 7532 - RMe real domiciliar per capita, por classe acumulada
rme_vd5008cap <- estimar_cap(
	subset(desenho, V2005.Rendimento == 1),
	formula = ~VD5008.Real,
	csp = "VD5008.Classes"
)

tab_7532 <- rme_vd5008cap[[1]]
cv_7532  <- rme_vd5008cap[[2]]

# Tabela 7561 - População por classe acumulada
cap_list <-  vector("list", 13)

for (i in 1:13) {
    sub_desenho <- subset(
    	desenho,
    	V2005.Rendimento == 1 & VD5008.Classes %in% classes_simples[1:i]
	)
    cap_list[[i]] <- svytotal(~Estrato.Geo, sub_desenho, na.rm = T)
}

tab_7561 <- data.frame(
	estratos_geo,
	do.call(cbind, lapply(cap_list, `[`, 1:10))
)
colnames(tab_7561) <- c("Estrato", classes_acumuladas)

cv_7561 <- data.frame(
	estratos_geo,
	do.call(cbind, lapply(cap_list, cv))
)
colnames(cv_7561) <- c("Estrato", classes_acumuladas)

# Tabela 7435 - valores próximos, iguais arredondando
gini_vd5008real <- svyby(
	~VD5008.Real,
	~Estrato.Geo,
	subset(desenho, V2005.Rendimento == 1),
	FUN = svygini,
	keep.names = FALSE,	
	vartype = "cv",
	na.rm = TRUE
)

tab_7435 <- gini_vd5008real
colnames(tab_7435) <- c("Estrato", "Valor", "cv")
cv_7435 <- gini_vd5008real[, -2]
colnames(cv_7435) <- c("Estrato", "cv")

# ---------------------------------------------------------------------
# Finalizar tabelas

for (obj in ls(pattern = "_7")) {
	df <- get(obj)
	df[[1]] <- estratos_geo
	assign(obj, df)
}

for (obj in ls(pattern = "tab_7..[^5]$")) {
	df <- get(obj)
	df[, -1] <- round(df[, -1], 2)
	assign(obj, df)
}

# passar cv's para %
for (obj in ls(pattern = "cv_7")) {
	df <- get(obj)
	df[, -1] <- round(df[, -1] * 100, 1)
	assign(obj, df)
}

tab_7435[, 2] <- round(tab_7435[, 2], 3)          # índice de gini
tab_7435[, 3] <- round(tab_7435[, 3] * 100, 1)    # cv's

# passar populações para "mil pessoas"
tab_7521[, -1] <- round(tab_7521[, -1] / 1000)
tab_7561[, -1] <- round(tab_7561[, -1] / 1000)

# ---------------------------------------------------------------------
# Salvar arquivos 

for (obj in ls(pattern = "^(cv|tab)_7")) {
	write.csv2(
		get(obj), paste0("saida/RDPC/", obj, ".csv"),
		row.names = FALSE
	)
}
