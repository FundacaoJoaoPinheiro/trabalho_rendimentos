############### RASCUNHO ##################
# comparar valores estimados para MG na sessão do R com aqueles disponíveis 
# nas tabelas da plataforma SIDRA

pnadc_ano = 2023
visita = 1

gerar_DA <- function(v) {

	microdados <- "Microdados/PNADC_2023_visita1.txt"
	input <- "Microdados/input_PNADC_2023_visita1_20241220.txt"
	dict <- "Microdados/dicionario_PNADC_microdados_2023_visita1_20241220.xls"
	deflator <- "Microdados/deflator_PNADC_2023.xls"

	dados <- pnadc_deflator(
		pnadc_labeller(
			data_pnadc = read_pnadc(
				microdata = microdados,
				input = input,
				vars = c(v, "UF", "V2009")  # sempre importar UF e Idade
			),
			dictionary.file = dict
		),
		deflator.file = deflator
	)
	dados <- pnadc_design(
		subset(
			dados,
			UF == "Minas Gerais" | UF == "Bahia" | UF == "Pará" | UF == "Goiás"
		)
	)

	dados$variables$UF <- droplevels(dados$variables$UF)
	return(dados)
}

unidades_federativas <- c("Pará", "Bahia", "Minas Gerais", "Goiás")
