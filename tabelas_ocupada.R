# Reproduz tabelas SIDRA para os dez estratos geográficos de Minas Gerais.
# Tabelas referentes à população ocupada com rendimento: 7431, 7432, 7433,
# 7434, 7436, 7439, 7537, 7541, 7546, 7547, 7559, 7562. 

# ---------------------------------------------------------------------
# Preparar ambiente

pacotes <- c("PNADcIBGE", "survey")
#install.packages(setdiff(pacotes, rownames(installed.packages())))
lapply(pacotes, library, character.only = TRUE)

# carregar objetos e funções utilizados no script:
# gerar_desenho(); ad_grupos_idade(); estimar_totais(); reshape_wide();
# `tabelas_ocupada`; `areas_geograficas`
source("utilitarios.R")

# ---------------------------------------------------------------------
# Preparar os df

desenho <- gerar_desenho(tabelas_ocupada)

desenho$variables <- transform(
	desenho$variables,
	Pessoa.Ocupada = ifelse(VD4019 > 0, 1, 0)
)

desenho$variables <- transform(
	desenho$variables,
	Grupo.de.Idade = ad_grupos_idade(idade = V2009)
)

desenho$variables <- transform(
	desenho$variables,
	VD4019.Real = VD4019 * CO1,
	VD4020.Real = VD4020 * CO1e
)

# tabela 7536
limites_vd4019real <- estimar_quantis(desenho, formula = ~VD4019.Real)
colnames(limites_vd4019real) <- c("Estrato", percentis)

# tabela 7546
limites_vd4020real <- estimar_quantis(desenho, formula = ~VD4020.Real)
colnames(limites_vd4020real) <- c("Estrato", percentis)

desenho$variables <- transform(
	desenho$variables,
	VD4019.Classe = ad_classes_simples(
		renda = VD4019.Real,
		geo = Estrato.Geo,
		limites = limites_vd4019real
	),
	VD4020.Classe = ad_classes_simples(
		renda = VD4019.Real,
		geo = Estrato.Geo,
		limites = limites_vd4019real
	)
)

# ---------------------------------------------------------------------
# Reproduzir tabelas

# Tabela 7431 - população ocupada por cor/raça
ocupada_cor <- estimar_totais(
	desenho = subset(desenho, Pessoa.Ocupada == 1),
	formula = ~V2010
)

tab_7431 <- ocupada_cor[, c(1, 2, 3, 5)]
cv_7431  <- ocupada_cor[, c(1, 8, 9, 11)]

colnames(tab_7431) <- c("Estrato", "Branca", "Preta", "Parda")
colnames(cv_7431)  <- c("Estrato", "Branca", "Preta", "Parda")

# Tabela 7432 - população ocupada por grupos de idade
ocupada_idade <- estimar_totais(
	subset(desenho, Pessoa.Ocupada == 1),
	~Grupo.de.Idade
)

tab_7432 <- ocupada_idade[, c(1, 2:9)]
cv_7432  <- ocupada_idade[, c(1, 10:17)]

colnames(tab_7432) <- c("Estrato", levels(desenho$variables$Grupo.de.Idade))
colnames(cv_7432)  <- c("Estrato", levels(desenho$variables$Grupo.de.Idade))

# Tabela 7433 - população ocupada por VD3004, instrução;
ocupada_instrucao <- estimar_totais(
	subset(desenho, Pessoa.Ocupada == 1),
	~VD3004
)
levels(ocupada_instrucao) <- niveis_instrucao

tab_7433 <- ocupada_instrucao[, c(1, 2:8)]
cv_7433  <- ocupada_instrucao[, c(1, 9:15)]

colnames(tab_7433) <- c("Estrato", levels(desenho$variables$VD3004))
colnames(cv_7433)  <- c("Estrato", levels(desenho$variables$VD3004))

# Tabela 7434 - população ocupada por V2007, sexo;
ocupada_sexo <- estimar_totais(
	subset(desenho, Pessoa.Ocupada == 1),
	~V2007
)

tab_7434 <- data.frame(
	Estrato = estratos_geo,
	Homens = ocupada_sexo[[2]],
	Mulheres = ocupada_sexo[[3]]
)

cv_7434 <- data.frame(
	Estrato = estratos_geo,
	Homens = ocupada_sexo[[4]],
	Mulheres = ocupada_sexo[[5]]
)

# Tabela 7436 - População residente
populacao <- svytotal(~Estrato.Geo, desenho)

tab_7436 <- data.frame(
	Estrato = estratos_geo,
	Populacao = populacao[1:10]
)

cv_7436 <- data.frame(
	Estrato = estratos_geo,
	cv = cv(populacao)
)

# Tabela 7439 - população ocupada por V2005, responsáveis;
ocupada_responsavel <- svytotal(
	~Estrato.Geo,
	subset(
		desenho,
		V2005 == "Pessoa responsável pelo domicílio" & Pessoa.Ocupada == 1
	)
)

tab_7439 <- data.frame(
	Estrato = estratos_geo,
	Responsaveis = ocupada_responsavel[1:10]
)

cv_7439 <- data.frame(
	Estrato = estratos_geo,
	cv = cv(ocupada_responsavel)
)

