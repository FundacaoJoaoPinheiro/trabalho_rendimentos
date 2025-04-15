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

titulos <- c(
	"7429 - Participação das fontes no RMe domiciliar per capita",
	"7435 - Índice de Gini do rendimento domiciliar per capita",
	"7453 - Índice de Gini do rendimento médio habitualmente recebido",
	"7431 - População ocupada por cor/raça",
	"7434 - População ocupada por sexo",
	"7457 - Total de domicílios, por recebimento e tipo de programa social",
	"7559 - População por classe acumulada de rendimento efetivo",
	"7562 - População por classe acumulada de rendimento habitual",
	"7441 - Rendimento médio real por cor ou raça",
	"7442 - Rendimento médio real por grupo de idade",
	"7443 - Rendimento médio real por nível de instrução",
	"7444 - Rendimento médio real por sexo",
	"7446 - Rendimento médio real de pessoas responsáveis pelo domícilio",
	"7531 - RMe real domiciliar per capita, por classe simples de percentual",
	"7538 - Rendimento habitual médio por classe acumulada de percentual",
	"7548 - Rendimento habitual médio por classe acumulada de percentual"
)

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
limites_vd5008 <- lapply(
	lista_desenhos, function(desenho) {
		estimar_quantis(desenho, formula = ~VD5008.Real)
	}
)

limites_vd4019 <- lapply(
	lista_desenhos,
	function(desenho) estimar_quantis(desenho, formula = ~VD4019.Real)
)

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
			VD4020.Real,
			Estrato.Geo,
			limites_vd4020[[idx]]
		)
	)

	return(desenho)
})

# grupos de idade, níveis de instrução, cor/raça e ocupação
niveis_vd3004 <- levels(lista_desenhos[[1]][["variables"]][["VD3004"]])

lista_desenhos <- lapply(lista_desenhos, function(desenho) {

	desenho$variables <- transform(
		desenho$variables,
		Grupo.de.Idade = ad_grupos_idade(idade = V2009)
	)

	desenho$variables <- transform(
		desenho$variables,
		Nivel.de.Instrucao = factor(
			cases(
				VD3004 %in% niveis_vd3004[1:2], niveis_instrucao[1],
				VD3004 %in% niveis_vd3004[3:4], niveis_instrucao[2],
				VD3004 %in% niveis_vd3004[5:6], niveis_instrucao[3],
				VD3004 %in% niveis_vd3004[7],   niveis_instrucao[4]
			),
			levels = niveis_instrucao
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
	part_rdpc[2:6] <- round(part_rdpc[2:6] * 100, 2)    # porcentagem

	valores <- part_rdpc[c(1, 2:6)]
	coefvar <- part_rdpc[c(1, 7:11)]

	colnames(valores)[-1] <- c(fontes_rendimento[c(1, 2, 4, 5, 8)])
	colnames(coefvar)[-1] <- c(fontes_rendimento[c(1, 2, 4, 5, 8)])

	return(list(valores, coefvar))
})
names(tab_7429) <- paste0("sidra_", serie)

# 7431 - população ocupada por cor/raça
tab_7431 <- lapply(lista_desenhos, function(desenho){

	ocupada_cor <- estimar_totais(
		desenho = subset(desenho, Pessoa.Ocupada == 1),
		formula = ~Cor.ou.Raca
	)

	valores <- ocupada_cor[, c(1, 2:3)]
	coefvar <- ocupada_cor[, c(1, 5:6)]

	colnames(valores)[-1] <- c("Branca", "Negra")
	colnames(coefvar)[-1] <- c("Branca", "Negra")

	return(list(valores, coefvar))
})
names(tab_7431) <- paste0("sidra_", serie)

# 7434 - população ocupada por sexo
tab_7434 <- lapply(lista_desenhos, function(desenho){

	ocupada_sexo <- estimar_totais(
		subset(desenho, Pessoa.Ocupada == 1),
		~V2007
	)

	valores <- data.frame(
		"Estrato Geografico" = estratos_geo,
		"Homens" = ocupada_sexo[[2]],
		"Mulheres" = ocupada_sexo[[3]]
	)

	coefvar <- data.frame(
		"Estrato Geografico" = estratos_geo,
		"Homens" = ocupada_sexo[[4]],
		"Mulheres" = ocupada_sexo[[5]]
	)

	return(list(valores, coefvar))
})
names(tab_7434) <- paste0("sidra_", serie)

# 7435 - Índice de Gini do rendimento domiciliar p/ capita
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

	valores <- gini_vd5008real[, -3]
	colnames(valores) <- c("Estrato Geografico", "Indice de Gini")
	valores[[2]] <- round(valores[[2]], 3)

	coefvar <- gini_vd5008real[, -2]
	colnames(coefvar) <- c("Estrato Geografico", "cv")

	return(list(valores, coefvar))
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

	valores <- reshape_wide(rme_cor[, -4])
	coefvar <- reshape_wide(rme_cor[, -3])

	return(list(valores, coefvar))
})
names(tab_7441) <- paste0("sidra_", serie)

