# Reproduz tabelas SIDRA para os dez estratos geográficos de Minas Gerais.
# Tema: Rendimento de todas as fontes (PNAD contínua anual, 1a visita*).
# Tabelas: 7429, 7431, 7434, 7435, 7441, 7442, 7444, 7446, 7453, 7457,
#          7531, 7538, 7548, 7559, 7562.
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

serie <- 2021:2023
lista_desenhos <- vector("list", length(serie))
names(lista_desenhos) <- paste0("desenho_", serie)

tabelas <- c(7435, 7453, 7531, 7538, 7548, 7434, 7431,
	7559, 7562, 7429, 7441, 7442, 7444, 7446, 7457)

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
	tipos_rend <- c("VD4019", "VD4048", "V5004A2", "VD4052.Real")
	if (ano > 2014) { 
		tipos_rend <- c(tipos_rend, "Outros.Rendimentos")
	}
	desenho$variables <- ad_rdpc(desenho$variables, tipos_rend)
	desenho$variables$VD5008.Real <- desenho$variables$VD4052.Real.DPC
	desenho$variables$VD4052.Real.DPC <- NULL
	
	return(desenho)
})

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
	lista_desenhos, function(desenho) {
		estimar_quantis(desenho, formula = ~VD4019.Real)
	}
)

limites_vd4020 <- vector("list", length(serie))
names(limites_vd4020) <- paste0("limites_", serie)
limites_vd4020 <- lapply(
	lista_desenhos, function(desenho) {
		estimar_quantis(desenho, formula = ~VD4020.Real)
	}
)

lista_desenhos <- lapply(lista_desenhos, function(desenho) {

	# classes simples de percentual
	desenho$variables <- transform(
		desenho$variables,
		VD5008.Classes = ad_classes_simples(
			renda = VD5008.Real,
			geo = Estrato.Geo,
			limites = limites_vd5008real
		),
		VD4019.Classes = ad_classes_simples(
			renda = VD4019.Real,
			geo = Estrato.Geo,
			limites = limites_vd4019real
		),
		VD4019.Classes = ad_classes_simples(
			renda = VD4019.Real,
			geo = Estrato.Geo,
			limites = limites_vd4019real
		)
	)
}

