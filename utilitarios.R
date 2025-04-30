# Funções e Objetos para serem utilizados interativamente ou de forma
# automatizada pelos demais scripts.
#
# João Paulo Gonzaga Garcia: joaopauloggarcia@gmail.com
#----------------------------------------------------------
# OBJETOS

# Caminhos
pnadc_ano <- 2023
entrada <- "entrada"
deflator  <- list.files(entrada, pattern = "^deflator", full.names = TRUE)

# Tabelas agrupadas por características em comum

# não precisam de deflatores
sem_deflator <- c("7426", "7431", "7432", "7433", "7434", "7436", "7439",
	"7447", "7448", "7449", "7450", "7451", "7452", "7454", "7455",
	"7456", "7457")

# categorias por fontes de rendimento (trabalho, outras fontes, etc)
tabelas_fontes <- c("7426", "7429", "7437")

# rendimento domicilar per capita a preços médios do ano
tabelas_RDPC <- c("7428", "7435", "7438", "7521",
                  "7531", "7532", "7561")

# rendimento médio mensal real de pessoas ocupadas
tabelas_RMe <- c("7453", "7535", "7538", "7545", "7548",
				 "7441", "7442", "7443", "7444", "7446")

# população ocupada por categoria (sexo, cor/raça, instrução, etc)
tabelas_ocupada <- c("7431", "7432", "7433", "7434", "7436",
                     "7439", "7536", "7537", "7546",
                     "7547", "7559", "7562") 

# população com domicílios em que alguém recebe benefícios
tabelas_progsociais <- c("7447", "7448", "7449", "7450",
                         "7451", "7452", "7454", "7455",
                         "7456", "7457")

# Objetos utilizados como rótulos para nomear colunas

estratos_geo <- c(
    "Belo Horizonte",                        # 3110
	"Entorno + Colar metropol. de BH",       # 3120 + 3130
	"Integrada de BSB em MG + Norte de MG",  # 3140 + 3154
	"Sul de Minas Gerais",                   # 3151
	"Triângulo Mineiro",                     # 3152
	"Zona da Mata",                          # 3153
	"Vale do Rio Doce",                      # 3155
	"Central de Minas Gerais "               # 3156
)

fontes_rendimento <- c(
	"Todas as Fontes",
	"Trabalho Hab.",
	"Trabalho Efet.",
	"Outras Fontes",
	"Aposentadoria",
	"Aluguel",
	"Pensão Alimenticia",
	"Outros Rendimentos"
)

percentis <- paste0("P", c(5, seq(10, 90, by = 10), 95, 99))

classes_simples <- c(
	"Até P5",
	"P5-P10",
	"P10-P20",
	"P20-P30",
	"P30-P40",
	"P40-P50",
	"P50-P60",
	"P60-P70",
	"P70-P80",
	"P80-P90",
	"P90-P95",
	"P95-P99",
	"P99+"
)

classes_acumuladas <- c(paste0("Até ", percentis), "Total")

#grupos_idade = c(
#	"14-17",
#	"18-19",
#	"20-24",
#	"25-29",
#	"30-39",
#	"40-49",
#	"50-59",
#	"60+"
#)

grupos_idade = c(
	"14-17",
	"18-24",
	"25-39",
	"40-49",
	"50+"
)

#niveis_instrucao = c(
#	"Sem instrucao",
#	"Fund. incompleto",
#	"Fund. completo",
#	"Medio incompleto",
#	"Medio completo",
#	"Sup. incompleto",
#	"Sup. completo"
#)

niveis_instrucao = c(
	"Sem instrucao + Fund. incompleto",
	"Fund. completo + Medio incompleto",
	"Medio completo + Sup. incompleto",
	"Sup. completo"
)

