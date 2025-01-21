############### RASCUNHO ##################
# comparar valores estimados para MG na sessão do R com aqueles disponíveis 
# nas tabelas da plataforma SIDRA

pacotes <- c("sidrar", "PNADcIBGE", "survey", "convey")
lapply(pacotes, library, character.only = TRUE)
source("testes/utilitarios.R")
options(scipen = 999)

variaveis <- c("V2009", "VD4002", "VD4052", "V2010", "VD3004", "V2007", "V2005")

if (file.exists("desenho_pessoas.RDS")) {
	desenho <- readRDS("desenho_pessoas.RDS")
} else {
	desenho <- gerar_DA(variaveis)
}

# Pessoas por categorias -------------------------------------------

# Pessoas de 14 anos ou mais de idade ocupadas por categoria
# --> V2009, VD4002, VD4052

# 7431 --> V2010; cor/raça -----------------------------------
sidra_7431 <- get_sidra(x = 7431, variable = 10765, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2)

desenho$variables <- transform(
	desenho$variables,
	Ocupadas.com.Rendimento = ifelse(
		V2009 >= 14 & VD4002 == "Pessoas ocupadas" & !is.na(VD4052),
		1, NA
	)
)

ocupadas_cor <- svyby(
	~Ocupadas.com.Rendimento,
	~V2010 + UF,
	desenho,
	FUN = svytotal,
	vartype = "cv",
	keep.names = FALSE,
	na.rm = TRUE)
	
View(ocupadas_cor)
View(sidra_7431[c(4,7,3)])

# 7432 --> V2009; grupos de idade -------------------------
sidra_7432 <- get_sidra(x = 7432, variable = 10765, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2)

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

ocupadas_idade <- svyby(
	~Ocupadas.com.Rendimento,
	~Grupos.de.Idade + UF,
	desenho,
	FUN = svytotal,
	vartype = "cv",
	keep.names = FALSE,
	na.rm = TRUE)
	
View(ocupadas_idade)
View(sidra_7432[c(4,7,3)])

# 7433 --> VD3004; instrução -------------------------
sidra_7433 <- get_sidra(x = 7433, variable = 10765, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2)

ocupadas_instrucao <- svyby(
	~Ocupadas.com.Rendimento,
	~VD3004 + UF,
	desenho,
	FUN = svytotal,
	vartype = "cv",
	keep.names = FALSE,
	na.rm = TRUE)
	
View(ocupadas_instrucao)
View(sidra_7433[c(4,7,3)])

# 7434 --> V2007; sexo --------------------------------
sidra_7434 <- get_sidra(x = 7434, variable = 10765, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2)

ocupadas_sexo <- svyby(
	~Ocupadas.com.Rendimento,
	~V2007 + UF,
	desenho,
	FUN = svytotal,
	vartype = "cv",
	keep.names = FALSE,
	na.rm = TRUE)
	
View(ocupadas_sexo)
View(sidra_7434[c(4,7,3)])

# 7439 --> V2005, responsáveis;

# 7440 --> V1023, área;

