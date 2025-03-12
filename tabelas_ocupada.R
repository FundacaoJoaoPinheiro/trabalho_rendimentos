# Reproduz tabelas SIDRA para os dez estratos geográficos de Minas Gerais.
# Tabelas referentes à população ocupada com rendimento: 7431, 7432, 7433,
# 7434, 7436, 7439, 7440, 7537, 7541, 7546, 7547, 7559, 7560, 7562, 7563

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
# Preparar os dados

desenho <- gerar_desenho(tabelas_ocupada)

desenho$variables <- transform(
	desenho$variables,
	Pessoa.Ocupada = ifelse(VD4019 > 0, 1, 0)
)

desenho$variables <- transform(
	desenho$variables,
	Grupos.de.Idade = ad_grupos_idade(idade = V2009)
)

desenho$variables <- transform(
	desenho$variables,
	VD4019.Real = VD4019 * CO1,
	VD4020.Real = VD4020 * CO1e
)

# tabela 7436
limites_vd4019real <- estimar_quantis(desenho, formula = ~VD4019.Real)

# tabela 7546
limites_vd4020real <- estimar_quantis(desenho, formula = ~VD4020.Real)

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

ocupada_total <- svytotal(~Estrato.Geo, subset(desenho, Pessoa.Ocupada == 1))
ocupada_total <- cbind(Total = ocupada_total, cv = cv(ocupada_total))

# ---------------------------------------------------------------------
# Reproduzir tabelas

# Tabela 7431 - população ocupada por cor/raça
ocupada_cor <- estimar_totais(
	desenho = subset(desenho, Pessoa.Ocupada == 1),
	formula = ~V2010
)
ocupada_cor$Total <- ocupada_total$Total
ocupada_cor$cv.Total <- ocupada_total$cv

tab_7431 <- ocupada_cor[, c(1, 2:7, 14)]
cv_7431  <- ocupada_cor[, c(1, 8:13)]
cv_7431[, -1] <- round(cv_7431[, -1] * 100, 1)
colnames(tab_7431) <- c("Estrato.Geo", levels(desenho$variables$V2010), "Total")
colnames(cv_7431)  <- c("Estrato.Geo", levels(desenho$variables$V2010), "Total")

# Tabela 7432 - população ocupada por grupos de idade
ocupada_idade <- estimar_totais(
	subset(desenho, Pessoa.Ocupada == 1),
	~Grupos.de.Idade
)

tab_7432 <- reshape_wide(ocupada_idade[-4])
cv_7432 <- reshape_wide(ocupada_idade[-3])
cv_7432[, -1] <- round(cv_7432[, -1] * 100, 3)

# Tabela 7433 - população ocupada por VD3004, instrução;
ocupada_instrucao <- estimar_totais(desenho, ~Pessoa.Ocupada, ~VD3004)

tab_7433 <- reshape_wide(ocupada_instrucao[-4])
cv_7433 <- reshape_wide(ocupada_instrucao[-3])
cv_7433[, -1] <- round(cv_7433[, -1] * 100, 3)

# Tabela 7434 - população ocupada por V2007, sexo;
ocupada_sexo <- estimar_totais(desenho, ~Pessoa.Ocupada, ~V2007)
tab_7434 <- reshape_wide(ocupada_sexo[-4])
cv_7434 <- reshape_wide(ocupada_sexo[-3])
cv_7434[, -1] <- round(cv_7434[, -1] * 100, 3)

# Tabela 7439 - população ocupada por V2005, responsáveis;
ocupada_responsavel <- estimar_totais(
	subset(desenho, V2005 == "Pessoa responsável pelo domicílio"),
	~Pessoa.Ocupada
)
ocupada_responsavel[, 1] <- estratos_geo

tab_7439 <- ocupada_responsavel[1:2]
cv_7439 <- ocupada_responsavel[-2]
cv_7439[, -1] <- round(cv_7439[, -1] * 100, 3)

# Tabela 7536 - Limites superiores do rendimento habitual, a preços médios do ano
tab_7536 <- limites_vd4019real[, c(1, 2:13)]
cv_7536  <- limites_vd4019real[, c(1, 14:25)]
tab_7536[[1]] <- estratos_geo
cv_7536[[1]]  <- estratos_geo
cv_7536[, -1] <- round(cv_7536[, -1] * 100, 1)

# Tabela 7537 - população ocupada por classe simples de rendimento habitual
ocupada_csp_h <- estimar_totais(desenho, ~VD4019.Classe)
ocupada_csp_h[[1]] <- estratos_geo

tab_7537 <- ocupada_csp_h[, c(1, 2:14)]
cv_7537  <- ocupada_csp_h[, c(1, 15:27)]
cv_7537[, - 1] <- round(cv_7537[, -1] * 100, 1)

# Tabela 7547 - população ocupada por classe simples de rendimento efetivo
ocupada_csp_e <- estimar_totais(desenho, ~VD4020.Classe)
ocupada_csp_e[[1]] <- estratos_geo

tab_7547 <- ocupada_csp_e[, c(1, 2:14)]
cv_7547  <- ocupada_csp_e[, c(1, 15:27)]
cv_7547[, - 1] <- round(cv_7547[, -1] * 100, 1)

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
colnames(tab_7559) <- c("Estrato.Geo", classes_acumuladas)

cv_7559 <- data.frame(
	estratos_geo,
	do.call(cbind, lapply(ocupada_cap_e, function(x) x[, 2]))
)
colnames(cv_7559) <- c("Estrato.Geo", classes_acumuladas)
cv_7559[, -1] <- round(cv_7559[, -1] * 100, 1)

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
colnames(tab_7562) <- c("Estrato.Geo", classes_acumuladas)

cv_7562 <- data.frame(
	estratos_geo,
	do.call(cbind, lapply(ocupada_cap_h, function(x) x[, 2]))
)
colnames(cv_7562) <- c("Estrato.Geo", classes_acumuladas)
cv_7562[, -1] <- round(cv_7562[, -1] * 100, 1)
