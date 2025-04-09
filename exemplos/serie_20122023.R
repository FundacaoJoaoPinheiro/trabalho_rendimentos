# Reproduz tabelas SIDRA para os dez estratos geográficos de Minas Gerais.
# Tema: Rendimento de todas as fontes (PNAD contínua anual, 1a visita*).
# Tabelas: 7429, 7431, 7434, 7435, 7441, 7442, 7443, 7444,
#          7446, 7453, 7457, 7531, 7538, 7548, 7559, 7562.
# série: 2012 a 2023.

# *Nos anos de 2020 e 2021, o SIDRA usou a 5a visita.
# *Preços deflacionados para 2023, utilizando CO1 e CO1e (consultar nota técnica).

# ---------------------------------------------------------------------
# Preparar ambiente

pacotes <- c("PNADcIBGE", "survey", "convey")
#install.packages(setdiff(pacotes, rownames(installed.packages())))
lapply(pacotes, library, character.only = TRUE)

# carregar objetos e funções utilizados no script:
source("utilitarios.R")

# ---------------------------------------------------------------------
# Importar e Preparar dados

serie <- 2012:2023
lista_desenhos <- vector("list", length(serie))

tabelas <- c(7429, 7431, 7434, 7435, 7441, 7442, 7443, 7444,
	7446, 7453, 7457, 7531, 7538, 7548, 7559, 7562)

# Adicionar colunas de rendimento
lista_desenhos <- lapply(serie, function(ano) {
	desenho <- gerar_desenho(ano, tabelas)
	
	# programas sociais, seguro-desemprego, bolsa de estudos, aplicações, etc
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
		VD4020.Real = VD4019 * CO1e,   # efetivamente recebido de trabalho
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
		tipos_rend <- c(tipos_rend, "Outros.Rendimentos")
	}
	desenho$variables <- ad_rdpc(desenho$variables, tipos_rend)
	desenho$variables$VD5008.Real <- desenho$variables$VD4052.Real.DPC
	desenho$variables$VD4052.Real.DPC <- NULL
	
	return(desenho)
})

names(lista_desenhos) <- paste0("desenho_", serie)

# Adicionar colunas de categorias

# limites de classes percentuais
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
		VD5008.Classes = ad_classes_simples(
			renda = VD5008.Real,
			geo = Estrato.Geo,
			limites = limites_vd5008[[idx]]
		),
		VD4019.Classes = ad_classes_simples(
			renda = VD4019.Real,
			geo = Estrato.Geo,
			limites = limites_vd4019[[idx]]
		),
		VD4020.Classes = ad_classes_simples(
			renda = VD4019.Real,
			geo = Estrato.Geo,
			limites = limites_vd4020[[idx]]
		)
	)

	return(desenho)

})

lista_desenhos <- lapply(lista_desenhos, function(desenho) {

	desenho$variables <- transform(
		desenho$variables,
		"Grupo de Idade" = ad_grupos_idade(idade = V2009)
	)

	niveis_vd3004 <- levels(desenho$variables$VD3004)
	desenho$variables <- transform(
		desenho$variables,
		"Niveis de Instrucao" = factor(
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
		Pessoa.Ocupada = ifelse(VD4019 > 0, 1, 0)
	)

	return(desenho)
}

# Programas socias; excluir os anos de 2012 a 2014
lista_desenhos[-1:-3] <- lapply(lista_desenhos[-1:-3], function(desenho) {

	# vetor com os ids dos domicílios em que ao menos um morador recebe Bolsa Família
	ids_bolsafamilia <- tapply(
		desenho$variables$V5002A == "Sim", 
		desenho$variables$ID_DOMICILIO, 
		FUN = any
	)
	# indica se ao menos um morador do domicílio recebe Bolsa Família
	desenho$variables <- transform(
		desenho$variables,
		Domicilio.Bolsa.Familia = factor(
			ifelse(
				ID_DOMICILIO %in% names(ids_bolsafamilia[ids_bolsafamilia]),
				"Sim", "Não"
			),
			levels = c("Sim", "Não")
		)
	)

	ids_bpc <- tapply(
		desenho$variables$V5001A == "Sim", 
		desenho$variables$ID_DOMICILIO, 
		FUN = any
	)
	desenho$variables <- transform(
		desenho$variables,
		Domicilio.BPC = factor(
			ifelse(
				ID_DOMICILIO %in% names(ids_bpc[ids_bpc]),
				"Sim", "Não"
			),
			levels = c("Sim", "Não")
		)
	)

	ids_outros <- tapply(
		desenho$variables$V5003A == "Sim", 
		desenho$variables$ID_DOMICILIO, 
		FUN = any
	)
	desenho$variables <- transform(
		desenho$variables,
		Domicilio.Outros.Programas = factor(
			ifelse(
				ID_DOMICILIO %in% names(ids_outros[ids_outros]),
				"Sim", "Não"
			),
			levels = c("Sim", "Não")
		)
	)

	return(desenho)

})
