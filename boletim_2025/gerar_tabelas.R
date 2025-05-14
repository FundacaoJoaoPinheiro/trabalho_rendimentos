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
	"7443 - Rendimento habitual médio real mensal por nível de instrução",
	"7453 - Índice de Gini do rendimento médio habitualmente recebido",
	"7531 - RMe real mensal domiciliar per capita, por classe simples de percentual",
	"7538 - Rendimento habitual médio real mensal por classe acumulada de percentual"
)

# ---------------------------------------------------------------------
# IMPORTAR E PREPARAR DADOS

serie <- 2012:2024
tabelas <- c(7429, 7435, 7443, 7453, 7531, 7538)

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
		# habitualmente recebido de trabalho
		VD4019.Real = VD4019 * CO1,
		# efetivamente recebido de outras fontes
		VD4048.Real = VD4048 * CO1e
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

lista_desenhos <- lapply(seq_along(lista_desenhos), function(idx) {
	desenho <- lista_desenhos[[idx]]

	desenho$variables <- ad_classes_simples(
		desenho$variables,
		renda = "VD4019",
		limites_vd4019[[idx]]
	)
	desenho$variables <- ad_classes_simples(
		desenho$variables,
		renda = "VD5008",
		limites_vd5008[[idx]]
	)

	return(desenho)
})

# níveis de instrução
niveis_vd3004 <- levels(lista_desenhos[[1]][["variables"]][["VD3004"]])

lista_desenhos <- lapply(lista_desenhos, function(desenho) {

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

	return(desenho)
})

names(lista_desenhos) <- paste0("desenho_", serie)

# ---------------------------------------------------------------------
# REPRODUZIR TABELAS

# 7429 - participação % de cada fonte no rendimento médio domiciliar per capita
tab_7429 <- lapply(lista_desenhos, function(desenho){

	variaveis_necessarias <- "Outros.Rendimentos.DPC"
	if(!all(variaveis_necessarias %in% names(desenho$variables))) {
		return(NULL)
	}

	part_rdpc <- estimar_razao(
		desenho = subset(desenho, V2005.Rendimento == 1),
		numerador = ~VD5008 + VD4019.DPC + VD4048.DPC + V5004A2.DPC +
			Outros.Rendimentos.DPC,
		denominador = ~VD5008
	)
	part_rdpc[2:6] <- round(part_rdpc[2:6] * 100, 2)    # porcentagem

	valores <- part_rdpc[c(1, 2:6)]
	coefvar <- part_rdpc[c(1, 7:11)]

	colnames(valores)[-1] <- c(fontes_rendimento[c(1, 2, 4, 5, 8)])
	colnames(coefvar)[-1] <- c(fontes_rendimento[c(1, 2, 4, 5, 8)])

	return(list(valores, coefvar))
})
names(tab_7429) <- paste0("sidra_", serie)

# 7435 - Índice de Gini do rendimento domiciliar p/ capita
tab_7435 <- lapply(lista_desenhos, function(desenho){

	gini_vd5008real <- estimar_gini(
		subset(desenho, V2005.Rendimento == 1),
		~VD5008.Real
	)

	valores <- gini_vd5008real[, -3]
	colnames(valores) <- c("Estrato Geografico", "Indice de Gini")
	valores[[2]] <- round(valores[[2]], 3)

	coefvar <- gini_vd5008real[, -2]
	colnames(coefvar) <- c("Estrato Geografico", "cv")

	return(list(valores, coefvar))
})
names(tab_7435) <- paste0("sidra_", serie)

# 7443 - Rendimento médio real por nível de instrução
tab_7443 <- lapply(lista_desenhos, function(desenho){

	rme_instrucao <- estimar_medias(
		desenho,
		~VD4019.Real,
		por1 = ~Nivel.de.Instrucao
	)

	valores <- reshape_wide(rme_instrucao[, -4])
	valores[-1] <- round(valores[-1], 0)
	coefvar <- reshape_wide(rme_instrucao[, -3])

	return(list(valores, coefvar))
})
names(tab_7443) <- paste0("sidra_", serie)

# 7453 - Índice de Gini do rendimento médio habitualmente recebido
tab_7453 <- lapply(lista_desenhos, function(desenho){

	gini_vd4019real <- estimar_gini(subset(desenho, VD4019 > 0), ~VD4019.Real)
	
	valores <- gini_vd4019real[, -3]
	colnames(valores) <- c("Estrato Geografico", "Indice de Gini")
	valores[[2]] <- round(valores[[2]], 3)

	coefvar <- gini_vd4019real[, -2]
	colnames(coefvar) <- c("Estrato Geografico", "cv")

	return(list(valores, coefvar))
})
names(tab_7453) <- paste0("sidra_", serie)