# Lista com variáveis por tabela
variaveis <- list(
	tab_7426 = c("V5001A2", "V5002A2", "V5003A2", "V5004A2",
                 "V5005A2", "V5006A2", "V5007A2", "V5008A2",
                 "VD5008", "VD4019",  "VD4020",  "VD4048", 
                 "VD4052", "V2001",   "V2005"),
	tab_7427 = c("V2005", "VD4019", "VD4048"),
	tab_7428 = c("V2005", "VD4019", "VD4048"),
	tab_7429 = c("V5001A2", "V5002A2", "V5003A2", "V5004A2",
                 "V5005A2", "V5008A2", "VD4019",  "VD4048",
                 "VD5008", "V2001", "V2005"),
	tab_7430 = c("VD4019", "VD4020"),
	tab_7431 = c("VD4019", "V2010"),
	tab_7432 = c("V2009", "VD4002", "VD4052"),
	tab_7433 = c("V2009", "VD4002", "VD4052", "VD3004"),
	tab_7434 = c("VD4019", "V2007"),
	tab_7435 = c("V2001", "V2005", "VD4019", "VD4048"),
	tab_7436 = c(),
	tab_7437 = c("V5001A2", "V5002A2", "V5003A2", "V5004A2",
                 "V5005A2", "V5006A2", "V5007A2", "V5008A2",
                 "VD4019",  "VD4020",  "VD4048",  "VD4052",
                 "V2001",   "V2005"),
	tab_7438 = c("V2005", "VD4019", "VD4048"),
	tab_7439 = c("V2009", "VD4002", "VD4052", "V2005"),
	tab_7441 = c("VD4019", "V2010"),
	tab_7442 = c("VD4019", "V2009"),
	tab_7443 = c("VD4019", "VD3004"),
	tab_7444 = c("VD4019", "V2007"),
	tab_7445 = c("V1023", "VD4019", "VD4020"),
	tab_7446 = c("VD4019", "V2005"),
	tab_7447 = c("V2009", "VD3004", "V5002A"),
	tab_7448 = c("VD3004", "V5002A"),
	tab_7449 = c("V2005",  "V5001A", "V5002A",  "V5003A",
                 "VD3004", "S01007", "S01012A", "S01013",
                 "S01014", "S01023", "S01024",  "S01025",
                 "S01028"),
	tab_7450 = c("V5002A"),
	tab_7451 = c("V5001A"),
	tab_7452 = c("V5001A"),
	tab_7453 = c("VD4019"),
	tab_7454 = c("VD3004", "V5001A"),
	tab_7455 = c("VD3004", "V5001A"),
	tab_7456 = c("V2001", "V5001A", "V5002A", "V5003A"),
	tab_7457 = c("V5001A", "V5002A", "V5003A", "V2005"),
	tab_7458 = c("V2005", "VD4019", "VD4048", "V5001A", "V5002A", "V5003A"),
	tab_7521 = c("VD4019", "VD4048"),
	tab_7526 = c("V2005", "VD4019", "VD4048"),
	tab_7527 = c("V2005", "VD4019", "VD4048"),
	tab_7529 = c("V2005", "VD4019", "VD4048"),
	tab_7530 = c("V2005", "VD4019", "VD4048"),
	tab_7531 = c("V2001", "V2005", "VD4019", "VD4048"),
	tab_7532 = c("V2005", "VD4019", "VD4048"),
	tab_7533 = c("V2005", "VD4019", "VD4048"),
	tab_7534 = c("V2005", "VD4019", "VD4048"),
	tab_7535 = c("VD4019"),
	tab_7536 = c("VD4019"),
	tab_7537 = c("V2009", "VD4002", "VD4052", "VD4019"),
	tab_7538 = c("VD4019"),
	tab_7539 = c("VD4019"),
	tab_7540 = c("VD4019"),
	tab_7541 = c("V2009", "VD4002", "VD4052", "VD4019"),
	tab_7542 = c("VD4019"),
	tab_7543 = c("V2009", "VD4002", "VD4019"),
	tab_7544 = c("V2009", "VD4002", "VD4019"),
	tab_7545 = c("VD4020"),
	tab_7546 = c("V2009", "VD4002", "VD4052", "VD4020"),
	tab_7547 = c("V2009", "VD4002", "VD4052", "VD4020"),
	tab_7548 = c("VD4020"),
	tab_7549 = c("VD4019"),
	tab_7550 = c("VD4019"),
	tab_7551 = c("VD4019"),
	tab_7552 = c("VD4019"),
	tab_7553 = c("V2009", "VD4002", "VD4020"),
	tab_7554 = c("V2009", "VD4002", "VD4020"),
	tab_7559 = c("VD4020"),
	tab_7560 = c("V2009", "VD4002", "VD4052", "VD4020"),
	tab_7561 = c("V2005", "VD4019", "VD4048"),
	tab_7562 = c("VD4019"),
	tab_7563 = c("V2009", "VD4002", "VD4052", "VD4019"),
	tab_7564 = c("V2005", "VD4019", "VD4048")
)

#----------------------------------------------------------
# FUNÇÕES

# abreviar a função svyby()
estimar_por <- function(desenho, formula, por = ~Estrato.Geo, FUN) {

	estimativa <- svyby(
		formula = as.formula(formula),
		by = update.formula(por, ~ . + Estrato.Geo),
		design = desenho,
		FUN = FUN,
		vartype = "cv",
		keep.names = FALSE,
		drop.empty.groups = FALSE,
		na.rm = TRUE
	)
	levels(estimativa$Estrato.Geo) <- c(
		levels(estimativa$Estrato.Geo),
		"Minas Gerais"
	)

	if (por == ~Estrato.Geo) {
		por <- ~UF
	}
	estimativa_mg <- svyby(
		formula = as.formula(formula),
		by = update.formula(por, ~ . + UF),
		design = desenho,
		FUN = FUN,
		vartype = "cv",
		keep.names = FALSE,
		drop.empty.groups = FALSE,
		na.rm = TRUE
	)
	colnames(por_mg) <- colnames(por_estrato)

	resultado <- rbind(por_estrato, por_mg)

	return(resultado)
}


