# Reproduz tabelas SIDRA para os dez estratos geográficos de Minas Gerais.
# Tema: Rendimento de todas as fontes (PNAD contínua anual, 1a visita*).
# : 7429, 7431, 7434, 7435, 7441, 7442, 7443, 7444,
#          7446, 7453, 7457, 7531, 7538, 7548, 7559, 7562.
# série: 2012 a 2023.

# *Nos anos de 2020 e 2021, o SIDRA usou a 5a visita.
# *Preços deflacionados para 2023, utilizando CO1 e CO1e (consultar nota técnica).

# ---------------------------------------------------------------------
# PREPARAR AMBIENTE

pacotes <- c("PNADcIBGE", "survey", "convey", "openxlsx")
#install.packages(setdiff(pacotes, rownames(installed.packages())))
lapply(pacotes, library, character.only = TRUE)

# carregar objetos e funções utilizados no script:
source("utilitarios.R")

# pasta onde as tabelas serão salvas
saida <- "saida/serie_historica/"

# ---------------------------------------------------------------------
# IMPORTAR E PREPARAR DADOS

serie <- 2012:2023
tabelas <- c(7429, 7431, 7434, 7435, 7441, 7442, 7443, 7444,
	7446, 7453, 7457, 7531, 7538, 7548, 7559, 7562)

# Adicionar colunas de rendimento
lista_desenhos <- lapply(serie, function(ano) {
	desenho <- gerar_desenho(ano, tabelas)
	
	# programas sociais, seguro-desemprego, bolsa de estudos, aplicações, etc
	# variáveis indisponíveis para antes de 2015
	if (ano > 2014) {
		desenho$variables <- transform(
			desenho$variables,
			Outros.Rendimentos = rowSums(
				cbind(V5001A2, V5002A2, V5003A2, V5005A2, V5008A2),
				na.rm = TRUE
			)
		)
		desenho$variables <- transform(
			desenho$variables,
			Outros.Rendimentos = ifelse(
				Outros.Rendimentos == 0,
				NA, Outros.Rendimentos
			)
		)
	}

	# deflacionar
	desenho$variables <- transform(
		desenho$variables,
		VD4019.Real = VD4019 * CO1,    # habitualmente recebido de trabalho
		VD4020.Real = VD4020 * CO1e,   # efetivamente recebido de trabalho
		VD4048.Real = VD4048 * CO1e    # efetivamente recebido de outras fontes
	)
	desenho$variables <- transform(    # recebido de todas as fontes
		desenho$variables,
		VD4052.Real = rowSums(
			cbind(VD4019.Real, VD4048.Real),
			na.rm = TRUE
		)
	)

	# domiciliar per capita
	tipos_rend <- c("VD4019", "VD4048", "VD4052.Real")
	if (ano > 2014) { 
		tipos_rend <- c(tipos_rend, "V5004A2", "Outros.Rendimentos")
	}
	desenho$variables <- ad_rdpc(desenho$variables, tipos_rend)
	desenho$variables$VD5008.Real <- desenho$variables$VD4052.Real.DPC
	desenho$variables$VD4052.Real.DPC <- NULL
	
	return(desenho)
})

# Adicionar colunas de categorias

# classes simples
limites_vd5008 <- vector("list", length(serie))
names(limites_vd5008) <- paste0("limites_", serie)
limites_vd5008 <- lapply(
	lista_desenhos, function(desenho) {
		estimar_quantis(desenho, formula = ~VD5008.Real)
	}
)

limites_vd4019 <- vector("list", length(serie))
names(limites_vd4019) <- paste0("limites_", serie)
limites_vd4019 <- lapply(
	lista_desenhos,
	function(desenho) estimar_quantis(desenho, formula = ~VD4019.Real)
)

limites_vd4020 <- vector("list", length(serie))
names(limites_vd4020) <- paste0("limites_", serie)
limites_vd4020 <- lapply(
	lista_desenhos, function(desenho) {
		estimar_quantis(desenho, formula = ~VD4020.Real)
	}
)

lista_desenhos <- lapply(seq_along(lista_desenhos), function(idx) {
	desenho <- lista_desenhos[[idx]]

	desenho$variables <- transform(
		desenho$variables,
		VD5008.Classe = ad_classes_simples(
			renda = VD5008.Real,
			geo = Estrato.Geo,
			limites = limites_vd5008[[idx]]
		),
		VD4019.Classe = ad_classes_simples(
			VD4019.Real,
			Estrato.Geo,
			limites_vd4019[[idx]]
		),
		VD4020.Classe = ad_classes_simples(
			VD4019.Real,
			Estrato.Geo,
			limites_vd4020[[idx]]
		)
	)

	return(desenho)
})

