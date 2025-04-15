############### RASCUNHO ##################
# comparar valores estimados para MG na sessão do R com aqueles disponíveis 
# nas tabelas da plataforma SIDRA

# listar, instalar e carregar pacotes
pacotes <- c("sidrar", "PNADcIBGE", "survey")
install.packages(setdiff(pacotes, rownames(installed.packages())))
lapply(pacotes, library, character.only = TRUE)

# carregar script com objeto e funções
source("utilitarios.R")

# evitar notação científica e mostrar até dois dígitos significativos no console
options(scipen = 999, digits = 2)

# variaveis <- c("V2009", "VD4002", "VD4019", "VD4020", "VD4048", "V1023",
# "V2010", "VD3004", "V2007", "V2005")

if (file.exists("desenho_pop.RDS")) {
	desenho <- readRDS("desenho_pop.RDS")
} else {
	desenho <- gerar_desenho(tabelas_ocupada)
}

# População ocupada por categoria --------------------------------

# testar se os NA's estão nas mesmas linhas dessas duas colunas
all(
	is.na(desenho$variables$VD4019.Real1) ==
	is.na(desenho$variables$VD4020.Real1)
)

# adicionar coluna com as pessoas de 14 anos ou mais, ocupadas
# e com rendimento de trabalho
desenho$variables <- transform(
	desenho$variables,
	Pessoa.Ocupada = ifelse(VD4019 > 0, 1, 0)
)

# 7431 --> V2010, cor e raça;
# obter informações sobre a tabela do SIDRA
info_sidra(7431)

# importar tabela sidra com a 1a variável, todas as categorias e as UF's:
# PA, BA, MG, GO
sidra_7431 <- get_sidra(
	x = 7431, variable = 10765, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7431)

# estimar população ocupada com rendimento por raça/cor
ocupada_cor <- estimar_totais(
	desenho = subset(desenho, Pessoa.Ocupada == 1),
	formula = ~V2010
)
ocupada_cor$Total <- rowSums(ocupada_cor[2:7])

# comparar estimativa com os valores publicados no SIDRA
View(ocupada_cor)
View(sidra_7431[c(4,7,3)])

# reformatar tabela para facilitar a visualização
tab_7431 <- ocupada_cor[, c(1, 2:7, 14)]
cv_7431  <- ocupada_cor[, c(1, 8:13)]
cv_7431[, -1] <- round(cv_7431[, -1] * 100, 1)

# salvar tabela em formato CSV
write.csv(tab_7431, "tabelas/tab_7431.csv")
write.csv(cv_7431, "tabelas/cv_7431.csv")

# 7432 --> grupos de idade;
# obter informações sobre a tabela do SIDRA
info_sidra(7432)

# importar tabela sidra com a 1a variável, todas as categorias e as UF's
# PA, BA, MG, GO
sidra_7432 <- get_sidra(
	x = 7432, variable = 10765, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7432)

# adicionar coluna com os grupos de idade
desenho$variables <- transform(
	desenho$variables,
	Grupos.de.Idade = add_grupos_idade(V2009)
)

# estimar população ocupada com rendimento por grupo de idade
ocupada_idade <- estimar_totais(desenho, ~Pessoa.Ocupada, ~Grupos.de.Idade)

# comparar estimativa com os valores publicados no SIDRA
View(sidra_7432[c(4,7,3)])
View(ocupada_idade)

# reformatar tabela para facilitar a visualização
tab_7432 <- reshape_wide(ocupada_idade[-4])
cv_7432 <- reshape_wide(ocupada_idade[-3])

# salvar tabela em formato CSV
write.csv(tab_7432, "tabelas/tab_7432.csv")
write.csv(cv_7432, "tabelas/cv_7432.csv")

# 7433 --> VD3004, instrução;
# obter informações sobre a tabela do SIDRA
info_sidra(7433)

# importar tabela sidra com a 1a variável, todas as categorias e as UF's
# PA, BA, MG, GO
sidra_7433 <- get_sidra(
	x = 7433, variable = 10765, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7433)

# estimar população ocupada com rendimento por nível de instrução
ocupada_instrucao <- estimar_totais(desenho, ~Pessoa.Ocupada, ~VD3004)