# Tabela 7536 - Limites superiores do rendimento habitual, a preços médios do ano
tab_7536 <- limites_vd4019real[, c(1, 2:13)]
cv_7536  <- limites_vd4019real[, c(1, 14:25)]

# Tabela 7546 - Limites superiores do rendimento efetivo, a preços médios do ano
tab_7546 <- limites_vd4020real[, c(1, 2:13)]
cv_7546  <- limites_vd4020real[, c(1, 14:25)]

# Tabela 7537 - população ocupada por classe simples de rendimento habitual
ocupada_csp_h <- estimar_totais(desenho, ~VD4019.Classe)

tab_7537 <- ocupada_csp_h[, c(1, 2:14)]
cv_7537  <- ocupada_csp_h[, c(1, 15:27)]

colnames(tab_7537) <- c("Estrato", classes_simples)
colnames(cv_7537)  <- c("Estrato", classes_simples)

# Tabela 7547 - população ocupada por classe simples de rendimento efetivo
ocupada_csp_e <- estimar_totais(desenho, ~VD4020.Classe)
tab_7547 <- ocupada_csp_e[, c(1, 2:14)]
cv_7547  <- ocupada_csp_e[, c(1, 15:27)]

colnames(tab_7547) <- c("Estrato", classes_simples)
colnames(cv_7547)  <- c("Estrato", classes_simples)

# Tabela 7559 - população por classe acumulada de rendimento efetivo
ocupada_cap_e <- vector("list", 13)              # um item por classe acumulada
ocupada_cap_e[[1]] <- ocupada_csp_e[, c(2, 15)]  # Até P5

for (i in 2:13) {
	sub_desenho <- subset(
		desenho,
		VD4020.Classe %in% classes_simples[1:i]
	)
    estimativa <- svytotal(~Estrato.Geo, sub_desenho, na.rm = TRUE)
    ocupada_cap_e[[i]] <- cbind(estimativa, cv(estimativa))
    colnames(ocupada_cap_e[[i]]) <- c(classes_acumuladas[i], "cv")
}
rm(sub_desenho, estimativa)

tab_7559 <- data.frame(
	estratos_geo,
	do.call(cbind, lapply(ocupada_cap_e, function(x) x[, 1]))
)
colnames(tab_7559) <- c("Estrato", classes_acumuladas)

cv_7559 <- data.frame(
	estratos_geo,
	do.call(cbind, lapply(ocupada_cap_e, function(x) x[, 2]))
)
colnames(cv_7559) <- c("Estrato", classes_acumuladas)

# Tabela 7562 - população por classe acumulada de rendimento habitual
ocupada_cap_h <- vector("list", 13)
ocupada_cap_h[[1]] <- ocupada_csp_h[, c(2, 15)]

for (i in 2:13) {
	sub_desenho <- subset(
		desenho,
		VD4019.Classe %in% classes_simples[1:i]
	)
    estimativa <- svytotal(~Estrato.Geo, sub_desenho, na.rm = TRUE)
    ocupada_cap_h[[i]] <- cbind(estimativa, cv(estimativa))
    colnames(ocupada_cap_h[[i]]) <- c(classes_acumuladas[i], "cv")
}
rm(sub_desenho, estimativa)

tab_7562 <- data.frame(
	estratos_geo,
	do.call(cbind, lapply(ocupada_cap_h, function(x) x[, 1]))
)
colnames(tab_7562) <- c("Estrato", classes_acumuladas)

cv_7562 <- data.frame(
	estratos_geo,
	do.call(cbind, lapply(ocupada_cap_h, function(x) x[, 2]))
)
colnames(cv_7562) <- c("Estrato", classes_acumuladas)

# ---------------------------------------------------------------------
# Formatar tabelas

# adicionar nomes dos estratos
for (obj in ls(pattern = "_7")) {
	df <- get(obj)
	df[[1]] <- estratos_geo
	assign(obj, df)
}

# adicionar os totais em cada tabela
ocupada_total <- svytotal(~Estrato.Geo, subset(desenho, Pessoa.Ocupada == 1))

tabelas_pop <- setdiff(ls(pattern = "tab_"), c("tab_7536", "tab_7546"))
for (objt in tabelas_pop) {
	df <- get(obj)
	df$Total <- ocupada_total[1:10]
	assign(obj, df)
}

cv_pop <- setdiff(ls(pattern = "cv_"), c("cv_7536", "cv_7546"))
for (objt in cv_pop) {
	df <- get(obj)
	df$Total <- cv(ocupada_total)
	assign(obj, df)
}

# passar cv's para %
for (obj in ls(pattern = "cv_7")) {
	df <- get(obj)
	df[, -1] <- round(df[, -1] * 100, 1)
	assign(obj, df)
}

# alterar medidas para mil pessoas
for (obj in tabelas_pop) {
	df <- get(obj)
	df[, -1] <- round(df[, -1] / 1000)
	assign(obj, df)
}

# ---------------------------------------------------------------------
# Salvar arquivos 

for (obj in ls(pattern = "^(cv|tab)_7")) {
	write.csv2(
		get(obj),
		paste0("saida/ocupada/", obj, ".csv"),
		row.names = FALSE
	)
}