# grupos de idade, níveis de instrução, cor/raça e ocupação
lista_desenhos <- lapply(lista_desenhos, function(desenho) {

	desenho$variables <- transform(
		desenho$variables,
		Grupo.de.Idade = ad_grupos_idade(idade = V2009)
	)

	niveis_vd3004 <- levels(desenho$variables$VD3004)
	desenho$variables <- transform(
		desenho$variables,
		Nivel.de.Instrucao = factor(
			cases(
				VD3004 %in% niveis_vd3004[1:2], niveis_instrucao[1],
				VD3004 %in% niveis_vd3004[3:4], niveis_instrucao[2],
				VD3004 %in% niveis_vd3004[5:6], niveis_instrucao[3],
				VD3004 %in% niveis_vd3004[6],   niveis_instrucao[4]
			)
		)
	)
	
	desenho$variables <- transform(
		desenho$variables,
		Cor.ou.Raca = factor(
			cases(
				V2010 %in% c("Preta", "Parda"), "Negra",
				V2010 == "Branca", "Branca",
				TRUE, "Outra"
			)
		)
	)

	desenho$variables <- transform(
		desenho$variables,
		Pessoa.Ocupada = ifelse(VD4019 > 0, 1, 0)
	)

	return(desenho)
})

# programas socias
lista_desenhos <- lapply(lista_desenhos, function(desenho) {

	variaveis_necessarias <- c("V5001A", "V5002A", "V5003A")
	if(!all(variaveis_necessarias %in% names(desenho$variables))) {
		return(desenho)
	}

	# indica se ao menos um morador do domicílio recebe Bolsa Família
	desenho$variables <- transform(
		desenho$variables,
		Domicilio.Bolsa.Familia = factor(
			ifelse(
				ID_DOMICILIO %in% unique(ID_DOMICILIO[V5002A == "Sim"]),
				"Sim", "Não"
			),
			levels = c("Sim", "Não")
		)
	)

	desenho$variables <- transform(
		desenho$variables,
		Domicilio.BPC = factor(
			ifelse(
				ID_DOMICILIO %in% unique(ID_DOMICILIO[V5001A == "Sim"]),
				"Sim", "Não"
			),
			levels = c("Sim", "Não")
		)
	)

	desenho$variables <- transform(
		desenho$variables,
		Domicilio.Outros.Programas = factor(
			ifelse(
				ID_DOMICILIO %in% unique(ID_DOMICILIO[V5003A == "Sim"]),
				"Sim", "Não"
			),
			levels = c("Sim", "Não")
		)
	)

	return(desenho)
})

names(lista_desenhos) <- paste0("desenho_", serie)

# ---------------------------------------------------------------------
# REPRODUZIR TABELAS

# 7429 - participação % de cada fonte no rendimento médio domiciliar per capita
tab_7429 <- lapply(lista_desenhos, function(desenho){

	variaveis_necessarias <- c("V5001A", "V5002A", "V5003A")
	if(!all(variaveis_necessarias %in% names(desenho$variables))) {
		return(NULL)
	}

	part_rdpc <- svyby(
		~VD5008 + VD4019.DPC + VD4048.DPC + V5004A2.DPC + Outros.Rendimentos.DPC,
		by = ~Estrato.Geo,
		denominator = ~VD5008,
		design = subset(desenho, V2005.Rendimento == 1),
		FUN = svyratio,
		vartype = "cv",
		keep.names = FALSE,
		drop.empty.groups = FALSE,
		na.rm = TRUE
	)

	tabela <- part_rdpc[c(1, 2:6)]
	coeficiente <- part_rdpc[c(1, 7:11)]

	colnames(tabela)[-1] <- c(fontes_rendimento[c(1, 2, 4, 5, 8)])
	colnames(coeficientes)[-1] <- c(fontes_rendimento[c(1, 2, 4, 5, 8)])

	return(list(tabela, coeficientes))
})
names(tab_7429) <- paste0("sidra_", serie)

# 7431 - população ocupada por cor/raça
tab_7431 <- lapply(lista_desenhos, function(desenho){

	ocupada_cor <- estimar_totais(
		desenho = subset(desenho, Pessoa.Ocupada == 1),
		formula = ~Cor.ou.Raca
	)

	tabela <- ocupada_cor[, c(1, 2:4)]
	coeficiente <- ocupada_cor[, c(1, 5:7)]

	colnames(tabela)[-1] <- c("Branca", "Negra", "Outra")
	colnames(coeficientes)[-1] <- ("Branca", "Negra", "Outra")

	return(list(tabela, coeficientes))
})
names(tab_7431) <- paste0("sidra_", serie)