# 7531 - RMe real domiciliar per capita, por classe simples
tab_7531 <- lapply(lista_desenhos, function(desenho){

	rme_vd5008classe <- estimar_medias(
		subset(desenho, V2005.Rendimento == 1),
		formula = ~VD5008.Real,
		por1 = ~VD5008.Classe,
		por2 = ~VD5008.Classe.MG
	)

	valores <- reshape_wide(rme_vd5008classe[, -4])
	coefvar <- reshape_wide(rme_vd5008classe[, -3])

	total <- estimar_medias(desenho, ~VD5008.Real)
	valores$Total <- total[[2]]
	valores[-1] <- round(valores[-1], 0)
	coefvar$Total <- total[[3]]

	return(list(valores, coefvar))
})
names(tab_7531) <- paste0("sidra_", serie)

# 7538 - Rendimento habitual médio por classe acumulada de percentual
tab_7538 <- lapply(lista_desenhos, function(desenho){

	rme_vd4019cap <- estimar_cap(
		desenho = desenho,
		formula = ~VD4019.Real,
		csp = "VD4019.Classe"
	)

	valores <- rme_vd4019cap[[1]]
	coefvar  <- rme_vd4019cap[[2]]

	total <- estimar_medias(desenho, ~VD4019.Real)
	valores$Total <- total[[2]]
	valores[-1] <- round(valores[-1], 0)
	coefvar$Total <- total[[3]]

	return(list(valores, coefvar))
})
names(tab_7538) <- paste0("sidra_", serie)

# ---------------------------------------------------------------------
# FORMATAR TABELAS

objetos <- ls(pattern = "^tab_7")
objetos_gini <- c("tab_7435", "tab_7453")
objetos_real <- c("tab_7443", "tab_7531", "tab_7538")