# 7442 - Rendimento médio real por grupo de idade
tab_7442 <- lapply(lista_desenhos, function(desenho){

	rme_idade <- estimar_medias(
		subset(desenho, VD4019 > 0),
		~VD4019.Real,
		~Grupo.de.Idade
	)

	valores <- reshape_wide(rme_idade[, -4])
	coefvar <- reshape_wide(rme_idade[, -3])

	return(list(valores, coefvar))
})
names(tab_7442) <- paste0("sidra_", serie)

# 7443 - Rendimento médio real por nível de instrução
tab_7443 <- lapply(lista_desenhos, function(desenho){

	rme_instrucao <- estimar_medias(
		subset(desenho, VD4019 > 0),
		~VD4019.Real,
		~Nivel.de.Instrucao
	)
	levels(rme_instrucao[1]) <- niveis_instrucao

	valores <- reshape_wide(rme_instrucao[, -4])
	coefvar <- reshape_wide(rme_instrucao[, -3])

	return(list(valores, coefvar))
})
names(tab_7443) <- paste0("sidra_", serie)

# 7444 - Rendimento médio real por sexo
tab_7444 <- lapply(lista_desenhos, function(desenho){

	rme_sexo <- estimar_medias(
		subset(desenho, VD4019 > 0),
		~VD4019.Real,
		~V2007
	)

	valores <- reshape_wide(rme_sexo[-4])
	coefvar <- reshape_wide(rme_sexo[-3])

	return(list(valores, coefvar))
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

	valores <- rme_responsavel[-3]
	colnames(valores) <- c("Estrato Geografico", "Rendimento Médio")

	coefvar <- rme_responsavel[, -2]
	colnames(coefvar) <- c("Estrato Geografico", "cv")

	return(list(valores, coefvar))
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

	valores <- gini_vd4019RMe[, -3]
	colnames(valores) <- c("Estrato Geografico", "Indice de Gini")
	valores[[2]] <- round(valores[[2]], 3)

	coefvar <- gini_vd4019RMe[, -2]
	colnames(coefvar) <- c("Estrato Geografico", "cv")

	return(list(valores, coefvar))
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

	valores <- Reduce(
		function(...) merge(..., sort = FALSE),
		dom_progs[[1]]
	)
	coefvar  <- Reduce(
		function(...) merge(..., sort = FALSE),
		dom_progs[[2]]
	)

	return(list(valores, coefvar))
})
names(tab_7457) <- paste0("sidra_", serie)

# 7531 - RMe real domiciliar per capita, por classe simples
tab_7531 <- lapply(lista_desenhos, function(desenho){

	rme_vd5008classe <- estimar_medias(
		subset(desenho, V2005.Rendimento == 1),
		~VD5008.Real,
		~VD5008.Classe
	)

	valores <- reshape_wide(rme_vd5008classe[, -4])
	coefvar <- reshape_wide(rme_vd5008classe[, -3])

	return(list(valores, coefvar))
})
names(tab_7531) <- paste0("sidra_", serie)

# 7538 - Rendimento habitual médio por classe acumulada de percentual
tab_7538 <- lapply(lista_desenhos, function(desenho){

	rme_vd4019cap <- estimar_cap(
		desenho = subset(desenho, VD4019 > 0),
		formula = ~VD4019.Real,
		csp = "VD4019.Classe"
	)

	valores <- rme_vd4019cap[[1]]
	coefvar  <- rme_vd4019cap[[2]]

	return(list(valores, coefvar))
})
names(tab_7538) <- paste0("sidra_", serie)