# 7434 - população ocupada por V2007, sexo
tab_7434 <- lapply(lista_desenhos, function(desenho){

	ocupada_sexo <- estimar_totais(
		subset(desenho, Pessoa.Ocupada == 1),
		~V2007
	)

	tabela <- data.frame(
		"Estrato Geografico" = estratos_geo,
		"Homens" = ocupada_sexo[[2]],
		"Mulheres" = ocupada_sexo[[3]]
	)

	coeficientes <- data.frame(
		"Estrato Geografico" = estratos_geo,
		"Homens" = ocupada_sexo[[4]],
		"Mulheres" = ocupada_sexo[[5]]
	)

	return(list(tabela, coeficientes))
})
names(tab_7434) <- paste0("sidra_", serie)

# 7435 - valores próximos, iguais arredondando
tab_7435 <- lapply(lista_desenhos, function(desenho){

	gini_vd5008real <- svyby(
		~VD5008.Real,
		~Estrato.Geo,
		subset(desenho, V2005.Rendimento == 1),
		FUN = svygini,
		keep.names = FALSE,	
		vartype = "cv",
		na.rm = TRUE
	)

	tabela <- gini_vd5008real[, -3]
	colnames(tabela) <- c("Estrato Geografico", "Valor")

	coeficientes <- gini_vd5008real[, -2]
	colnames(coeficientes) <- c("Estrato Geografico", "cv")

	return(list(tabela, coeficientes))
})
names(tab_7435) <- paste0("sidra_", serie)

# 7441 - Rendimento médio real por cor ou raça
tab_7441 <- lapply(lista_desenhos, function(desenho){
	
	rme_cor <- estimar_medias(
		subset(
			desenho,
			VD4019 > 0 & Cor.ou.Raca != "Outra"
		),
		~VD4019.Real,
		~Cor.ou.Raca
	)
	rme_cor <- subset(rme_cor, Cor.ou.Raca != "Outra")
	rme_cor$Cor.ou.Raca <- droplevels(rme_cor$Cor.ou.Raca)

	tabela <- reshape_wide(rme_cor[, -4])
	coeficientes  <- reshape_wide(rme_cor[, -3])

	return(list(tabela, coeficientes))
})
names(tab_7441) <- paste0("sidra_", serie)

# 7442 - Rendimento médio real por grupo de idade
tab_7442 <- lapply(lista_desenhos, function(desenho){

	rme_idade <- estimar_medias(
		subset(desenho, VD4019 > 0),
		~VD4019.Real,
		~Grupo.de.Idade
	)

	tabela <- reshape_wide(rme_idade[, -4])
	coeficientes  <- reshape_wide(rme_idade[, -3])

	return(list(tabela, coeficientes))
})
names(tab_7442) <- paste0("sidra_", serie)

# 7443 - Rendimento médio real por nível de instrução
tab_7443 <- lapply(lista_desenhos, function(desenho){

	rme_instrucao <- estimar_medias(
		subset(desenho, VD4019 > 0),
		~VD4019.Real,
		~Nivel.de.Instrucao
	)
	levels(rme_instrucao) <- niveis_instrucao

	tabela <- reshape_wide(rme_instrucao[, -4])
	coeficientes  <- reshape_wide(rme_instrucao[, -3])

	return(list(tabela, coeficientes))
})
names(tab_7443) <- paste0("sidra_", serie)

# 7444 - Rendimento médio real por sexo
tab_7444 <- lapply(lista_desenhos, function(desenho){

	rme_sexo <- estimar_medias(
		subset(desenho, VD4019 > 0),
		~VD4019.Real,
		~V2007
	)

	tabela <- reshape_wide(rme_sexo[-4])
	coeficientes  <- reshape_wide(rme_sexo[-3])

	return(list(tabela, coeficientes))
})
names(tab_7444) <- paste0("sidra_", serie)

# 7446 - Rendimento médio real de pessoas responsáveis pelo domícilio
tab_7446 <- lapply(lista_desenhos, function(desenho){

	rme_responsavel <- estimar_medias(
		subset(
			desenho,
			VD4019 > 0 & V2005 == "Pessoa responsável pelo domicílio"
		),
		~VD4019.Real
	)

	tabela <- rme_responsavel
	colnames(tabela) <- c("Estrato Geografico", "Rendimento")

	coeficientes <- rme_responsavel[, -2]
	colnames(coeficientes) <- c("Estrato Geografico", "cv")

	return(list(tabela, coeficientes))
})
names(tab_7446) <- paste0("sidra_", serie)

