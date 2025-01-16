#=========== EM ELABORAÇÃO. NÃO UTILIZAR =================#

# Reproduz tabelas SIDRA da PNADC/A, 5a visita, filtrando dados
# para os dez estratos geográficos de Minas Gerais.
# Tema das tabelas: Rendimento de todas as fontes.
#
# Funções e Objetos para serem utilizados interativamente ou de forma
# automatizada pelo script principal
#
# João Paulo Gonzaga Garcia: joaopauloggarcia@gmail.com
#----------------------------------------------------------
# OBJETOS

pnadc_dir <- "Microdados"  # pasta com os arquivos da PNADC
pnadc_ano <- 2023

codvar <- list(
	`7426` = c("VD4052", "VD4019", "VD4020", "VD4048", # não requer deflator
               "V5004A", "V5007A", "V5006A", "V5008A", "V5005A"),
	`7427` = c("V2005", "VD4019", "VD4048"),
	`7428` = c("V2005", "VD4019", "VD4048"),
	`7429` = c("VD5011", "VD4020", "V5004A",
	           "V5007A", "V5006A", "V5008A"),
	`7430` = c("VD4019", "VD4020"),
	`7431` = c("V2010", "V4009", "V4033"),     # não requer deflator
	`7432` = c("V2009", "V4009", "V4033"),     # não requer deflator
	`7433` = c("VD3004", "V4009", "V4033"),    # não requer deflator
	`7434` = c("V2007", "V4009", "V4033"),     # não requer deflator
	`7435` = c("V2005", "VD4019", "VD4048"),
	`7436` = c(),
	`7437` = c("VD4019", "VD4020", "V5004A2", "V5007A2",
	           "V5006A2", "V5008A2", "V5005A2"),
	`7438` = c("V2005", "VD4019", "VD4048"),
	`7439` = c("V2005", "V4034"),              # não requer deflator
	`7440` = c("V1023", "V2005", "V4034"),     # não requer deflator
	`7441` = c("V2010", "VD4019", "VD4020"),
	`7442` = c("VD4019", "VD4020"),
	`7443` = c("VD3004", "VD4019", "VD4020"),
	`7444` = c("V2007", "VD4019", "VD4020"),
	`7445` = c("V1023", "VD4019", "VD4020"),
	`7446` = c("V2005", "VD4019", "VD4020"),
	`7447` = c("VD3004", "V5002A"),         # não requer deflator
	`7448` = c("VD3004", "V5002A"),         # não requer deflator
	`7449` = c("V5002A"),          # não requer deflator
	`7450` = c("V5002A"),          # não requer deflator
	`7451` = c("V5001A"),          # não requer deflator
	`7452` = c("V5001A"),          # não requer deflator
	`7453` = c("VD4019"),
	`7454` = c("VD3004", "V5001A"),    # não requer deflator
	`7455` = c("VD3004", "V5001A"),    # não requer deflator
	`7456` = c("V2001", "V5001A", "V5002A", "V5003A"),    # não requer deflator
	`7457` = c("V5001A", "V5002A", "V5003A"),             # não requer deflator
	`7458` = c("V2005", "VD4019", "VD4048", "V5001A", "V5002A", "V5003A"),
	`7521` = c("VD5011"),
	`7526` = c("V2005", "VD4019", "VD4048"),
	`7527` = c("V2005", "VD4019", "VD4048"),
	`7529` = c("V2005", "VD4019", "VD4048"),
	`7530` = c("V2005", "VD4019", "VD4048"),
	`7531` = c("V2005", "VD4019", "VD4048"),
	`7532` = c("V2005", "VD4019", "VD4048"),
	`7533` = c("V2005", "VD4019", "VD4048"),
	`7534` = c("V2005", "VD4019", "VD4048"),
	`7535` = c("VD4019"),
	`7536` = c("VD4019"),
	`7537` = c("VD4019"),
	`7538` = c("VD4019"),
	`7539` = c("VD4019"),
	`7540` = c("VD4019"),
	`7541` = c("VD4019"),
	`7542` = c("VD4019"),
	`7543` = c("VD4019"),
	`7544` = c("VD4019"),
	`7545` = c("VD4019"),
	`7546` = c("VD4019"),
	`7547` = c("VD4019"),
	`7548` = c("VD4019"),
	`7549` = c("VD4019"),
	`7550` = c("VD4019"),
	`7551` = c("VD4019"),
	`7552` = c("VD4019"),
	`7553` = c("VD4019"),
	`7554` = c("VD4019"),
	`7559` = c("VD4019"),
	`7560` = c("VD4019"),
	`7561` = c("V2005", "VD4019", "VD4048"),
	`7562` = c("VD4019"),
	`7563` = c("VD4019"),
	`7564` = c("V2005", "VD4019", "VD4048")
)