# 7548 - Rendimento habitual médio por classe acumulada de percentual
tab_7548 <- lapply(lista_desenhos, function(desenho){

	rme_vd4020cap <- estimar_cap(
		subset(desenho, VD4020 > 0),
		~VD4020.Real,
		"VD4020.Classe"
	)

	valores <- rme_vd4020cap[[1]]
	coefvar  <- rme_vd4020cap[[2]]

	return(list(valores, coefvar))
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
	    valores <- svytotal(~Estrato.Geo, sub_desenho, na.rm = TRUE)
	    ocupada_cap_e[[i]] <- cbind(valores, cv(valores))
	    colnames(ocupada_cap_e[[i]]) <- c(classes_acumuladas[i], "cv")
	}
	rm(sub_desenho, valores)

	valores <- data.frame(
		estratos_geo,
		do.call(cbind, lapply(ocupada_cap_e, function(x) x[, 1]))
	)
	colnames(valores) <- c("Estrato Geografico", classes_acumuladas)

	coefvar <- data.frame(
		estratos_geo,
		do.call(cbind, lapply(ocupada_cap_e, function(x) x[, 2]))
	)
	colnames(coefvar) <- c("Estrato Geografico", classes_acumuladas)

	return(list(valores, coefvar))
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
	    valores <- svytotal(~Estrato.Geo, sub_desenho, na.rm = TRUE)
	    ocupada_cap_h[[i]] <- cbind(valores, cv(valores))
	    colnames(ocupada_cap_h[[i]]) <- c(classes_acumuladas[i], "cv")
	}
	rm(sub_desenho, valores)

	valores <- data.frame(
		estratos_geo,
		do.call(cbind, lapply(ocupada_cap_h, function(x) x[, 1]))
	)
	colnames(valores) <- c("Estrato Geografico", classes_acumuladas)

	coefvar <- data.frame(
		estratos_geo,
		do.call(cbind, lapply(ocupada_cap_h, function(x) x[, 2]))
	)
	colnames(coefvar) <- c("Estrato Geografico", classes_acumuladas)

	return(list(valores, coefvar))
})
names(tab_7562) <- paste0("sidra_", serie)

# ---------------------------------------------------------------------
# FORMATAR TABELAS

objetos <- ls(pattern = "^tab_7")
objetos_gini <- c("tab_7435", "tab_7453")
objetos_pop  <- c("tab_7431", "tab_7434", "tab_7457", "tab_7559", "tab_7562")
objetos_real <- c("tab_7441", "tab_7442", "tab_7443", "tab_7444",
                  "tab_7446", "tab_7531", "tab_7538", "tab_7548")

for (obj in objetos) {
	tab_serie <- get(obj)

	tab_serie <- lapply(tab_serie, function(sublista) {

		if (is.null(sublista)) return(NULL)

		sublista[[1]] <- fmt_estrato(sublista[[1]])
		sublista[[2]] <- fmt_estrato(sublista[[2]])

		if (obj %in% objetos_pop) {
			sublista[[1]] <- fmt_pop(sublista[[1]])
		}
		if (obj %in% objetos_real) {
			sublista[[1]][, -1] <- round(sublista[[1]][, -1], 0)
		}

		return(sublista)
	})

	assign(obj, tab_serie)
}

# ---------------------------------------------------------------------
# SALVAR TABELAS
 
openxlsx_setOp("keepNA", TRUE)
openxlsx_setOp("na.string", "-")

titulos <- setNames(
        titulos,
        c(objetos)
)

linhas <- length(estratos_geo)

# um arquivo .xlsx por tabela; uma aba por ano da série.
# tabelas de valores e CV's na mesma aba.
# aplicar destaque em células com CV > 15%
for (obj in objetos) {

	tab_serie <- get(obj)
	titulo <- titulos[[obj]]
	wb <- createWorkbook()
	estilo_cv_alto <- createStyle(fontColour = "#9C0006", bgFill = "#FFC7CE")

	for (i in seq_along(serie)) {
		sublista <- tab_serie[[i]]
		if (is.null(sublista)) next

		ano <- as.character(serie[i])
		valores <- sublista[[1]]
		coefvar <- sublista[[2]]

		# definir títulos
		if (obj %in% objetos_gini) {
			titulo_val <- paste0("Tabela ", titulo)
			titulo_cv  <- paste0("CV's ", titulo, " (%)")
		} else if (obj %in% objetos_pop) {
			titulo_val <- paste0("Tabela ", titulo, " (Mil pessoas)")
			titulo_cv  <- paste0("CV's ", titulo, " (%)")
		} else {
			titulo_val <- paste0("Tabela ", titulo, " (Reais)")
			titulo_cv  <- paste0("CV's ", titulo, " (%)")
		}

		# adicionar aba e escrever dados
		addWorksheet(wb, ano)
		writeData(wb, ano, titulo_val, startCol = 1, startRow = 1)
		writeData(wb, ano, valores   , startCol = 1, startRow = 2)
		
		writeData(wb, ano, titulo_cv , startCol = 1, startRow = linhas + 4)
		writeData(wb, ano, coefvar   , startCol = 1, startRow = linhas + 5)

		# destaque para CVs altos
		for (col in 2:ncol(coefvar)) {
			conditionalFormatting(
				wb, sheet = ano,
				cols = col,
				rows = (linhas + 6):(2 * linhas + 6),
				rule = ">15",
				style = estilo_cv_alto,
				type = "expression"
			)
		}
	}

	# salvar planilha (um arquivo por objeto/tabela)
	saveWorkbook(wb, file = paste0(saida, obj, ".xlsx"), overwrite = TRUE)
}
