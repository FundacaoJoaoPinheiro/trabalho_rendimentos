############### RASCUNHO ##################
# comparar valores estimados para MG na sessão do R com aqueles disponíveis 
# nas tabelas da plataforma SIDRA

# Funções e Objetos para serem utilizados interativamente ou de forma
# automatizada.
###########################################

# OBJETOS

# Definindo caminho de arquivos e outros argumentos que serão usados
# para a leitura dos dados

pnadc_ano <- 2023

# diretório com os arquivos de microdados e os respectivos arquivos
pnadc_dir <- "../entrada"
microdados <- file.path(pnadc_dir, "PNADC_2023_visita1.txt")
input      <- file.path(pnadc_dir, "input_PNADC_2023_visita1_20241220.txt")
deflator   <- file.path(pnadc_dir, "deflator_PNADC_2023.xls")
dicionario <- file.path(pnadc_dir,
	"dicionario_PNADC_microdados_2023_visita1_20241220.xls")

# Definindo grupos de tabelas por características comuns

# não precisam de deflatores
sem_deflator <- c("7426", "7431", "7432", "7433", "7434", "7436", "7439",
	"7440", "7447", "7448", "7449", "7450", "7451", "7452", "7454", "7455",
	"7456", "7457")

# a distribuição da massa de rendimento
tabelas_distribuicao <- c("7543", "7544", "7553", "7554")

# categorias por fontes de rendimento (trabalho, outras fontes, etc)
tabelas_fontes <- c("7426", "7429", "7437")

# rendimento domicilar per capita a preços prório/último do ano
tabelas_RDPC1 <- c("7428", "7438", "7521", "7527",       # prório ano
                   "7530", "7531", "7532", "7561")
tabelas_RDPC2 <- c("7427", "7458", "7526", "7529",       # último ano
                   "7533", "7534", "7564")

# rendimento médio mensal de pessoas ocupadas a preços do prório/último ano
tabelas_RMe1 <- c("7453", "7453", "7535", "7538", "7545", "7548")    # prório ano
tabelas_RMe2 <- c("7441", "7442", "7443", "7444", "7445", "7446",    # último ano
                  "7539", "7542", "7549", "7552")

# população ocupada por categoria (sexo, cor/raça, instrução, etc)
tabelas_ocupada <- c("7431", "7432", "7433", "7434", "7436",
                     "7439", "7440", "7537", "7541", "7546",
                     "7547", "7559", "7560", "7562", "7563") 

# população com domicílios em que alguém recebe benefícios
tabelas_progsociais <- c("7447", "7448", "7449", "7450",
                         "7451", "7452", "7454", "7455",
                         "7456", "7457")

# Definindo outros objetos úteis, utilizados principalmente como "rótulos"
# para colunas das tabelas

unidades_federativas <- c("Pará", "Bahia", "Minas Gerais", "Goiás")

areas_geograficas <- c("Capital", "Resto.da.RM", "Resto.da.RIDE", "Resto.da.UF")

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

# classes simples dde percentual (CSP)
classes <- paste0("P", c(5, seq(10, 90, by = 10), 95, 99))

