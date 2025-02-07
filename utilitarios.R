# Funções e Objetos para serem utilizados interativamente ou de forma
# automatizada pelos demais scripts.
#
# João Paulo Gonzaga Garcia: joaopauloggarcia@gmail.com
#----------------------------------------------------------
# OBJETOS

# Objetos utilizados na leitura dos dados da PNADc
pnadc_ano <- 2023

pnadc_dir <- "Microdados"
microdados <- file.path(pnadc_dir, "PNADC_2023_visita1.txt")
input      <- file.path(pnadc_dir, "input_PNADC_2023_visita1_20241220.txt")
deflator   <- file.path(pnadc_dir, "deflator_PNADC_2023.xls")
dicionario <- file.path(pnadc_dir,
	"dicionario_PNADC_microdados_2023_visita1_20241220.xls")

# Tabelas agrupadas por características em comum

tabelas_distribuicao <- c("7543", "7544", "7553", "7554")

tabelas_fontes <- c("7426", "7429", "7437")

tabelas_RDPC1 <- c("7428", "7438", "7521", "7527",       # prório ano
                   "7530", "7531", "7532", "7561")
tabelas_RDPC2 <- c("7427", "7458", "7526", "7529",       # último ano
                   "7533", "7534", "7564")

tabelas_RMe1 <- c("7453", "7453", "7535", "7538", "7545", "7548")    # prório ano
tabelas_RMe2 <- c("7441", "7442", "7443", "7444", "7445", "7446",    # último ano
                  "7539", "7542", "7549", "7552")

tabelas_ocupada <- c("7431", "7432", "7433", "7434", "7436",
                     "7439", "7440", "7537", "7541", "7546",
                     "7547", "7559", "7560", "7562", "7563") 

tabelas_progsocial <- c("7447", "7448", "7449")

sem_deflator <- c("7426", "7431", "7432", "7433", "7434", "7436", "7439",
	"7440", "7447", "7448", "7449", "7450", "7451", "7452", "7454", "7455",
	"7456", "7457")

# Objetos utilizados como rótulos na criação de colunas

areas_geograficas <- c("Capital", "Resto.da.RM", "Resto.da.RIDE", "Resto.da.UF")

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

grupos_idade = c(
	"14 a 17 anos",
	"18 e 19 anos",
	"20 a 24 anos",
	"25 a 29 anos",
	"30 a 39 anos",
	"40 a 49 anos",
	"50 a 59 anos",
	"60 anos ou mais"
)

classes_simples <- paste0("P", c(5, seq(10, 90, by = 10), 95, 99))

faixas_simples <- c(
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

faixas_acumuladas <- c(paste0("Até P", c(5, 1:9 * 10, 95, 99)), "Total")

# Lista de variáveis por tabela
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

# `tabelas` : um vetor com número de tabelas, cujas variáveis serão importadas;
# `ano`     : ano da pesquisa (numérico)
# `download`: um argumento lógico que define se a importação será online
gerar_desenho <- function(tabelas, ano = pnadc_ano, download = FALSE) {

	# definir argumentos usados na leitura dos microdados
	visita <- ifelse(ano == 2020 | ano == 2021, 5, 1)
	tabelas <- as.character(tabelas)
	variaveis <- unique(unlist(variaveis[tabelas]))
	requer_deflator <- length(setdiff(tabelas, sem_deflator)) > 0
	
	# ler os dados
	if (download) {
		dados <- get_pnadc(
			year = pnadc_ano,
			interview = visita,
			design = FALSE,                       # ver abaixo pnadc_design()
			vars = c(variaveis, "UF", "V2009"),   # sempre importar UF e Idade
			deflator = requer_deflator
		)
	} else {
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

	# gerar desenho amostral para MG, incluindo coluna com estratos geográficos
	dados <- pnadc_design(subset(dados, UF == "Minas Gerais"))
	dados$variables$UF <- droplevels(dados$variables$UF)
	dados$variables <- transform(
		dados$variables,
		Estrato.Geo = factor(substr(Estrato, 1, 4))  # 1o ao 4o num. do Estrato
	)                                                # dão o estrato geografico

	return(dados)
}

estimar_totais <- function(desenho, formula, por = ~Estrato.Geo) {
	por = update.formula(por, ~ . + Estrato.Geo)
	svyby(
		formula = as.formula(formula),
		by = as.formula(por),
		design = desenho,
		FUN = svytotal,
		vartype = "cv",
		keep.names = FALSE,
		drop.empty.groups = FALSE,
		na.rm = TRUE
	)
}

estimar_quantis <- function(desenho, renda) {
	svyby(
		formula = as.formula(renda),
		by = ~Estrato.Geo,
		design = desenho,
		FUN = svyquantile,
		quantiles = c(0.05, seq(0.10, 0.90, by = 0.10), 0.95, 0.99),
		vartype = "cv",
		keep.names = FALSE,
		drop.empty.groups = FALSE,
		na.rm = TRUE
	)
}

reshape_wide <- function(df, timevar.pos = 1) {
	resultado <- reshape(
		df, direction = "wide",
		idvar =  "UF",
		timevar = colnames(df)[timevar.pos]
	)
	colnames(resultado) <- c("UF", levels(df[[timevar.pos]]))
	rownames(resultado) <- NULL
	return(resultado)
}

add_faixas_simples <- function(renda, geo, limites) {
	renda_geo <- split(renda, geo)
	limites_geo <- limites[-1]

	faixas_geo <- Map(
		function(valores, quantis) {
			cut(
				valores,
				breaks = c(-Inf, quantis[1:12], Inf),
				labels = faixas_simples,
				right = FALSE
			)
		},
		renda_geo,
		limites_geo
	)
	
	resultado <- unsplit(faixas_geo, geo)
	return(resultado)
}

add_grupos_idade <- function(idade) {
	cut(
		idade,
		breaks = c(13, 17, 19, 24, 29, 39, 49, 59, Inf),
		labels = grupos_idade,
		right = TRUE
	)
}
