#=========== EM ELABORAÇÃO. NÃO UTILIZAR =================#

# Reproduz tabelas SIDRA da PNADC/A, 5a visita, recortando os dados
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
	"7426", = c("VD4020", "VD4020", "V5004A", "V5007A", "V5006A", "V5008A"), #F
	"7427", = c("VD5002"),
	"7428", = c("VD5002"),
	"7429", = c(),
	"7430", = c(),
	"7431", = c(),  #F
	"7432", = c(),  #F
	"7433", = c(),  #F
	"7434", = c(),  #F
	"7435", = c(),
	"7436", = c(),  #F
	"7437", = c(),
	"7438", = c(),
	"7439", = c(),  #F
	"7440", = c(),  #F
	"7441", = c(),
	"7442", = c(),
	"7443", = c(),
	"7444", = c(),
	"7445", = c(),
	"7446", = c(),
	"7447", = c(),  #F
	"7448", = c(),  #F
	"7449", = c(),  #F
	"7450", = c(),  #F
	"7451", = c(),  #F
	"7452", = c(),  #F
	"7453", = c(),
	"7454", = c(),  #F
	"7455", = c(),  #F
	"7456", = c(),  #F
	"7457", = c(),  #F
	"7458", = c(),
	"7521", = c(),  #F
	"7526", = c(),
	"7527", = c(),
	"7529", = c(),
	"7530", = c(),
	"7531", = c(),
	"7532", = c(),
	"7533", = c(),
	"7534", = c(),
	"7535", = c(),
	"7536", = c(),  #F
	"7537", = c(),
	"7538", = c(),
	"7539", = c(),
	"7540", = c(),  #F
	"7541", = c(),
	"7542", = c(),
	"7543", = c(),
	"7544", = c(),
	"7545", = c(),
	"7546", = c(),  #F
	"7547", = c(),
	"7548", = c(),
	"7549", = c(),
	"7550", = c(),  #F
	"7551", = c(),
	"7552", = c(),
	"7553", = c(),
	"7554", = c(),
	"7559", = c(),
	"7560", = c(),
	"7561", = c(),
	"7562", = c(),
	"7563", = c(),
	"7564", = c() 
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

	# tabelas com estimativas para população (não precisam de deflator)
	tabelas_pop <- c("7426", "7431", "7432", "7433", "7434", "7436", "7439",
		"7440", "7447", "7448", "7449", "7450", "7451", "7452", "7454", "7455",
		"7456", "7457", "7521", "7536", "7540", "7546", "7550")
	
	# incorporar deflatores de acordo com as tabelas desejadas (TRUE ou FALSE)
	requer_deflator <- length(setdiff(tabelas, tabelas_pop)) > 0
	
	# ler os dados (baixar apenas se download=TRUE)
	if (download) {
		dados <- get_pnadc(
			year = pnadc_ano,
			interview = 5,
			design = FALSE,    # será feito pela função pnadc_design
			vars = variaveis,
			deflator = requer_deflator
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

		# ler os arquivos e gerar o plano amostral
		dados <- pnadc_labeller(
			data_pnadc = read_pnadc(
				microdata = microdados,
				input = input,
				vars = variaveis
			),
			dictionary.file = dicionario
		)
		if (requer_deflator) {
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

# Função para estimar totais por variável e estrato geográfico
# `PA` é o plano amostral (svyrep.design)
# `var` é uma variável/coluna (string)
estimar_pop <- function(PA, var) {
	formula <- as.formula(paste0("~interaction(Estrato_G, ", var, ")"))
  	svytotal(x = formula, design = PA, na.rm = TRUE)
}