# estimar totais por Estrato.Geo
estimar_totais <- function(desenho, formula, por) {
	estimar_por(desenho, formula, por, FUN = svytotal)
}

# estimar médias por Estrato.Geo
estimar_medias <- function(desenho, formula, por = ~Estrato.Geo) {
	estimar_por(desenho, formula, por, FUN = svymean)
}

# estimar quantis das classes percentuais simples e Estrato.Geo
estimar_quantis <- function(desenho, formula) {
	estimar_por(desenho, formula, por, FUN = svyquantile)
}

estimar_cap <- function(desenho, formula, csp) {

	cap_list <- vector("list", 13)
	for (i in 1:13) {
	    sub_desenho <- subset(desenho, get(csp) %in% classes_simples[1:i])
	    cap_list[[i]] <- estimar_medias(sub_desenho, formula)
	}

	# agrupar valores e CV's dos data frames da lista
	valores <- data.frame(
		c(estratos_geo, "Minas Gerais"),
		do.call(cbind, lapply(cap_list, `[`, 2))
	)
	cvs <- data.frame(
		c(estratos_geo, "Minas Gerais"),
		do.call(cbind, lapply(cap_list, `[`, 3))
	)

	colnames(valores) <- c("Região", classes_acumuladas)
	colnames(cvs) <- c("Região", classes_acumuladas)

	return(list(valores, cvs))
}

estimar_interacao <- function(desenho, formula, FUN, vars) {

	# preparar fórmula com a interação Estrato x Programas
	interacao <- reformulate(
		sapply(
			vars,
			function(v) paste0("interaction(Estrato.Geo, ", v, ")")
		),
		response = NULL
	)

	svybys(
		design = desenho,
		formula = formula,
		bys = interacao,
		FUN = FUN,
		vartype = "cv",
		keep.names = FALSE,
		drop.empty.groups = FALSE,
		na.rm = TRUE
	)
}

# formatar tabelas SIDRA
fmt_estrato <- function(df) {
	df[[1]] <- estratos_geo
	colnames(df)[1] <- "Região"
	return(df)
}
fmt_porcent <- function(df) {
	df[, -1] <- round(df[, -1] * 100, 2)
	return(df)
}
fmt_pop <- function(df) {
	df$Total <- rowSums(df[, -1])
	df[, -1] <- round(df[, -1] / 1000, 0)
	return(df)
}

# reformatar dataframes, criando uma coluna para cada categoria da variável
reshape_wide <- function(df, timevar_pos = 1) {
	# usar reshape para passar para o formato wide
	resultado <- reshape(
		df, direction = "wide",
		idvar =  "Estrato.Geo",
		timevar = colnames(df)[timevar_pos]
	)
	# adicionar os nomes das colunas e excluir nomes de linhas
	colnames(resultado) <- c("Estrato Geografico", levels(df[[timevar_pos]]))
	rownames(resultado) <- NULL
	return(resultado)
}

# dividir colunas de interação criadas por svybys()  ex: dividir
# "Pará.Sim" em "Pará" e "Sim"  e então reagrupar os dataframes da
# lista gerada usando reshape_wide(), funcção criada acima.
agrupar_progs <- function(lista) {

	# função que será aplicada a cada item da lista gerada por svyby()
	dividir_interacao <- function(df) {

		# adicionar as duas colunas que formam a interação
		df$Estrato.Geo <- rep(estratos_geo, times = 2)
		df$Categoria <- factor(
			rep(c("Sim", "Não"), each = length(estratos_geo)),
			levels = c("Sim", "Não")
		)

		# remover a coluna de interação e reordenar as colunas criadas
		df[[1]] <- NULL   # coluna com a interação Estrato x Categoria
		df <- df[, c(4, 3, 1, 2)]
		return(df)
	}
	lista <- lapply(lista, dividir_interacao)

	# adicionar o nome do programa social às colunas
	levels(lista[[1]]$Categoria) <- paste0("Bolsa.Familia", ".", c("Sim", "Não"))
	levels(lista[[2]]$Categoria) <- paste0("BPC", ".", c("Sim", "Não"))
	levels(lista[[3]]$Categoria) <- paste0("Outros", ".", c("Sim", "Não"))

	# reformatar e criar lista com valores e cv's
	valores <- lapply(lista, function(df) reshape_wide(df[, -4]))
	cv_list <- lapply(lista, function(df) reshape_wide(df[, -3]))

	return(list(valores, cv_list))
}

