############### RASCUNHO ##################
# comparar valores estimados para MG na sessão do R com aqueles disponíveis 
# nas tabelas da plataforma SIDRA

pacotes <- c("sidrar", "PNADcIBGE", "survey", "convey")
lapply(pacotes, library, character.only = TRUE)
source("testes/utilitarios.R")
options(scipen = 999)

variaveis <- c("V2009", "VD4002", "VD4052", "V2010", "VD3004", "V2007", "V2005")

if (file.exists("desenho_pessoas.RDS")) {
	desenho_amostral <- readRDS("desenho_pessoas.RDS")
} else {
	desenho_amostral <- gerar_DA(variaveis)
}

# Pessoas por categorias -------------------------------------------

# 7440 --> V1023, área;

# 7543 --> VD4019 * CO1, classe simples; Resultados muito parecidos
sidra_7543 <- get_sidra(
	x = 7543, variable = 10848, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7543)

# Pessoas de 14 anos ou mais de idade ocupadas por categoria
# --> V2009, VD4002 VD4052

# 7431 --> V2010; cor/raça --------------------------
sidra_7431 <- get_sidra(x = 7431, variable = 10765, period = "2023",
	geo = "State", geo.filter = 31, header = TRUE, format = 2)

desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	Ocupadas.com.Rendimento = ifelse(
		V2009 >= 14 & VD4002 == "Pessoas ocupadas" & !is.na(VD4052),
		1, NA
	)
)

ocupadas_cor <- svyby(
	~Ocupadas.com.Rendimento,
	~V2010 + Estrato_G,
	desenho_amostral,
	FUN = svytotal,
	vartype = "cv",
	na.rm = TRUE)
	
print(ocupadas_cor)
unname(sidra_7431[c(7,3)])

# 7432 --> V2009; grupos de idade --------------------------
sidra_7432 <- get_sidra(x = 7432, variable = 10765, period = "2023",
	geo = "State", geo.filter = 31, header = TRUE, format = 2)

desenho_amostral$variables <- transform(
	desenho_amostral$variables,
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
	~Grupos.de.Idade + Estrato_G,
	desenho_amostral,
	FUN = svytotal,
	vartype = "cv",
	na.rm = TRUE)
	
print(ocupadas_idade)
unname(sidra_7432[c(7,3)])

# 7433 --> VD3004; instrução -------------------------
sidra_7433 <- get_sidra(x = 7433, variable = 10765, period = "2023",
	geo = "State", geo.filter = 31, header = TRUE, format = 2)

ocupadas_instrucao <- svyby(
	~Ocupadas.com.Rendimento,
	~VD3004 + Estrato_G,
	desenho_amostral,
	FUN = svytotal,
	vartype = "cv",
	na.rm = TRUE)
	
print(ocupadas_instrucao)
unname(sidra_7433[c(7,3)])

# 7434 --> V2007; sexo -------------------------
sidra_7434 <- get_sidra(x = 7434, variable = 10765, period = "2023",
	geo = "State", geo.filter = 31, header = TRUE, format = 2)

ocupadas_sexo <- svyby(
	~Ocupadas.com.Rendimento,
	~V2007 + Estrato_G,
	desenho_amostral,
	FUN = svytotal,
	vartype = "cv",
	na.rm = TRUE)
	
print(ocupadas_sexo)
unname(sidra_7434[c(7,3)])