# comparar estimativa com os valores publicados no SIDRA
View(sidra_7433[c(4,7,3)])
View(ocupada_instrucao)

# reformatar tabela para facilitar a visualização
tab_7433 <- reshape_wide(ocupada_instrucao[-4])
cv_7433 <- reshape_wide(ocupada_instrucao[-3])

# salvar tabela em formato CSV
write.csv(tab_7433, "tabelas/tab_7433.csv")
write.csv(cv_7433, "tabelas/cv_7433.csv")

# 7434 --> V2007, sexo;
# obter informações sobre a tabela do SIDRA
info_sidra(7434)

# importar tabela sidra com a 1a variável, todas as categorias e as UF's
# PA, BA, MG, GO
sidra_7434 <- get_sidra(
	x = 7434, variable = 10765, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7434)

# estimar população ocupada com rendimento por sexo
ocupada_sexo <- estimar_totais(desenho, ~Pessoa.Ocupada, ~V2007)

# comparar estimativa com os valores publicados no SIDRA
print(sidra_7434[c(4,7,3)])
unnames(ocupada_sexo)

# reformatar tabela para facilitar a visualização
tab_7434 <- reshape_wide(ocupada_sexo[-4])
cv_7434 <- reshape_wide(ocupada_sexo[-3])

# salvar tabela em formato CSV
write.csv(tab_7434, "tabelas/tab_7434.csv")
write.csv(cv_7434, "tabelas/cv_7434.csv")

# 7439 --> V2005, responsáveis;
# obter informações sobre a tabela do SIDRA
info_sidra(7439)

# importar tabela sidra com a 1a variável, todas as categorias e as UF's
# PA, BA, MG, GO
sidra_7439 <- get_sidra(
	x = 7439, variable = 10770, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7439)

# estimar população ocupada com rendimento e responsável pelo domicílio
ocupada_responsavel <- estimar_totais(
	subset(desenho, V2005 == "Pessoa responsável pelo domicílio"),
	~Pessoa.Ocupada
)

# comparar estimativa com os valores publicados no SIDRA
print(sidra_7439[c(4,3)])
ocupada_responsavel

# reformatar tabela para facilitar a visualização
tab_7439 <- reshape_wide(ocupada_responsavel[-4])
cv_7439 <- reshape_wide(ocupada_responsavel[-3])

# salvar tabela em formato CSV
write.csv(tab_7439, "tabelas/tab_7439.csv")
write.csv(cv_7439, "tabelas/cv_7439.csv")

# 7440 --> V1023, área;
# obter informações sobre a tabela do SIDRA
info_sidra(7440)

# importar tabela sidra com a 1a variável, todas as categorias e as UF's
# PA, BA, MG, GO
sidra_7440 <- get_sidra(
	x = 7440, variable = 10765, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7440)

# estimar população ocupada com rendimento por tipo de área geográfica
ocupada_area <- estimar_totais(desenho, ~Pessoa.Ocupada, ~V1023)
levels(ocupada_area$V1023) <- areas_geograficas

# comparar estimativa com os valores publicados no SIDRA
View(sidra_7440[c(4,7,3)])
View(ocupada_area)

# reformatar tabela para facilitar a visualização
tab_7440 <- reshape_wide(ocupada_area[-4])
cv_7440 <- reshape_wide(ocupada_area[-3])

# salvar tabela em formato CSV
write.csv(tab_7440, "tabelas/tab_7440.csv")
write.csv(cv_7440, "tabelas/cv_7440.csv")

# 7436 --> populacao residente
# obter informações sobre a tabela do SIDRA
info_sidra(7436)

# importar tabela sidra com a 1a variável, todas as categorias e as UF's
# PA, BA, MG, GO
sidra_7436 <- get_sidra(
	x = 7436, variable = 606, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7436)

# estimar população residente por UF
ocupada_total <- svytotal(~UF, subset(desenho, VD4019 > 0), na.rm = TRUE)

# comparar estimativa com os valores publicados no SIDRA
print(sidra_7436[c(4,3)])
print(ocupada_total)

tab_7436 <- data.frame(
	UF = unidades_federativas,
	Populacao.Residente = ocupada_total[[1]],
	cv = cv(ocupada_total)
)