# `faixas` : coluna com as faixas simples
# `limites`: lista com os limites superiores por Estrato.Geo
ad_classes_simples <- function(renda, geo, limites) {

	# garantir que os CV's não estão inclusos
	limites <- limites[1:13]

	# criar listas com um item por unidade territorial
	renda_geo <- split(renda, geo)
	limites_geo <- split(limites[, -1], limites[[1]])
	limites_geo <- lapply(limites_geo, as.numeric)

	classes_geo <- Map(
		function(y, lim) {
			cut(
				y,
				breaks = c(-Inf, lim, Inf),
				labels = classes_simples,
				right = FALSE,
				include.lowest = TRUE
			)
		},
		renda_geo,
		limites_geo
	)
	
	resultado <- unsplit(classes_geo, geo)
	return(resultado)
}

ad_grupos_idade <- function(idade) {
	cut(
		idade,
		breaks = c(13, 17, 24, 39, 49, Inf),
		#breaks = c(13, 17, 19, 24, 29, 39, 49, 59, Inf),
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
		FUN = function(x) sum(x, na.rm = TRUE)
	)
	# loop para criar as colunas
	for (v in vars) {
		# renda domiciliar
		renda <- ifelse(df$V2005.Rendimento == 1, df[[v]], NA)
		renda_dom <- ave(
			renda,
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

# aplica vários casos de ifelse() - similar a kit::niif e dplyr::case_when
cases <- function(...) {
	conditions <- list(...)
	n <- length(conditions)

	if (n %% 2 != 0) {
		stop("Padrão esperado: cond1, resultado1, cond2, resultado2, ...")
	}

	conds <- conditions[seq(1, n, by = 2)]
	results <- conditions[seq(2, n, by = 2)]
	out <- rep(NA, length(conds[[1]]))

	for (i in seq_along(conds)) {
		out <- ifelse(conds[[i]] & is.na(out), results[[i]], out)
	}

	return(out)
}

# gera desenho amostral
# `tabelas` : um vetor com número das tabelas cujas variáveis serão importadas;
# `ano`     : ano da pesquisa (numérico)
gerar_desenho <- function(ano = pnadc_ano, tabelas) {

	# importar dados da 1a visita, com exceção dos anos 2020 e 2021 (5a visita)
	visita <- ifelse(ano == 2020 | ano == 2021, 5, 1)

	# definir variáveis com base nas tabelas passadas como argumentos
	tabelas <- paste0("tab_", tabelas)
	variaveis <- unique(
		c(unlist(variaveis[tabelas]), "UF")
	)
	
	# incorporar deflatores de acordo com as tabelas desejadas (TRUE ou FALSE)
	requer_deflator <- length(setdiff(tabelas, sem_deflator)) > 0

	# ler os dados
	pnadc_dir <- file.path("entrada", ano)

	if (!dir.exists(pnadc_dir)) {

		dir.create(pnadc_dir, recursive = TRUE)
		desenho <- get_pnadc(
			year = pnadc_ano,
			interview = visita,
			design = FALSE,     # ver abaixo pnadc_design()
			vars = variaveis,
			deflator = requer_deflator,
			savedir = pnadc_dir
		)

	} else {

		microdados <- list.files(pnadc_dir, "^PNADC_.*txt$", full.names = TRUE)
		input <- list.files(pnadc_dir, "^input_PNADC_.*txt$", full.names = TRUE)
		dicionario <- list.files(
			pnadc_dir,
			"^dicionario_PNADC_microdados_.*xls$",
			full.names = TRUE
		)

		desenho <- read_pnadc(
			microdata = microdados,
			input = input,
			vars = variaveis
		)
		desenho <- pnadc_labeller(
			data_pnadc = desenho ,
			dictionary.file = dicionario
		)
		if (requer_deflator) {
			desenho <- pnadc_deflator(desenho, deflator.file = deflator)
		}
	}

	# gerar desenho amostral para MG, incluindo coluna com estratos geográficos
	desenho <- pnadc_design(subset(desenho, UF == "Minas Gerais"))
	desenho$variables$Estrato.Geo <- droplevels(desenho$variables$UF)
	desenho$variables <- transform(
		desenho$variables,
		Estrato.Geo = factor(substr(Estrato, 1, 4))
	)
	# agrupar Colar + Entorno e Integrada + Norte de Minas (respectivamente)
	desenho$variables <- transform(
		desenho$variables,
		Estrato.Geo = factor(
			ifelse(
				Estrato.Geo %in% c("3120", "3130"), "3120+3130",
				ifelse(
					Estrato.Geo %in% c("3140", "3154"), "3140+3154",
					as.character(Estrato.Geo)
				)
			)
		)
	)

	return(desenho)
}
