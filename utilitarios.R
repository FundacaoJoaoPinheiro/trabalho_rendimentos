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

input_dir <- "Microdados"  # pasta com os arquivos da PNADC
pnadc_ano <- 2023

codvar <- list(
	"7426" = c("VD4020", "V5004A", "V5007A", "V5006A", "V5008A"),
	"7427" = c("VD5002"),
	"7428" = c("VD5002"),
	"7426" = c(),
	"7427" = c(),
	"7428" = c(),
	"7429" = c(),
	"7430" = c(),
	"7431" = c(),
	"7432" = c(),
	"7433" = c(),
	"7434" = c(),
	"7435" = c(),
	"7436" = c(),
	"7437" = c(),
	"7438" = c(),
	"7439" = c(),
	"7440" = c(),
	"7441" = c(),
	"7442" = c(),
	"7443" = c(),
	"7444" = c(),
	"7445" = c(),
	"7446" = c(),
	"7447" = c(),
	"7448" = c(),
	"7449" = c(),
	"7450" = c(),
	"7451" = c(),
	"7452" = c(),
	"7453" = c(),
	"7454" = c(),
	"7455" = c(),
	"7456" = c(),
	"7457" = c(),
	"7458" = c(),
	"7521" = c(),
	"7526" = c(),
	"7527" = c(),
	"7529" = c(),
	"7530" = c(),
	"7531" = c(),
	"7532" = c(),
	"7533" = c(),
	"7534" = c(),
	"7535" = c(),
	"7536" = c(),
	"7537" = c(),
	"7538" = c(),
	"7539" = c(),
	"7540" = c(),
	"7541" = c(),
	"7542" = c(),
	"7543" = c(),
	"7544" = c(),
	"7545" = c(),
	"7546" = c(),
	"7547" = c(),
	"7548" = c(),
	"7549" = c(),
	"7550" = c(),
	"7551" = c(),
	"7552" = c(),
	"7553" = c(),
	"7554" = c(),
	"7559" = c(),
	"7560" = c(),
	"7561" = c(),
	"7562" = c(),
	"7563" = c(),
	"7564" = c()
)

# FUNÇÕES

# Gerar plano amostral para MG, adicionando estratos geográficos.
# `tabelas` : um vetor com número de tabelas, cujas variáveis serão importadas;
# `download`: um argumento lógico que define se a importação será online
gerar_pa <- function(tabelas = NULL, download = FALSE) {

	# definir variáveis com base nas tabelas passadas como argumentos
	if (is.null(tabelas)) {
		tabelas <- names(codvar)  # se `NULL`, selecionar todas as tabelas
	} else {
		tabelas <- as.character(tabelas)
	}
	variaveis <- unique(unlist(codvar[tabelas]))

	# incorporar ou não deflatores de acordo com tabelas específicas
	requer_deflator <- any(tabelas %in% c("7427", "7428"))
	
	# ler os dados (baixar apenas se download=TRUE)
	if (download) {
		dados <- get_pnadc(
			year = as.numeric(pnadc_ano),
			interview = 5,
			design = FALSE,
			vars = variaveis,
			deflator = requer_deflator
		)
	} else {
		# definir caminho para os arquivos relevantes
		microdados <- file.path(input_dir, paste0("PNADC_",
			pnadc_ano, "_visita5.txt"))
		input <- file.path(input_dir, paste0("input_PNADC_",
			pnadc_ano, "_visita5.txt"))
		dicionario <- file.path(input_dir, paste0("dicionario_PNADC_microdados_",
			pnadc_ano, "_visita5.xls"))
		deflator <- file.path(input_dir, paste0("deflator_PNADC_",
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
		if (requer_deflator) {
			dados <- pnadc_deflator(dados, deflator.file = deflator)
		}
	}
	dados <- pnadc_design(subset(dados, UF == "Minas Gerais"))

	# adicionar coluna com os códigos dos Estratos Geográficos
	dados$variables <- transform(
		dados$variables,
		Possui_Renda_Habitual = factor(
			ifelse(!is.na(VD4020), "Sim", "Não"),
			levels = c("Sim", "Não"),  # ordem padrão das outras colunas
		),
		Estrato_G = factor(substr(Estrato, 1, 4)) # 4 primeiros números do Estrato
	)                                             # formam o estrato geografico

	return(dados)
}

# Função para estimar população por variável e estrato geográfico
# `pa` é o plano amostral (svyrep.design)
# `var` é uma variável/coluna (string)
estimar_pop <- function(pa, var) {
	formula <- as.formula(paste0("~interaction(Estrato_G, ", var, ")"))
  	svytotal(x = formula, design = pa, na.rm = TRUE)
}

