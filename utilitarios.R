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

pnadc_dir <- "Microdados" # pasta com os arquivos da PNADC
pnadc_ano <- 2023

microdados <- file.path(pnadc_dir, "PNADC_2023_visita1.txt")
input      <- file.path(pnadc_dir, "input_PNADC_2023_visita1_20241220.txt")
deflator   <- file.path(pnadc_dir, "deflator_PNADC_2023.xls")
dicionario <- file.path(pnadc_dir,
	"dicionario_PNADC_microdados_2023_visita1_20241220.xls")

# não precisam de deflatores
sem_deflator <- c("7426", "7431", "7432", "7433", "7434", "7436", "7439",
	"7440", "7447", "7448", "7449", "7450", "7451", "7452", "7454", "7455",
	"7456", "7457")

# a distribuição da massa de rendimento
tabelas_distribuicao <- c("7543", "7544", "7553", "7554")

# categorias por tipo de rendimento (trabalho, outras fontes, etc)
tabelas_tipo_rend <- c("7426", "7429", "7437")

# rendimento domicilar per capita a preços prório/último do ano
tabelas_RDPC <- c("7428", "7438", "7521", "7527",       # prório ano
                  "7530", "7531", "7532", "7561",
                  "7427", "7458", "7526", "7529",       # último ano
                  "7533", "7534", "7564")

# rendimento médio mensal de pessoas ocupadas a preços do prório/último ano
tabelas_RMe <- c("7453", "7453", "7535", "7538", "7545", "7548",    # prório ano
                 "7441", "7442", "7443", "7444", "7445", "7446",    # último ano
                 "7539", "7542", "7549", "7552")

# população ocupada por categoria (sexo, cor/raça, instrução, etc)
tabelas_pop <- c("7431", "7432", "7433", "7434", "7436", "7439", "7440", "7537",
	"7541", "7546", "7547", "7559", "7560", "7562", "7563") 

# população com domicílios em que alguém recebe benefícios
tabelas_progsocial <- c("7447", "7448", "7449")

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
	"Central de Minas Gerais " # 3156
)

# classes simples de percentual (CSP)
rotulos_csp <- c(
	"Até P5",
	"Maior que P5 até P10",
	"Maior que P10 até P20",
	"Maior que P20 até P30",
	"Maior que P30 até P40",
	"Maior que P40 até P50",
	"Maior que P50 até P60",
	"Maior que P60 até P70",
	"Maior que P70 até P80",
	"Maior que P80 até P90",
	"Maior que P90 até P95",
	"Maior que P95 até P99",
	"Maior que P99"
)

# classes acumuladas de percentual (CAP)
rotulos_cap <- c(paste0("Até P", c(5, 1:9 * 10, 95, 99)), "Total")

