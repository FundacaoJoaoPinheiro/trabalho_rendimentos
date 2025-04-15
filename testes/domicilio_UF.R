############### RASCUNHO ##################
# comparar valores estimados para MG na sessão do R com aqueles disponíveis 
# nas tabelas da plataforma SIDRA

pacotes <- c("sidrar", "PNADcIBGE", "survey", "convey")
lapply(pacotes, library, character.only = TRUE)
source("testes/utilitarios.R")
options(scipen = 999)

if (file.exists("desenho_pessoas.RDS")) {
	desenho <- readRDS("desenho_pessoas.RDS")
} else {
	desenho <- gerar_desenho(tabelas_domicilio)
}

