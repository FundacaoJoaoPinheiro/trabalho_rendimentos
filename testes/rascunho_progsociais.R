############### RASCUNHO ##################
# comparar valores estimados para MG na sessão do R com aqueles disponíveis 
# nas tabelas da plataforma SIDRA

pacotes <- c("sidrar", "PNADcIBGE", "survey", "microbenchmark")
lapply(pacotes, library, character.only = TRUE)
source("testes/utilitarios.R")
options(scipen = 999)

variaveis <- c("V2005", "V5001A", "V5002A", "V5003A", "VD3004", "S01007",
	"S01012A", "S01013", "S01014", "S01023", "S01024", "S01025", "S01028")

if (file.exists("desenho_progsociais.RDS")) {
	desenho <- readRDS("desenho_progsociais.RDS")
} else {
	desenho <- gerar_DA(variaveis)
}

# Pessoas que recebem benefício por caracterísitcas domiciliares
# ------------------------------------------------------------

# 7447 --> V5002A, VD3004; arredondando os resultados são iguais
info_sidra(7447)

sidra_7447 <- get_sidra(
	x = 7447, variable = 10784, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7447)

ids_bolsafamilia <- tapply(
	desenho$variables$V5002A == "Sim", 
	desenho$variables$ID_DOMICILIO, 
	FUN = any
)

desenho$variables <- transform(
	desenho$variables,
	Domicilio.Bolsa.Familia = ifelse(
		ID_DOMICILIO %in% names(ids_bolsafamilia[ids_bolsafamilia]),
		1, 0
	)
)

pop_bolsafamilia <- svyby(
	~Domicilio.Bolsa.Familia,
	~VD3004 + UF,
	subset(desenho, V2009 >= 10),
	FUN = svytotal,
	na.rm = TRUE
)

View(sidra_7447[c(4,7,3)])
View(pop_bolsafamilia)

# 7448 --> 7447
info_sidra(7448)

sidra_7448 <- get_sidra(
	x = 7448, variable = 10784, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7448)

View(sidra_7448[c(4,7,3)])


# 7449 --> V5002A, S01007, S01012A, S01013, S01014, S01023, S01024, S01025, S01028
info_sidra(7449)

sidra_7449 <- get_sidra(
	x = 7449, variable = 10790, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7449)

pop_acesso <- svyby(
	formula = ~
		# abastecimento de água
		(S01007  == "Rede geral de distribuição") +
		# esgoto
		(S01012A == "Rede geral, rede pluvial") +
		# destino do lixo
		(S01013  == "Coletado diretamente por serviço de limpeza" |
		S01013   == "Coletado em caçamba de serviço de limpeza") +
		# iluminação elétrica
		(S01014  == "Utiliza ao menos uma fonte de energia eletrica") +
		# geladeira
		(S01023  == "Sim, de 1 porta" |
		S01023   == "Sim, de 2 (ou mais) portas") +
		# máquina de lavar
		(S01024  == "Sim") +
		# televisão
		(S01025  == "Sim, somente de tela fina (LED, LCD ou plasma)" |
		S01025   == "Sim, somente de tubo" |
		S01025   == "Sim, de tela fina e de tubo") +
		# microcomputador
		(S01028  == "Sim"),
	by = ~Domicilio.Bolsa.Familia + UF,
	subset(desenho, V2009 >= 10 & V2005 == "Pessoa responsável pelo domicílio"),
	FUN = svytotal,
	na.rm = TRUE
)

colnames(pop_acesso)[2:9 * 2] <- c(
	"Abastecimento.de.Agua",
	"Esgotamento.Sanitario",
	"Coleta.de.lixo",
	"Iluminacao.Eletrica",
	"Geladeira",
	"Maquina.de.lavar",
	"Televisao",
	"Microcomputador"
)

colnames(pop_acesso)[seq(3,17, by =2)] <- c(
	"Sem.Abastecimento.de.Agua",
	"Sem.Esgotamento.Sanitario",
	"Sem.Coleta.de.lixo",
	"Sem.Iluminacao.Eletrica",
	"Sem.Geladeira",
	"Sem.Maquina.de.lavar",
	"Sem.Televisao",
	"Sem.Microcomputador"
)

View(sidra_7449[c(4,7,3)])
View(pop_acesso[1:4 * 2, 1:9 * 2])   # filtrar para ficar fácil de comparar

# 7450 --> 7449
info_sidra(7450)

sidra_7450 <- get_sidra(
	x = 7450, variable = 10784, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)

View(sidra_7450[c(4,7,3)])

# 7451 --> 7449; V5001A
info_sidra(7451)

sidra_7451 <- get_sidra(
	x = 7451, variable = 10784, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7431)

View(sidra_7451[c(4,7,3)])

# 7452 --> 7451; V5001A
info_sidra(7452)

sidra_7452 <- get_sidra(
	x = 7452, variable = 10784, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7431)

View(sidra_7452[c(4,7,3)])

# 7454 --> 7447; V5001A
info_sidra(7454)

sidra_7454 <- get_sidra(
	x = 7454, variable = 10784, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7431)

Vieww(sidra_7454[c(4,7,3)])

# 7455 --> V5001A, V5002A, V5003A
info_sidra(7455)

sidra_7455 <- get_sidra(
	x = 7455, variable = 10784, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7431)

View(sidra_7455[c(4,7,3)])

# 7456 --> V5001A, V5002A, V5003A
info_sidra(7456)

sidra_7456 <- get_sidra(
	x = 7456, variable = 10784, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7431)

View(sidra_7456[c(4,7,3)])

# 7457 --> V5001A, V5002A, V5003A
info_sidra(7457)

sidra_7457 <- get_sidra(
	x = 7457, variable = 10784, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7431)

View(sidra_7457[c(4,7,3)])