estratos_geo <- c(
    "Belo Horizonte (MG)",     # 3110,
	"Entorno metropol. de Belo Horizonte (MG)",    # 3120,
	"Colar metropolitano de Belo Horizonte (MG)",  # 3130,
	"Integrada de Brasília em Minas Gerais",       # 3140,
	"Sul de Minas Gerais",     # 3151,
	"Triângulo Mineiro",       # 3152,
	"Zona da Mata (MG)",       # 3153,
	"Norte de Minas Gerais",   # 3154,
	"Vale do Rio Doce (MG)",   # 3155,
	"Central de Minas Gerais"  # 3156
)

#----------------------------------------------------------
# FUNÇÕES

# Gerar desenho amostral para MG, adicionando estratos geográficos.
# `tabelas` : um vetor com número de tabelas, cujas variáveis serão importadas;
# `download`: um argumento lógico que define se a importação será online
gerar_DA <- function(tabelas = "todas", year = ano, download = FALSE) {

	# definir variáveis com base nas tabelas passadas como argumentos
	if (tabelas == "todas") {
		tabelas <- names(codvar)  # se `NULL`, selecionar todas as tabelas
	} else {
		tabelas <- as.character(tabelas)
	}
	variaveis <- unique(unlist(codvar[tabelas]))

	# importar dados da 1a visita, com exceção dos anos 2020 e 2021 (5a visita)
	visita <- ifelse(year == 2020 | year == 2021, 5, 1)

	# tabelas com estimativas para população que não precisam de deflatores
	tabelas_pop <- c("7426", "7431", "7432", "7433", "7434", "7436", "7439",
		"7440", "7447", "7448", "7449", "7450", "7451", "7452", "7454", "7455",
		"7456", "7457")
	
	# incorporar deflatores de acordo com as tabelas desejadas (TRUE ou FALSE)
	requer_deflator <- length(setdiff(tabelas, tabelas_pop)) > 0
	
	# ler os dados
	# baixar apenas se download=TRUE
	if (download) {
		dados <- get_pnadc(
			year = pnadc_ano,
			interview = visita,
			design = FALSE,               # será feito pela função pnadc_design
			vars = c(variaveis, "UF", "V2009"),    # sempre importar UF e Idade
			deflator = requer_deflator
		)
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

		# ler os arquivos e gerar o desenho amostral
		dados <- pnadc_labeller(
			data_pnadc = read_pnadc(
			microdata = microdados,
			input = input,
				vars = c(variaveis, "UF", "V2009")  # sempre importar UF e Idade
			),
			dictionary.file = dicionario
		)
		if (requer_deflator) {
			dados <- pnadc_deflator(dados, deflator.file = deflator)
		}
	}
	dados <- pnadc_design(subset(dados, UF == "Minas Gerais", V2009 >= 14))

	# adicionar coluna com os códigos dos Estratos Geográficos
	dados$variables <- transform(
		dados$variables,
		Estrato_G = factor(substr(Estrato, 1, 4)) # 4 primeiros números do Estrato
	)                                             # formam o estrato geografico

	return(dados)
}
