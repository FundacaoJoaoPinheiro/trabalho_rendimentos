#=========== EM ELABORAÇÃO. NÃO UTILIZAR =================#

# Reproduz tabelas SIDRA da PNADC/A, 5a visita, recortando os dados
# para os dez estratos geográficos de Minas Gerais.
# Tema das tabelas: Rendimento de todas as fontes.
#
# Funções e Objetos para serem utilizados manualmente ou de forma
# automatizada pelo script principal
#
# João Paulo Gonzaga Garcia: joaopauloggarcia@gmail.com
#----------------------------------------------------------
# OBJETOS

pnadc_dir <- "Microdados"  # pasta com os arquivos da PNADC
pnadc_ano <- 2023

codvar <- list(
	"7426", = c("VD4020", "V5004A", "V5007A", "V5006A", "V5008A"),
	"7427", = c("VD5002"),  # requer deflator
	"7428", = c("VD5002"),  # requer deflator
	"7429", = c(),  # requer deflator
	"7430", = c(),
	"7431", = c(),
	"7432", = c(),
	"7433", = c(),
	"7434", = c(),
	"7435", = c(),  # requer deflator
	"7436", = c(),
	"7437", = c(),  # requer deflator
	"7438", = c(),  # requer deflator
	"7439", = c(),
	"7440", = c(),
	"7441", = c(),  # requer deflator
	"7442", = c(),  # requer deflator
	"7443", = c(),  # requer deflator
	"7444", = c(),  # requer deflator
	"7445", = c(),  # requer deflator
	"7446", = c(),  # requer deflator
	"7447", = c(),
	"7448", = c(),
	"7449", = c(),
	"7450", = c(),
	"7451", = c(),
	"7452", = c(),
	"7453", = c(),  # requer deflator
	"7454", = c(),
	"7455", = c(),
	"7456", = c(),
	"7457", = c(),
	"7458", = c(),  # requer deflator
	"7521", = c(),
	"7526", = c(),  # requer deflator
	"7527", = c(),  # requer deflator
	"7529", = c(),  # requer deflator
	"7530", = c(),  # requer deflator
	"7531", = c(),  # requer deflator
	"7532", = c(),  # requer deflator
	"7533", = c(),  # requer deflator
	"7534", = c(),  # requer deflator
	"7535", = c(),  # requer deflator
	"7536", = c().
	"7537", = c(),  # requer deflator
	"7538", = c(),  # requer deflator
	"7539", = c(),  # requer deflator
	"7540", = c(),
	"7541", = c(),  # requer deflator
	"7542", = c(),  # requer deflator
	"7543", = c(),  # requer deflator
	"7544", = c(),  # requer deflator
	"7545", = c(),  # requer deflator
	"7546", = c(),
	"7547", = c(),  # requer deflator
	"7548", = c(),  # requer deflator
	"7549", = c(),  # requer deflator
	"7550", = c(),
	"7551", = c(),  # requer deflator
	"7552", = c(),  # requer deflator
	"7553", = c(),  # requer deflator
	"7554", = c(),  # requer deflator
	"7559", = c(),  # requer deflator
	"7560", = c(),  # requer deflator
	"7561", = c(),  # requer deflator
	"7562", = c(),  # requer deflator
	"7563", = c(),  # requer deflator
	"7564", = c()   # requer deflator
)

# FUNÇÕES

# Gerar plano amostral para MG, adicionando estratos geográficos.
# `tabelas` : um vetor com número de tabelas, cujas variáveis serão importadas;
# `download`: um argumento lógico que define se a importação será online
gerar_PA <- function(tabelas = NULL, download = FALSE) {

	# definir variáveis com base nas tabelas passadas como argumentos
	if (is.null(tabelas)) {
		tabelas <- names(codvar)  # se `NULL`, selecionar todas as tabelas
	} else {
		tabelas <- as.character(tabelas)
	}
	variaveis <- unique(unlist(codvar[tabelas]))

	nao_requer_deflator <- c( "7426", "7430", "7431", "7432", "7433", "7434",
		"7436", "7439", "7440", "7447", "7448", "7449", "7450", "7451", "7452",
		"7454", "7455", "7456", "7457", "7521", "7536", "7540", "7546", "7550")
	
	# incorporar ou não deflatores de acordo com as tabelas desejadas
	add_deflator <- length(setdiff(tabelas, nao_requer_deflator)) > 0
	
	# ler os dados (baixar apenas se download=TRUE)
	if (download) {
		dados <- get_pnadc(
			year = as.numeric(pnadc_ano),
			interview = 5,
			design = FALSE,    # será feito pela função pnadc_design
			vars = variaveis,
			deflator = add_deflator
		)
	} else {
		# definir caminho para os arquivos relevantes
		microdados <- file.path(pnadc_dir, paste0("PNADC_",
			pnadc_ano, "_visita5.txt"))
		input <- file.path(pnadc_dir, paste0("input_PNADC_",
			pnadc_ano, "_visita5.txt"))
		dicionario <- file.path(pnadc_dir, paste0("dicionario_PNADC_microdados_",
			pnadc_ano, "_visita5.xls"))
		deflator <- file.path(pnadc_dir, paste0("deflator_PNADC_",
			pnadc_ano, ".xls"))

		# ler os arquivos e construir o plano amostral
		dados <- pnadc_labeller(
			data_pnadc = read_pnadc(
				microdata = microdados,
				input = input,
				vars = variaveis
			),
			dictionary.file = dicionario
		)
		if (add_deflator) {
			dados <- pnadc_deflator(dados, deflator.file = deflator)
		}
	}
	dados <- pnadc_design(subset(dados, UF == "Minas Gerais"))

	# adicionar coluna com os códigos dos Estratos Geográficos
	dados$variables <- transform(
		dados$variables,
		Estrato_G = factor(substr(Estrato, 1, 4)) # 4 primeiros números do Estrato
	)                                             # formam o estrato geografico

	return(dados)
}

# Função para estimar população por variável e estrato geográfico
# `PA` é o plano amostral (svyrep.design)
# `var` é uma variável/coluna (string)
estimar_pop <- function(PA, var) {
	formula <- as.formula(paste0("~interaction(Estrato_G, ", var, ")"))
  	svytotal(x = formula, design = PA, na.rm = TRUE)
}