for (obj in objetos) {
	tab_serie <- get(obj)

	tab_serie <- lapply(tab_serie, function(sublista) {

		if (is.null(sublista)) return(NULL)

		sublista[[1]] <- fmt_estrato(sublista[[1]])
		sublista[[2]] <- fmt_estrato(sublista[[2]])
		sublista[[2]] <- fmt_porcent(sublista[[2]])

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

linhas <- length(estratos_geo) + 1

# um arquivo .xlsx por tabela; uma aba por ano da série.
# tabelas de valores e CV's na mesma aba.
# aplicar destaque em células com CV > 15%
for (obj in objetos) {

	tab_serie <- get(obj)
	titulo <- titulos[[obj]]
	caminho_arquivo <- paste0(saida, obj, ".xlsx")

	if (file.exists(caminho_arquivo)) {
		wb <- loadWorkbook(caminho_arquivo)
	} else {
		wb <- createWorkbook()
	}

	estilo_cv_alto <- createStyle(fontColour = "#9C0006", bgFill = "#FFC7CE")

	for (i in seq_along(serie)) {
		sublista <- tab_serie[[i]]
		if (is.null(sublista)) next

		ano <- as.character(serie[i])
		valores <- sublista[[1]]
		coefvar <- sublista[[2]]

		if (ano %in% names(wb)) {
			removeWorksheet(wb, ano)
		}

		titulo_val <- paste0("Tabela ", titulo)
		titulo_cv  <- paste0("CV's ", titulo, " (%)")

		if (obj %in% objetos_real) {
			titulo_val <- paste0(titulo_val, " (Reais)")
		} else if (!(obj %in% objetos_gini)) {
			titulo_val <- paste0(titulo_val, " (Índice)")
		}

		addWorksheet(wb, ano)
		writeData(wb, ano, titulo_val, startCol = 1, startRow = 1)
		writeData(wb, ano, valores   , startCol = 1, startRow = 2)
		writeData(wb, ano, titulo_cv , startCol = 1, startRow = linhas + 5)
		writeData(wb, ano, coefvar   , startCol = 1, startRow = linhas + 6)

		for (col in 2:ncol(coefvar)) {
			conditionalFormatting(
				wb, sheet = ano,
				cols = col,
				rows = (linhas + 7):(2 * linhas + 7),
				rule = ">15",
				style = estilo_cv_alto,
				type = "expression"
			)
		}
	}

	saveWorkbook(wb, file = caminho_arquivo, overwrite = TRUE)
}

# ---------------------------------------------------------------------
# VISUALIZAÇÃO

# Carregar pacotes necessários
library(ggplot2)
library(RColorBrewer)

# 7429 - Participação % de cada fonte no rendimento médio domiciliar per capita

# Construir data.frame longo (2015–2024), ignorando "Minas Gerais" (última linha)
dados_longos <- do.call(rbind, lapply(seq_along(tab_7429), function(i) {
	ano <- gsub("sidra_", "", names(tab_7429)[i])
	obj <- tab_7429[[i]][[1]]
	
	# Verificações
	if (is.null(obj)) return(NULL)
	if (!("Região de MG" %in% names(obj)) || !("Trabalho Hab." %in% names(obj))) return(NULL)
	if (nrow(obj) == 0) return(NULL)
	
	# Remover a linha de "Minas Gerais"
	obj <- obj[ obj$`Região de MG` != "Minas Gerais", ]
	
	data.frame(
		Ano = ano,
		Regiao = obj$`Região de MG`,
		Trabalho_Hab = as.numeric(gsub(",", ".", obj$`Trabalho Hab.`))
	)
}))

# Garantir que os anos estejam ordenados corretamente
dados_longos$Ano <- factor(dados_longos$Ano, levels = as.character(2015:2024))

# Paleta de cores para as regiões
n_regioes <- length(unique(dados_longos$Regiao))
cores_regioes <- brewer.pal(n = n_regioes, name = "Set3")

# Criar gráfico
ggplot(dados_longos, aes(x = Ano, y = Trabalho_Hab, fill = Regiao)) +
	geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
	geom_text(
		aes(label = sprintf("%.1f", Trabalho_Hab)),
		position = position_dodge(width = 0.9),
		vjust = -0.3,
		size = 3
	) +
	scale_fill_manual(values = cores_regioes) +
	labs(
		title = "Participação % de cada fonte no rendimento médio domiciliar per capita",
		x = "Ano",
		y = "% do rendimento de Trabalho Hab.",
		fill = "Região"
	) +
	theme_minimal(base_size = 12) +
	theme(
		axis.text.x = element_text(angle = 45, hjust = 1),
		plot.title = element_text(face = "bold"),
		legend.position = "bottom"
	) +
	guides(fill = guide_legend(nrow = 2, byrow = TRUE))

ggsave("boletim_2025/grafico_7429.png")

# Minas Gerais

# Extrair dados apenas de "Minas Gerais" para os anos 2015–2024
dados_mg <- do.call(rbind, lapply(seq_along(tab_7429), function(i) {
	ano <- gsub("sidra_", "", names(tab_7429)[i])
	obj <- tab_7429[[i]][[1]]
	
	# Verificações
	if (is.null(obj)) return(NULL)
	if (!("Região de MG" %in% names(obj))) return(NULL)
	if (nrow(obj) == 0) return(NULL)
	
	# Selecionar apenas a linha "Minas Gerais"
	obj <- obj[ obj$`Região de MG` == "Minas Gerais", ]
	if (nrow(obj) != 1) return(NULL)

	# Converter colunas desejadas
	data.frame(
		Ano = ano,
		Fonte = c("Trabalho Hab.", "Outras Fontes", "Aposentadoria", "Outros Rendimentos"),
		Participacao = as.numeric(gsub(",", ".", unlist(obj[c("Trabalho Hab.", "Outras Fontes", "Aposentadoria", "Outros Rendimentos")])))
	)
}))

# Garantir ordenação dos anos
dados_mg$Ano <- factor(dados_mg$Ano, levels = as.character(2015:2024))

# Cores fixas para cada fonte
cores_fontes <- c(
	"Trabalho Hab." = "#1b9e77",
	"Outras Fontes" = "#66c2a5",
	"Aposentadoria" = "#fc8d62",
	"Outros Rendimentos" = "#8da0cb"
)

# Criar gráfico
ggplot(dados_mg, aes(x = Ano, y = Participacao, fill = Fonte)) +
	geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
	geom_text(
		aes(label = sprintf("%.1f", Participacao)),
		position = position_dodge(width = 0.9),
		vjust = -0.3,
		size = 3
	) +
	scale_fill_manual(values = cores_fontes) +
	labs(
		x = "Ano",
		y = "% do rendimento",
		fill = "Fonte"
	) +
	theme_minimal(base_size = 12) +
	theme(
		axis.text.x = element_text(angle = 45, hjust = 1),
		plot.title = element_text(face = "bold"),
		legend.position = "bottom"
	) +
	guides(fill = guide_legend(nrow = 2, byrow = TRUE))

ggsave("boletim_2025/grafico_7429_MG.png")

# 7443 - Rendimento médio real por nível de instrução

# Extrair tabelas de 2019 e 2024
dados_2019 <- tab_7443[["sidra_2019"]][[1]]
dados_2024 <- tab_7443[["sidra_2024"]][[1]]

# Verificar se ambas as tabelas têm a mesma ordem de regiões
stopifnot(identical(dados_2019$`Região de MG`, dados_2024$`Região de MG`))

# Níveis de instrução que queremos comparar
niveis_instrucao <- c(
	"Sem instrucao + Fund. incompleto",
	"Fund. completo + Medio incompleto",
	"Medio completo + Sup. incompleto",
	"Sup. completo"
)

# Construir data.frame longo com variação percentual
dados_variacao <- do.call(rbind, lapply(niveis_instrucao, function(instrucao) {
	valores_2019 <- as.numeric(gsub(",", ".", dados_2019[[instrucao]]))
	valores_2024 <- as.numeric(gsub(",", ".", dados_2024[[instrucao]]))
	
	var_perc <- 100 * (valores_2024 - valores_2019) / valores_2019
	
	data.frame(
		Regiao = dados_2019$`Região de MG`,
		Instrucao = instrucao,
		Variacao = var_perc
	)
}))

# Garantir que região e instrução sejam fatores para controle de ordem, se quiser
dados_variacao$Instrucao <- factor(
	dados_variacao$Instrucao,
	levels = niveis_instrucao
)

# Paleta para níveis de instrução
cores_instrucao <- c(
	"Sem instrucao + Fund. incompleto" = "#e41a1c",
	"Fund. completo + Medio incompleto" = "#377eb8",
	"Medio completo + Sup. incompleto" = "#4daf4a",
	"Sup. completo" = "#984ea3"
)
dados_variacao$Regiao <- factor(
	dados_variacao$Regiao,
	levels = unique(dados_variacao$Regiao)  # mantém a ordem original
)

# Gráfico com ajustes
ggplot(dados_variacao, aes(x = Regiao, y = Variacao, fill = Instrucao)) +
	geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
	geom_text(
		aes(label = sprintf("%.1f%%", Variacao)),
		position = position_dodge(width = 0.9),
		vjust = ifelse(dados_variacao$Variacao >= 0, -0.3, 1.2),
		size = 3
	) +
	scale_fill_manual(values = cores_instrucao) +
	labs(
		title = "Variação percentual do rendimento por nível de instrução (2019–2024)",
		x = "Região de MG",
		y = "Variação percentual (%)",
		fill = "Nível de instrução"
	) +
	theme_minimal(base_size = 12) +
	theme(
		axis.text.x = element_text(angle = 45, hjust = 1),
		plot.title = element_text(face = "bold"),
		legend.position = "bottom",
		panel.grid.major = element_blank(),  # remove linhas horizontais maiores
		panel.grid.minor = element_blank(),  # remove linhas horizontais menores
		panel.grid.major.x = element_blank(),  # remove verticais também, por garantia
		panel.grid.minor.x = element_blank()
	) +
	guides(fill = guide_legend(nrow = 2, byrow = TRUE))

# 7435 - Índice de Gini do rendimento domiciliar p/ capita


# Construir data.frame longo com os dados de 2012 a 2024
dados_gini <- do.call(rbind, lapply(names(tab_7435), function(nome) {
	ano <- gsub("sidra_", "", nome)
	obj <- tab_7435[[nome]][[1]]
	
	if (is.null(obj)) return(NULL)
	if (!("Região de MG" %in% names(obj)) || !("Indice de Gini" %in% names(obj))) return(NULL)
	
	data.frame(
		Ano = as.integer(ano),
		Regiao = obj$`Região de MG`,
		Gini = as.numeric(gsub(",", ".", obj$`Indice de Gini`))
	)
}))

# Garantir ordem das regiões conforme 2024
ordem_regioes <- tab_7435[["sidra_2024"]][[1]]$`Região de MG`
dados_gini$Regiao <- factor(dados_gini$Regiao, levels = ordem_regioes)

# Paleta semelhante ao Excel (usando tons pastéis)
n_cores <- length(unique(dados_gini$Regiao))
cores_excel <- brewer.pal(n = min(12, n_cores), name = "Pastel1")

# Gráfico
ggplot(dados_gini, aes(x = factor(Ano), y = Gini, fill = Regiao)) +
	geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
	geom_text(
		aes(label = sprintf("%.3f", Gini)),
		position = position_dodge(width = 0.9),
		vjust = -0.3,
		size = 3
	) +
	scale_fill_manual(values = cores_excel) +
	labs(
		title = "Índice de Gini por região de MG (2012–2024)",
		x = "Ano",
		y = "Índice de Gini",
		fill = "Região"
	) +
	theme_minimal(base_size = 12) +
	theme(
		axis.text.x = element_text(angle = 45, hjust = 1),
		plot.title = element_text(face = "bold"),
		legend.position = "bottom",
		panel.grid.major.x = element_blank(),
		panel.grid.minor.x = element_blank()
	) +
	guides(fill = guide_legend(nrow = 2, byrow = TRUE))