classes_simples <- c(
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

classes_acumuladas <- c(paste0("Até P", c(5, 1:9 * 10, 95, 99)), "Total")

# Definindo lista com as variáveis requeridas por cada tabela

variaveis <- list(
	`7426` = c("V5001A2", "V5002A2", "V5003A2", "V5004A2",
               "V5005A2", "V5006A2", "V5007A2", "V5008A2",
               "VD5008",
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
	`7434` = c("V2009", "VD4002", "VD4052", "V2007"),
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
	`7449` = c("V2005",  "V5001A", "V5002A",  "V5003A",
               "VD3004", "S01007", "S01012A", "S01013",
               "S01014", "S01023", "S01024",  "S01025",
               "S01028"),
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

# Gerar desenho amostral para PA, MG, BA e GO
# `tabelas` : um vetor com número de tabelas, cujas variáveis serão importadas;
# `year`    : ano da pesquisa (numérico)
# `download`: um argumento lógico que define se a importação será online
gerar_desenho <- function(tabelas, ano = pnadc_ano, download = FALSE) {

	# importar dados da 1a visita, com exceção dos anos 2020 e 2021 (5a visita)
	visita <- ifelse(ano == 2020 | ano == 2021, 5, 1)

	# definir variáveis com base nas tabelas passadas como argumentos
	tabelas <- as.character(tabelas)
	variaveis <- unique(unlist(variaveis[tabelas]))

	# incorporar deflatores de acordo com as tabelas desejadas (TRUE ou FALSE)
	requer_deflator <- length(setdiff(tabelas, sem_deflator)) > 0
	
	# Ler os dados
	# baixar apenas se download=TRUE
	if (download) {
		dados <- get_pnadc(
			year = ano,
			interview = visita,
			design = FALSE,               # será feito pela função pnadc_design
			vars = c(variaveis, "UF", "V2009"),    # sempre importar UF e Idade
			savedir = pnadc_dir,
			reload = FALSE,
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
		# adicionar deflatores quando necessário
		if (requer_deflator) {
			dados <- pnadc_deflator(dados, deflator.file = deflator)
		}
	}
	# filtrar dados para PA, BA, MG e GO
	dados <- pnadc_design(subset(dados, UF %in% unidades_federativas))
	dados$variables$UF <- droplevels(dados$variables$UF)

	return(dados)
}

# estimar totais por UF
estimar_totais <- function(desenho, formula, por = ~UF) {
	por = update.formula(por, ~ . + UF)
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

# estimar médias por UF
estimar_medias <- function(desenho, formula, por = ~UF) {
	por = update.formula(por, ~ . + UF)
	svyby(
		formula = as.formula(formula),
		by = as.formula(por),
		design = desenho,
		FUN = svymean,
		vartype = "cv",
		keep.names = FALSE,
		drop.empty.groups = FALSE,
		na.rm = TRUE
	)
}

# estimar quantis das classes percentuais simples e UF
estimar_quantis <- function(desenho, formula) {
	svyby(
		formula,
		by = ~UF,
		design = desenho,
		FUN = svyquantile,
		quantiles = c(0.05, seq(0.10, 0.90, by = 0.10), 0.95, 0.99),
		vartype = "cv",
		keep.names = FALSE,
		na.rm = TRUE
	)
}

# estimativas por interação UF x programas sociais, utilizando svybys()
estimar_interacao <- function(desenho, formula, FUN, vars) {

	# preparar fórmula com a interação UF x Programas
	interacao <- reformulate(
		vapply(
			vars,
			function(v) paste0("interaction(UF, ", v, ")"), character(1L)
		),
		response = NULL
	)

	svybys(
		design = desenho,
		formula = formula,
		bys = interacao,
		FUN = FUN,
		vartype = "cv",
		keep.names = FALSE
	)
}

# estimar variáveis por faixa acumulada percentual(FAP)
estimar_cap <- function(desenho, formula, csp) {

	cap_list <- vector("list", 13)
	for (i in 1:13) {
	    sub_desenho <- subset(desenho, get(csp) %in% classes_simples[1:i])
	    cap_list[[i]] <- estimar_medias(sub_desenho, formula)
	}

	# agrupar valores e CV's dos data frames da lista
	valores <- data.frame(
		unidades_federativas,     # selecionar coluna de valores
		do.call(cbind, lapply(cap_list, `[`, 2))
	)
	cvs <- data.frame(
		unidades_federativas,     # selecionar coluna de CV's
		do.call(cbind, lapply(cap_list, `[`, 3))
	)
	cvs[, -1] <- round(cvs[, -1] * 100, 1)

	colnames(valores) <- c("UF", classes_acumuladas)
	colnames(cvs) <- c("UF", classes_acumuladas)

	return(list(valores, cvs))
}

# reformatar tabelas, criando uma coluna para cada categoria da variável
reshape_wide <- function(df, timevar.pos = 1) {
	# capturar categorias que serão usadas como nomes de colunas
	timevar_names <- levels(df[[timevar.pos]])
	# usar reshape para passar para o formato wide
	df <- reshape(
		df, direction = "wide",
		idvar =  "UF",
		timevar = colnames(df)[timevar.pos]
	)
	# adicionar os nomes das colunas e excluir nomes de linhas
	colnames(df) <- c("UF", timevar_names)
	rownames(df) <- NULL
	return(df)
}

# dividir colunas de interação criadas por svybys()  ex: dividir
# "Pará.Sim" em "Pará" e "Sim"  e então reagrupar os dataframes da
# lista gerada usando reshape_wide(), função criada acima.
agrupar_progs <- function(lista) {

	# função que será aplicada a cada item da lista gerada por svyby()
	dividir_interacao <- function(df) {

		# adicionar as duas colunas que formam a interação
		df$UF <- rep(unidades_federativas, times = 2)
		df$Categoria <- factor(
			rep(c("Sim", "Não"), each = 4),
			levels = c("Sim", "Não")
		)

		# adicionar o nome do programa social às colunas
		nome <- sub(
			".*?\\.([^)]*)\\)", "\\1",    # entre o primeiro "." e o próximo ")"
			colnames(df)[1]   # Ex: "interaction(UF, Domicilio.{Bolsa.Familia})"
		)
		levels(df$Categoria) <- paste0(levels(df$Categoria), ".", nome)

		# remover a coluna de interação e reordenar as colunas criadas
		df[[1]] <- NULL   # coluna com a interação UF.Categoria
		df <- df[, c(4, 3, 1, 2)]
		return(df)
	}
	lista <- lapply(lista, dividir_interacao)

	# reformatar e criar lista com valores e cv's
	valores <- lapply(lista, function(df) reshape_wide(df[, -4]))
	lista_cvs <- lapply(lista, function(df) reshape_wide(df[, -3]))

	return(list(valores, lista_cvs))
}

ad_grupos_idade <- function(idade.var) {
	cut(
		idade.var,
		breaks = c(13, 17, 19, 24, 29, 39, 49, 59, Inf),
		labels = grupos_idade,
		right = TRUE
	)
}

# adiciona rendimento domiciliar per capita
ad_rdpc <- function(df, vars) {
	# criar colunas auxiliares, indicando se o morador entra no cálculo
	# da renda domiciliar e o número de moradores que está incluso no cálculo
	df$V2005.Rendimento <- ifelse(
		df$V2005 == "Pensionista" |
		df$V2005 == "Empregado(a) doméstico(a)" |
		df$V2005 == "Parente do(a) empregado(a) doméstico(a)",
		NA, 1
	)
	df$V2001.Rendimento <- ave(
		df$V2005.Rendimento,
		df$ID_DOMICILIO,
		FUN = function(x) sum(x, na.rm=T)
	)
	# loop para criar as colunas
	for (v in vars) {
		# renda domiciliar
		renda_dom <- ave(
			df[[v]],
			df$ID_DOMICILIO,
			FUN = function(x) sum(x, na.rm = TRUE)
		)
		# adicionar ".DPC" como sufixo no nome da coluna
		col_name <- paste0(v, ".DPC")
		# criar coluna com a renda domiciliar per capita
		df[[col_name]] <- ifelse(
			df$V2005.Rendimento == 1,
			renda_dom / df$V2001.Rendimento,
			NA
		)
	}
	return(df)
}

# `faixas` : coluna com as faixas simples
# `limites`: lista com os limites superiores por UF
ad_classes_simples <- function(renda, geo, quantis) {

	# garantir que os CV's não estão inclusos
	quantis <- quantis[1:13]

	# criar listas com um item por unidade territorial
	renda_geo <- split(renda, geo)
	quantis_geo <- split(quantis[, -1], quantis[[1]])
	quantis_geo <- lapply(quantis_geo, as.numeric)

	classes_geo <- Map(
		function(renda, quantis) {
			cut(
				renda,
				breaks = c(-Inf, quantis, Inf),
				labels = classes_simples,
				right = FALSE
			)
		},
		renda_geo,
		quantis_geo
	)
	
	resultado <- unsplit(classes_geo, geo)
	return(resultado)
}

acumular_rme <- function(rme, pop) {
	rme_uf <- split(rme[, -1], rme[[1]])
	pop_uf <- split(pop[, -1], pop[[1]])

	rme_acumul_uf <- Map(
		function(rme, pop) cumsum(rme * t(pop)) / cumsum(t(pop)),
		rme_uf,
		pop_uf
	)

	resultado <- data.frame(
		unidades_federativas,
		do.call(rbind, rme_acumul_uf)
	)
	rownames(resultado) <- NULL
	colnames(resultado) <- c("UF", classes_acumuladas)

	return(resultado)
}

# adicionar variáveis deflacionadas
deflacionar <- function(df, vars) {

	deflacionar_ano <- function(df, ano.base) {
		# criar loop entre as variáveis de rendimento
		for (v in vars) {
			# deflatores diferentes para rendimentos habituais/efetivos
			if (v == "VD4019") {
				deflator <- paste0("CO", ano.base)
			} else {
				deflator <- paste0("CO", ano.base, "e")
			}
			# adicionar variável deflacionada ao dataframe
			col_name <- paste0(v, ".Real", ano.base)
			df[[col_name]] <- df[[v]] * df[[deflator]]
		}
		return(df)
	}

	df <- deflacionar_ano(df, ano.base = 1)
	df <- deflacionar_ano(df, ano.base = 2)

	return(df)
}
