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
# Ler os dados

serie <- 2012:2023
tabelas <- c(7435, 7453, 7531, 7538, 7548, 7434, 7431,
	7559, 7562, 7429, 7441, 7442, 7444, 7446, 7457)

for (ano in serie) {
	dados <- gerar.desenho(tabelas, ano)
	obj <- paste0("desenho_", ano)
	assign(obj, dados)
	saveRDS(dados, file.path(entrada, ano, "/desenho.RDS"))
}
