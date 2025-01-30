############### RASCUNHO ##################
# comparar valores estimados para MG na sessão do R com aqueles disponíveis 
# nas tabelas da plataforma SIDRA

# evitar notação científica e exibir até quatro casas decimais
options(scipen = 999, digits = 4)

# carregar e instalar pacotes
pacotes <- c("sidrar", "PNADcIBGE", "survey", "microbenchmark")
lapply(pacotes, library, character.only = TRUE)
source("testes/utilitarios.R")

# variaveis: V2005, V5001A, V5002A, V5003A, VD3004, S01007,
# S01012A, S01013, S01014, S01023, S01024, S01025, S01028

if (file.exists("desenho_progsociais.RDS")) {
	desenho <- readRDS("desenho_progsociais.RDS")
} else {
	desenho <- gerar_desenho(tabelas_progsocial)
}

# Pessoas que recebem benefício por caracterísitcas domiciliares
# ------------------------------------------------------------

# 7447 --> V5002A, VD3004; arredondando os resultados são iguais

# obter informações sobre a tabela
info_sidra(7447)

# importar tabela para as PA, BA, MG e GO
sidra_7447 <- get_sidra(
	x = 7447, variable = 10784, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7447)

# vetor com os ids dos domicílios em que ao menos um morador recebe Bolsa Família
ids_bolsafamilia <- tapply(
	desenho$variables$V5002A == "Sim", 
	desenho$variables$ID_DOMICILIO, 
	FUN = any
)

# criar coluna que indica se ao menos um morador do domicílio recebe Bolsa Família
desenho$variables <- transform(
	desenho$variables,
	Domicilio.Bolsa.Familia = factor(
		ifelse(
			ID_DOMICILIO %in% names(ids_bolsafamilia[ids_bolsafamilia]),
			"Sim", "Não"
		)
	)
)

# estimar total de pessoas de 10 anos ou mais cujo domicílio possui ao
# menos um morador que recebe Bolsa Família, por nível de instrução e UF
pop_bolsafamilia <- estimar_totais(
	~Domicilio.Bolsa.Familia,
	~VD3004,
	subset(desenho, V2009 >= 10)
)

# visualizar tabela sidra e nossa estimativa a título de comparação
View(sidra_7447[c(4,7,3)])
View(pop_bolsafamilia)

# formatar tabela para melhor visualização
# 7 níveis de instrução e 4 UF's (que serão 10 estratos geográficos)
# criar então 7 colunas para cada nível
# os índices 1, 4 e 6 são das colunas VD3004, valores "Sim" e cv's "Sim"
tab_7447 <- reformatar3(pop_bolsafamilia[c(1, 2, 4, 6)]

# salvar arquivo csv com a tabela
write.csv(tab_7447, "tab_7447.csv")

# 7448(Não) --> 7447(Sim)

# consultar informações da tabela
info_sidra(7448)

# importar a tabela do SIDRA
sidra_7448 <- get_sidra(
	x = 7448, variable = 10784, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7448)

# formatar tabela para melhor visualização
# os índices 1, 3 e 5 são das colunas VD3004, valores "Não" e cv's "Não"
tab_7448 <- reformatar3(pop_bolsafamilia[c(1, 2, 3, 5)])

# salvar arquivo csv com a tabela
write.csv(tab_7448, "tab_7448.csv")

# 7449 --> V5002A, S01007, S01012A, S01013, S01014, S01023, S01024, S01025, S01028
# domicílios em que ao menos um morador recebeu Bolsa Família, por acesso
# a bens e serviços

# consultar informações da tabela
info_sidra(7449)

# importar a tabela do SIDRA
sidra_7449 <- get_sidra(
	x = 7449, variable = 10790, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7449)

# estimar domicílios em que ao menos um morador recebe Bolsa Familia
# por tipo de acesso ou posse de bens e serviços
pop_acesso <- estimar_totais(
	formula = ~
		# abastecimento de água
		(S01007  == "Rede geral de distribuição") +
		# esgoto
		(S01012A == "Rede geral, rede pluvial" |
         S01012A == "Fossa séptica ligada à rede") +
		# destino do lixo
		(S01013  == "Coletado diretamente por serviço de limpeza" |
         S01013  == "Coletado em caçamba de serviço de limpeza") +
		# iluminação elétrica
		(S01014  == "Utiliza ao menos uma fonte de energia eletrica") +
		# geladeira
		(S01023  == "Sim, de 1 porta" |
         S01023  == "Sim, de 2 (ou mais) portas") +
		# máquina de lavar
		(S01024  == "Sim") +
		# televisão
		(S01025  == "Sim, somente de tela fina (LED, LCD ou plasma)" |
         S01025  == "Sim, somente de tubo" |
         S01025  == "Sim, de tela fina e de tubo") +
		# microcomputador
		(S01028  == "Sim"),
	desenho = subset(
		desenho,
		Domicilio.Bolsa.Familia == "Sim" &
		# há apenas um responsável por domicílio, assim evitamos dupla contagem
		V2005 == "Pessoa responsável pelo domicílio"
	)
)

# remover colunas em que os testes das variáveis suplementares foi FALSE
pop_acesso <- pop_acesso[-seq(3, 34, by = 2)]

# as colunas "Sim" e "Não" estão intercaladas
# renomear as colunas "Sim"
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

# renomear as colunas "Não"
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

# visualizar tabela sidra e nossa estimativa a título de comparação
View(sidra_7449[c(4,7,3)])
View(pop_acesso[1:4 * 2, 1:9 * 2])   # filtrar para ficar fácil de comparar

# 7450 --> 7449
info_sidra(7450)

sidra_7450 <- get_sidra(
	x = 7450, variable = 10784, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)

# visualizar tabela sidra e nossa estimativa a título de comparação
View(sidra_7450[c(4,7,3)])

# 7451 --> 7449; V5001A
info_sidra(7451)

sidra_7451 <- get_sidra(
	x = 7451, variable = 10784, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7431)

# visualizar tabela sidra e nossa estimativa a título de comparação
View(sidra_7451[c(4,7,3)])

# 7452 --> 7451; V5001A
info_sidra(7452)

sidra_7452 <- get_sidra(
	x = 7452, variable = 10784, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7431)

# visualizar tabela sidra e nossa estimativa a título de comparação
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

# visualizar tabela sidra e nossa estimativa a título de comparação
View(sidra_7455[c(4,7,3)])

# 7456 --> V5001A, V5002A, V5003A
info_sidra(7456)

sidra_7456 <- get_sidra(
	x = 7456, variable = 10784, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7431)

# visualizar tabela sidra e nossa estimativa a título de comparação
View(sidra_7456[c(4,7,3)])

# 7457 --> V5001A, V5002A, V5003A
info_sidra(7457)

sidra_7457 <- get_sidra(
	x = 7457, variable = 10784, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7431)

# visualizar tabela sidra e nossa estimativa a título de comparação
View(sidra_7457[c(4,7,3)])
