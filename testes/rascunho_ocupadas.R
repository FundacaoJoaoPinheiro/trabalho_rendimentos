############### RASCUNHO ##################
# comparar valores estimados para MG na sessão do R com aqueles disponíveis 
# nas tabelas da plataforma SIDRA

pacotes <- c("sidrar", "PNADcIBGE", "survey")
lapply(pacotes, library, character.only = TRUE)
options(scipen = 999)

variaveis <- c("V2009", "VD4002", "VD4052", "V4034", "V2010", "VD3004", "V2007")

pnadc_ano = 2023
visita = 1

if (file.exists("desenho_ocupadas.RDS")) {
	desenho_amostral <- readRDS("desenho_ocupadas.RDS")
} else {
	microdados <- "Microdados/PNADC_2023_visita1.txt"
	input <- "Microdados/input_PNADC_2023_visita1_20241220.txt"
	dict <- "Microdados/dicionario_PNADC_microdados_2023_visita1_20241220.xls"
	deflator <- "Microdados/deflator_PNADC_2023.xls"
	desenho_amostral <- pnadc_deflator(
		pnadc_labeller(
			data_pnadc = read_pnadc(
				microdata = microdados,
				input = input,
				vars = c(variaveis, "UF", "V2009")  # sempre importar UF e Idade
			),
			dictionary.file = dict
		),
		deflator.file = deflator
	)
	desenho_amostral <- pnadc_design(
		subset(desenho_amostral, UF == "Minas Gerais")
	)
}
desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	Estrato_G = factor(substr(Estrato, 1, 4))
)

# 7431, 7432, 7433 e 7434 -------------------------------------
# Pessoas de 14 anos ou mais de idade ocupadas por categoria --> V2009, VD4002,
# VD4052

# 7431 --> V2010 --------------------------
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

# 7432 --> V2009 --------------------------
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

# 7433 --> VD3004 -------------------------
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

# 7434 --> V2007 -------------------------
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