# 7453 - Índice de Gini do rendimento médio habitualmente recebido
tab_7453 <- lapply(lista_desenhos, function(desenho){

	gini_vd4019RMe <- svyby(
		~VD4019.Real,
		~Estrato.Geo,
		desenho,
		FUN = svygini,
		vartype = "cv",
		keep.names = FALSE,
		na.rm = TRUE
	)

	tabela <- gini_vd4019RMe[, -3]
	colnames(tabela) <- c("Estrato Geografico", "Indice.de.Gini")

	coeficientes <- gini_vd4019RMe[, -2]
	colnames(coeficientes) <- c("Estrato Geografico", "cv")

	return(list(tabela, coeficientes))
})
names(tab_7453) <- paste0("sidra_", serie)

# 7457 - Total de domicílios, por recebimento e tipo de programa social
tab_7457 <- lapply(lista_desenhos, function(desenho){

	variaveis_necessarias <- c("V5001A", "V5002A", "V5003A")
	if(!all(variaveis_necessarias %in% names(desenho$variables))) {
		return(NULL)
	}

	dom_progs <- estimar_interacao(
		subset(desenho, V2005 == "Pessoa responsável pelo domicílio"),
		~V2005 == "Pessoa responsável pelo domicílio",
		FUN = svytotal,
		c("Domicilio.Bolsa.Familia", "Domicilio.BPC", "Domicilio.Outros.Programas")
	)
	# remover colunas em que o teste foi FALSE
	dom_progs <- lapply(dom_progs, `[`, c(-2, -4))
	dom_progs <- agrupar_progs(dom_progs)

	tabela <- Reduce(
		function(...) merge(..., sort = FALSE),
		dom_progs[[1]]
	)
	coeficientes  <- Reduce(
		function(...) merge(..., sort = FALSE),
		dom_progs[[2]]
	)

	return(list(tabela, coeficientes))
})
names(tab_7457) <- paste0("sidra_", serie)

# 7531 - RMe real domiciliar per capita, por classe simples
tab_7531 <- lapply(lista_desenhos, function(desenho){

	rme_vd5008classe <- estimar_medias(
		subset(desenho, V2005.Rendimento == 1),
		~VD5008.Real,
		~VD5008.Classe
	)

	tabela <- reshape_wide(rme_vd5008classe[, -4])
	coeficientes  <- reshape_wide(rme_vd5008classe[, -3])

	return(list(tabela, coeficientes))
})
names(tab_7531) <- paste0("sidra_", serie)

# 7538 - Rendimento habitual médio por classe acumulada de percentual
tab_7538 <- lapply(lista_desenhos, function(desenho){

	rme_vd4019cap <- estimar_cap(
		desenho = subset(desenho, VD4019 > 0),
		formula = ~VD4019.Real,
		csp = "VD4019.Classe"
	)

	tabela <- rme_vd4019cap[[1]]
	coeficientes  <- rme_vd4019cap[[2]]

	return(list(tabela, coeficientes))
})
names(tab_7538) <- paste0("sidra_", serie)

# 7548 - Rendimento habitual médio por classe acumulada de percentual
tab_7548 <- lapply(lista_desenhos, function(desenho){

	rme_vd4020cap <- estimar_cap(
		subset(desenho, VD4020 > 0),
		~VD4020.Real,
		"VD4020.Classe"
	)

	tabela <- rme_vd4020cap[[1]]
	coeficientes  <- rme_vd4020cap[[2]]

	return(list(tabela, coeficientes))
})
names(tab_7548) <- paste0("sidra_", serie)

# 7559 - população por classe acumulada de rendimento efetivo
tab_7559 <- lapply(lista_desenhos, function(desenho){

	ocupada_csp_e <- estimar_totais(desenho, ~VD4020.Classe)
	ocupada_cap_e <- vector("list", 13)
	ocupada_cap_e[[1]] <- ocupada_csp_e[, c(2, 15)]

	for (i in 2:13) {
		sub_desenho <- subset(
			desenho,
			VD4020.Classe %in% classes_simples[1:i]
		)
	    estimativa <- svytotal(~Estrato.Geo, sub_desenho, na.rm = TRUE)
	    ocupada_cap_e[[i]] <- cbind(estimativa, cv(estimativa))
	    colnames(ocupada_cap_e[[i]]) <- c(classes_acumuladas[i], "cv")
	}
	rm(sub_desenho, estimativa)

	tabela <- data.frame(
		estratos_geo,
		do.call(cbind, lapply(ocupada_cap_e, function(x) x[, 1]))
	)
	colnames(tabela) <- c("Estrato Geografico", classes_acumuladas)

	coeficientes <- data.frame(
		estratos_geo,
		do.call(cbind, lapply(ocupada_cap_e, function(x) x[, 2]))
	)
	colnames(coeficientes) <- c("Estrato Geografico", classes_acumuladas)

	return(list(tabela, coeficientes))
})
names(tab_7559) <- paste0("sidra_", serie)

