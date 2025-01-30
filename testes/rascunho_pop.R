############### RASCUNHO ##################
# comparar valores estimados para MG na sessão do R com aqueles disponíveis 
# nas tabelas da plataforma SIDRA

pacotes <- c("sidrar", "PNADcIBGE", "survey", "microbenchmark")
lapply(pacotes, library, character.only = TRUE
)
source("testes/utilitarios.R")
options(scipen = 999)

# variaveis <- c("V2009", "VD4002", "VD4019", "VD4020", "VD4048", "V1023",
# "V2010", "VD3004", "V2007", "V2005")

if (file.exists("desenho_pop.RDS")) {
	desenho <- readRDS("desenho_pop.RDS")
} else {
	desenho <- gerar_desenho(tabelas_pop)
}

# Pessoas ocupadas por categorias --------------------------------

# testar se os NA's estão nas mesmas linhas dessas duas colunas
all(
	is.na(desenho$variables$VD4019.Real1) ==
	is.na(desenho$variables$VD4020.Real1)
)

desenho$variables <- transform(
	desenho$variables,
	Ocupadas.com.Rendimento = ifelse(
		V2009 >= 14 & VD4002 == "Pessoas ocupadas" & !is.na(VD4019),
		1, NA
	)
)

# 7431 --> V2010, cor e raça;
sidra_7431 <- get_sidra(
	x = 7431, variable = 10765, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7431)

pop_cor <- svyby(
	~Ocupadas.com.Rendimento,
	~V2010 + UF,
	desenho,
	FUN = svytotal,
	vartype = "cv",
	keep.names = FALSE,
	drop.empty.groups = FALSE,
	na.rm = TRUE
)

tab_7431 <- reformatar_cor(pop_cor)

View(pop_cor)
View(sidra_7431[c(4,7,3)])

write.csv(tab_7431, "tab_7431.csv")

# 7432 --> grupos de idade;
sidra_7432 <- get_sidra(
	x = 7432, variable = 10765, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7432)

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

pop_idade <- svyby(
	~Ocupadas.com.Rendimento,
	~Grupos.de.Idade + UF,
	desenho,
	FUN = svytotal,
	vartype = "cv",
	keep.names = FALSE,
	drop.empty.groups = FALSE,
	na.rm = TRUE
)

pop_idade <- data.frame(
	Grupos.Idade = grupos_idade,
	Pará = pop_idade[1:8, 3],
	Bahia = pop_idade[9:16, 3],
	Minas.Gerais = pop_idade[17:24, 3],
	Goiás = pop_idade[25:32, 3]
)

write.csv(pop_idade, "tab_7432.csv")

View(sidra_7432[c(4,7,3)])
View(pop_idade)

# 7433 --> VD3004, instrução;
sidra_7433 <- get_sidra(
	x = 7433, variable = 10765, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7433)

pop_instrucao <- svyby(
	~Ocupadas.com.Rendimento,
	~VD3004 + UF,
	desenho,
	FUN = svytotal,
	vartype = "cv",
	keep.names = FALSE,
	drop.empty.groups = FALSE,
	na.rm = TRUE
)

pop_instrucao <- data.frame(
	Nível.de.Instrução = levels(desenho$variables$VD3004),
	Pará = pop_instrucao[1:7, 3],
	Bahia = pop_instrucao[8:14, 3],
	Minas.Gerais = pop_instrucao[15:21, 3],
	Goiás = pop_instrucao[22:28, 3]
)

write.csv(pop_instrucao, "tab_7433.csv")

View(sidra_7433[c(4,7,3)])
View(pop_instrucao)

# 7434 --> V2007, sexo;
sidra_7434 <- get_sidra(
	x = 7434, variable = 10765, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7434)

pop_sexo <- svyby(
	~Ocupadas.com.Rendimento,
	~V2007 + UF,
	desenho,
	FUN = svytotal,
	vartype = "cv",
	keep.names = FALSE,
	drop.empty.groups = FALSE,
	na.rm = TRUE
)

print(sidra_7434[c(4,7,3)])
unnames(pop_sexo)

tab_7434 <- reformatar_wide(pop_sexo, "V2007")
colnames(tab_7434) <- c("UF", "Homens", "cv.Homens", "Mulheres", "cv.Mulheres")

write.csv(pop_sexo, "tab_7434.csv")

# 7439 --> V2005, responsáveis;
sidra_7439 <- get_sidra(
	x = 7439, variable = 10770, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7434)

pop_responsaveis <- svyby(
	~Ocupadas.com.Rendimento,
	~UF,
	subset(
		desenho,
		V2005 == "Pessoa responsável pelo domicílio"
	),
	FUN = svytotal,
	vartype = "cv",
	keep.names = FALSE,
	drop.empty.groups = FALSE,
	na.rm = TRUE
)
colnames(pop_responsaveis) <- c("UF", "Pessoas", "cv")

print(sidra_7439[c(4,3)])
pop_responsaveis

write.csv(pop_responsaveis, "tab_7439.csv")

# 7440 --> V1023, área;
sidra_7440 <- get_sidra(
	x = 7440, variable = 10765, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7434)

pop_area <- svyby(
	~Ocupadas.com.Rendimento,
	~V1023 + UF,
	desenho,
	FUN = svytotal,
	vartype = "cv",
	keep.names = FALSE,
	drop.empty.groups = FALSE,
	na.rm = TRUE
)

View(sidra_7440[c(4,7,3)])
View(pop_area)

tab_7437 <- reformatar_pop2(pop_area)
colnames(tab_7437) <- c(
	"UF",
	"Capital",
	"Regiao.Metropolitana",
	"RIDE",
	"Resto.da.UF"
)
write.csv(tab_7437, "tab_7437.csv")

# 7436 --> populacao residente
sidra_7436 <- get_sidra(
	x = 7436, variable = 606, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7436)

pop_total <- svytotal(~UF, desenho)

print(sidra_7436[c(4,3)])
print(pop_total)

tab_7436 <- data.frame(
	UF = unidades_federativas,
	Populacao.Residente = pop_total[[1]],
	cv = cv(pop_total)
)
colnames(tab_7436) <- c("UF", "Populacao.Residente", "cv")
write.csv(tab_7436, "tab_7436.csv")