variaveis <- list(
	`7426` = c("V5001A2", "V5002A2", "V5003A2", "V5004A2",
               "V5005A2", "V5006A2", "V5007A2", "V5008A2",
               "VD4019",  "VD4020",  "VD4048",  "VD4052",
               "V2001",   "V2005"),
	`7427` = c("V2005", "VD4019", "VD4048"),
	`7428` = c("V2005", "VD4019", "VD4048"),
	`7429` = c("V5001A2", "V5002A2", "V5003A2", "V5004A2",
               "V5005A2", "V5006A2", "V5007A2", "V5008A2",
               "VD4019",  "VD4020",  "VD4048",  "VD4052",
               "V2001",   "V2005"),
	`7430` = c("VD4019", "VD4020"),
	`7431` = c("V2009", "VD4002", "VD4052", "V2010"),
	`7432` = c("V2009", "VD4002", "VD4052"),
	`7433` = c("V2009", "VD4002", "VD4052", "VD3004"),
	`7434` = c("V2009", "VD4002", "VD4052", "2007"),
	`7435` = c("V2005", "VD4019", "VD4048"),
	`7436` = c(),
	`7437` = c("V5001A2", "V5002A2", "V5003A2", "V5004A2",
               "V5005A2", "V5006A2", "V5007A2", "V5008A2",
               "VD4019",  "VD4020",  "VD4048",  "VD4052",
               "V2001",   "V2005"),
	`7438` = c("V2005", "VD4019", "VD4048"),
	`7439` = c("V2009", "VD4002", "VD4052", "V2005"),
	`7440` = c("V1023", "V2005", "V4034"),
	`7441` = c("V2010", "VD4002", "VD4052", "V1023"),
	`7442` = c("VD4019", "VD4020"),
	`7443` = c("VD3004", "VD4019", "VD4020"),
	`7444` = c("V2007", "VD4019", "VD4020"),
	`7445` = c("V1023", "VD4019", "VD4020"),
	`7446` = c("V2005", "V2005", "VD4019", "VD4020"),
	`7447` = c("VD3004", "V5002A"),
	`7448` = c("VD3004", "V5002A"),
	`7449` = c("V5002A"),
	`7450` = c("V5002A"),
	`7451` = c("V5001A"),
	`7452` = c("V5001A"),
	`7453` = c("VD4019"),
	`7454` = c("VD3004", "V5001A"),
	`7455` = c("VD3004", "V5001A"),
	`7456` = c("V2001", "V5001A", "V5002A", "V5003A"),
	`7457` = c("V5001A", "V5002A", "V5003A"),
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
	`7537` = c("V2009", "VD4002", "VD4052", "VD4019"),
	`7538` = c("VD4019"),
	`7539` = c("VD4019"),
	`7540` = c("VD4019"),
	`7541` = c("V2009", "VD4002", "VD4052", "VD4019"),
	`7542` = c("VD4019"),
	`7543` = c("V2009", "VD4002", "VD4019"),
	`7544` = c("V2009", "VD4002", "VD4019"),
	`7545` = c("VD4019"),
	`7546` = c("V2009", "VD4002", "VD4052", "VD4020"),
	`7547` = c("V2009", "VD4002", "VD4052", "VD4020"),
	`7548` = c("VD4019"),
	`7549` = c("VD4019"),
	`7550` = c("VD4019"),
	`7551` = c("VD4019"),
	`7552` = c("VD4019"),
	`7553` = c("V2009", "VD4002", "VD4020"),
	`7554` = c("V2009", "VD4002", "VD4020"),
	`7559` = c("V2009", "VD4002", "VD4052", "VD4020"),
	`7560` = c("V2009", "VD4002", "VD4052", "VD4020"),
	`7561` = c("V2005", "VD4019", "VD4048"),
	`7562` = c("V2009", "VD4002", "VD4052", "VD4019"),
	`7563` = c("V2009", "VD4002", "VD4052", "VD4019"),
	`7564` = c("V2005", "VD4019", "VD4048")
)

#----------------------------------------------------------
# FUNÇÕES

# Gerar desenho amostral para MG, adicionando estratos geográficos.
# `tabelas` : um vetor com número de tabelas, cujas variáveis serão importadas;
# `year`    : ano da pesquisa (numérico)
# `download`: um argumento lógico que define se a importação será online
gerar_desenho <- function(tabelas, year = pnadc_ano, download = FALSE) {

	# definir variáveis com base nas tabelas passadas como argumentos
	if (is.null(tabelas)) {
		tabelas <- names(variaveis)  # se `NULL`, selecionar todas as tabelas
	} else {
		tabelas <- as.character(tabelas)
	}
	variaveis <- unique(unlist(variaveis[tabelas]))

	# importar dados da 1a visita, com exceção dos anos 2020 e 2021 (5a visita)
	visita <- ifelse(year == 2020 | year == 2021, 5, 1)

	# incorporar deflatores de acordo com as tabelas desejadas (TRUE ou FALSE)
	requer_deflator <- length(setdiff(tabelas, sem_deflator)) > 0
	
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
	dados <- pnadc_design(subset(dados, UF == "Minas Gerais"))
	dados$variables$UF <- droplevels(dados$variables$UF)

	# adicionar coluna com os códigos dos Estratos Geográficos
	dados$variables <- transform(
		dados$variables,
		Estrato.Geo = factor(substr(Estrato, 1, 4)) # 1o ao 4o números do Estrato
	)                                               # formam o estrato geografico

	return(dados)
}

estimar_quantis <- function(var, design) {
	svyby(
		formula = as.formula(var),
		by = ~ Estrato.Geo,
		design,
		FUN = svyquantile,
		quantiles = c(0.05, seq(0.10, 0.90, by = 0.10), 0.95, 0.99),
		vartype = "cv",
		na.rm = TRUE
	)
}

add_classe_simples <- function(dt, var, quantis) {
	# dividir a variável em uma lista por estrato geográfico
	var_estratos <- split(
		dt[[as.character(var)]],
		dt$Estrato.Geo
	)
	quantis_estratos <- split(quantis[2:13], quantis[[1]])
	# criar lista com classes simples por estrato geográfico
	classe_estrato <- Map(
		function(var, breaks) {
			cut(
				var,
				breaks = c(-Inf, as.numeric(breaks), Inf),
				labels = rotulos_csp,
				right = FALSE
			)
		},
		var_estratos,
		quantis_estratos
	)
	# reunir a lista de forma adequada à coluna de estratos da amostra
	unsplit(classe_estrato, dt$Estrato.Geo)
}

