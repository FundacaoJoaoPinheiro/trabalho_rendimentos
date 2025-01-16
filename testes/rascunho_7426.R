# comparar valores estimados para MG na sessão do R com aqueles disponíveis 
# nas tabelas da plataforma SIDRA

pacotes <- c("sidrar", "PNADcIBGE", "survey")
lapply(pacotes, library, character.only = TRUE)
options(scipen = 999)

variaveis <- c("V5001A", "V5002A", "V5003A", "V5004A", "V5005A", "V5006A")

pnadc_ano = 2023
visita = 1
pnadc_dir = "Microdados"

if (file.exists("desenho_7426.RDS")) {
	desenho_amostral <- readRDS("desenho_amostral.RDS")
} else {
	microdados <- list.files(
		pnadc_dir,
		paste0("^PNADC_", pnadc_ano, "_visita", visita, ".*txt$"),
		full.names = TRUE
	)
	input <- list.files(
		pnadc_dir,
		paste0("^input_PNADC_", pnadc_ano, "_visita", visita, ".*txt$"),
		full.names = TRUE
	)
	dicionario <- list.files(
		pnadc_dir,
		paste0("^dicionario_PNADC_microdados_", pnadc_ano,
			"_visita", visita, ".*xls$"),
		full.names = TRUE
	)
	deflator <- file.path(
		pnadc_dir,
		paste0("deflator_PNADC_", pnadc_ano, ".xls")
	)
	desenho_amostral <- pnadc_deflator(
		pnadc_labeller(
			data_pnadc = read_pnadc(
				microdata = microdados,
				input = input,
				vars = c(variaveis, "UF", "V2009")  # sempre importar UF e Idade
			),
			dictionary.file = dicionario
		),
		deflator.file = deflator
	)
	desenho_amostral <- pnadc_design(
		subset(desenho_amostral, UF == "Minas Gerais")
	)
}

# 1) 7426 ------------------------------------------------

sidra_7426 <- get_sidra(x = 7426, variable = 10486, period = "2023", geo = "State",
	geo.filter = 31, header = TRUE, format = 2)
sidra_7426 <- transform(sidra_7426, Valor = Valor * 1000)

# Rendimentos Habitual e Efetivo (V, ?)
svytotal(~is.na(VD4019) + is.na(VD4020), subset(desenho_amostral, V2009 >= 14))
sidra_7426[c(7,3)]

# Aposentadoria..., aluguel..., pensão... (V,V,V)
svytotal(~V5004A + V5007A + V5006A, desenho_amostral)

# Outros rendimentos (V)
desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	Outros_Rendimentos = factor(
		ifelse(
			V5001A == "Sim" | V5002A == "Sim" | V5003A == "Sim" |
			V5005A == "Sim" | V5008A == "Sim",
			"Sim", "Não"
		)
	)
)

svytotal(~Outros_Rendimentos, desenho_amostral)
sidra_7426[c(7,3)]

# Todas as fontes e Outras fontes (V,V)
svytotal(~is.na(VD4052) + is.na(VD4048), desenho_amostral)

## para não importar as variáveis VD4052 e VD4048:

desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	Outras_Fontes = factor(
		ifelse(
			V5004A == "Sim" | V5007A == "Sim" | V5006A == "Sim" |
			Outros_Rendimentos == "Sim",
			"Sim", "Não"
		)
	)
)

desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	Todas_as_Fontes = factor(
		ifelse(
			!is.na(VD4019) | Outras_Fontes == "Sim",
			"Sim", "Não"
		)
	)
)