# 7562 - população por classe acumulada de rendimento habitual
tab_7562 <- lapply(lista_desenhos, function(desenho){

	ocupada_csp_h <- estimar_totais(desenho, ~VD4019.Classe)
	ocupada_cap_h <- vector("list", 13)
	ocupada_cap_h[[1]] <- ocupada_csp_h[, c(2, 15)]

	for (i in 2:13) {
		sub_desenho <- subset(
			desenho,
			VD4019.Classe %in% classes_simples[1:i]
		)
	    estimativa <- svytotal(~Estrato.Geo, sub_desenho, na.rm = TRUE)
	    ocupada_cap_h[[i]] <- cbind(estimativa, cv(estimativa))
	    colnames(ocupada_cap_h[[i]]) <- c(classes_acumuladas[i], "cv")
	}
	rm(sub_desenho, estimativa)

	tabela <- data.frame(
		estratos_geo,
		do.call(cbind, lapply(ocupada_cap_h, function(x) x[, 1]))
	)
	colnames(tabela) <- c("Estrato Geografico", classes_acumuladas)

	coeficientes <- data.frame(
		estratos_geo,
		do.call(cbind, lapply(ocupada_cap_h, function(x) x[, 2]))
	)
	colnames(coeficientes) <- c("Estrato Geografico", classes_acumuladas)

	return(list(tabela, coeficientes))
})
names(tab_7562) <- paste0("sidra_", serie)

# ---------------------------------------------------------------------
# FORMATAR TABELAS

nomes_sidra <- ls(pattern = "^tab_7")
nomes_pop <- c("tab_7431", "tab_7434", "tab_7559", "tab_7562")
nomes_porcent <- c("tab_7429", "tab_7435", "tab_7453")

for (nome in nomes_sidra) {
	sidra <- get(nome)

	sidra <- lapply(sidra, function(ano) {

		if (is.null(ano)) return(NULL)

		ano[[1]] <- fmt_estrato(ano[[1]])
		ano[[2]] <- fmt_estrato(ano[[2]])

		ano[[2]] <- fmt_porcent(ano[[2]])

		if (nome %in% nomes_pop) {
			ano[[1]] <- fmt_pop(ano[[1]])
		}

		if (nome %in% nomes_porcent) {
			ano[[1]] <- fmt_porcent(ano[[1]])
		}

		if (!nome %in% c(nomes_pop, nomes_porcent)) {
			ano[[1]][, -1] <- round(ano[[1]][, -1], 0)
		}
		return(ano)
	})

	assign(nome, sidra)
}

# ---------------------------------------------------------------------
# SALVAR TABELAS
 
openxlsx_setOp("keepNA", TRUE)
openxlsx_setOp("na.string", "-")

for (nome in nomes_sidra) {
	sidra <- get(nome)
	wb <- createWorkbook()
	estilo_cv_alto <- createStyle(fontColour = "#9C0006", bgFill = "#FFC7CE")

	for (i in seq_along(serie)) {
		ano <- as.character(serie[i])
		sublista <- sidra[[i]]

		if (is.null(sublista)) next

		tabela <- sublista[[1]]
		coeficiente <- sublista[[2]]

		addWorksheet(wb, ano)
		writeData(wb, sheet = ano, x = tabela, startCol = 1, startRow = 1)
		start_cv <- nrow(tabela) + 3
		writeData(wb, ano, coeficientes, startCol = 1, startRow = start_cv)

		# Aplicar destaque em células com CV > 15%
		num_cols <- ncol(coeficientes)
		if (num_cols > 1) {
			for (col in 2:num_cols) {
				conditionalFormatting(
					wb, sheet = ano,
					cols = col,
					rows = (start_cv + 1):(start_cv + nrow(coeficientes)),
					rule = ">15",
					style = estilo_cv_alto,
					type = "expression"
				)
			}
		}
	}
	saveWorkbook(wb, file = paste0(saida, nome, ".xlsx"), overwrite = TRUE)
}