# salvar tabela em formato CSV
write.csv(tab_7436, "tabelas/tab_7436.csv")

# 7537 --> csp
info_sidra(7537)
sidra_7537 <- get_sidra(
	x = 7537, variable = 10844, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7537)

# deflacionar
desenho$variables <- transform(
	desenho$variables,
	VD4019.Real = VD4019 * CO1,
	VD4020.Real = VD4020 * CO1e
)

# limites
limites_vd4019real <- estimar_quantis(
	desenho,
	formula = ~VD4019.Real
)
limites_vd4020real <- estimar_quantis(
	desenho,
	~VD4020.Real
)
limites_vd4020real[1, 2] <- 0.0001    # P5 estimado é 0

# adicionar coluna com as classes simples
desenho$variables <- transform(
	desenho$variables,
	VD4019.Classe = ad_classes_simples(
		renda = VD4019.Real,
		geo = UF,
		quantis = limites_vd4019real
	),
	VD4020.Classe = ad_classes_simples(
		VD4020.Real,
		UF,
		limites_vd4020real
	)
)

ocupada_csp_h <- estimar_totais(desenho, ~VD4019.Classe)

View(sidra_7537[c(4,7,3)])
View(ocupada_csp_h)

# 7547 --> 7537, CO1e
ocupada_csp_e <- estimar_totais(desenho, ~VD4020.Classe)

# 7541 --> 7537, CO2

# 7551 --> 7541, CO2e

# 7559 --> CAP, CO1e
sidra_7559 <- get_sidra(
	x = 7559, variable = 10844, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7559)

ocupada_cap_e <- vector("list", 13)
ocupada_cap_e[[1]] <- ocupada_csp_e[, c(2, 15)]     # Até P5

for (i in 2:13) {
	sub_desenho <- subset(
		desenho,
		VD4020.Classe %in% classes_simples[1:i]
	)
    estimativa <- svytotal(~UF, sub_desenho, na.rm = TRUE)
    ocupada_cap_e[[i]] <- cbind(estimativa, cv(estimativa))
    colnames(ocupada_cap_e[[i]]) <- c(classes_acumuladas[i], "cv")
}
rm(sub_desenho, estimativa)

View(sidra_7559[c(4,7,3)])
View(ocupada_cap_e)

tab_7559 <- data.frame(
	unidades_federativas,
	do.call(cbind, lapply(ocupada_cap_e, function(x) x[, 1]))
)
colnames(tab_7559) <- c("UF", classes_acumuladas)

cv_7559 <- data.frame(
	unidades_federativas,
	do.call(cbind, lapply(ocupada_cap_e, function(x) x[, 2]))
)
colnames(cv_7559) <- c("UF", classes_acumuladas)
cv_7559[, -1] <- round(cv_7559[, -1] * 100, 1)

# 7560 --> 7559, CO2e

# 7562 --> 7559, CO1
sidra_7562 <- get_sidra(
	x = 7562, variable = 10844, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7562)

ocupada_cap_h <- vector("list", 13)
ocupada_cap_h[[1]] <- ocupada_csp_h[, c(2, 15)]     # Até P5

for (i in 2:13) {
	sub_desenho <- subset(
		desenho,
		VD4019.Classe %in% classes_simples[1:i]
	)
    estimativa <- svytotal(~UF, sub_desenho, na.rm = TRUE)
    ocupada_cap_h[[i]] <- cbind(estimativa, cv(estimativa))
    colnames(ocupada_cap_h[[i]]) <- c(classes_acumuladas[i], "cv")
}
rm(sub_desenho, estimativa)

View(sidra_7562[c(4,7,3)])
View(ocupada_cap_h)

tab_7562 <- data.frame(
	unidades_federativas,
	do.call(cbind, lapply(ocupada_cap_h, function(x) x[, 1]))
)
colnames(tab_7562) <- c("UF", classes_acumuladas)

cv_7562 <- data.frame(
	unidades_federativas,
	do.call(cbind, lapply(ocupada_cap_h, function(x) x[, 2]))
)
colnames(cv_7562) <- c("UF", classes_acumuladas)
cv_7562[, -1] <- round(cv_7562[, -1] * 100, 1)

# 7563 --> 7562, CO2
