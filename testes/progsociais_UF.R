############### RASCUNHO ##################
# comparar valores estimados para MG na sessão do R com aqueles disponíveis 
# nas tabelas da plataforma SIDRA

# evitar notação científica e exibir até quatro casas decimais
options(scipen = 999, digits = 4)

# carregar e instalar pacotes
pacotes <- c("sidrar", "PNADcIBGE", "survey")
install.packages(setdiff(pacotes, rownames(installed.packages())))
lapply(pacotes, library, character.only = TRUE)
source("utilitarios.R")     # carregar funções e objetos que serão utilizados

# variaveis: V2005, V5001A, V5002A, V5003A, VD3004, S01007,
# S01012A, S01013, S01014, S01023, S01024, S01025, S01028

if (file.exists("desenho_progsociais.RDS")) {
	desenho <- readRDS("desenho_progsociais.RDS")
} else {
	desenho <- gerar_desenho(tabelas_progsociais)
}

# Pessoas que recebem benefício por caracterísitcas domiciliares
# ------------------------------------------------------------

# 7447 --> V5002A, VD3004; arredondando os resultados são iguais

# obter informações sobre a tabela
info_sidra(7447)

# importar tabela para as PA, BA, MG e G
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
		),
		levels = c("Sim", "Não")
	)
)

# estimar total de pessoas de 10 anos ou mais cujo domicílio possui ao
# menos um morador que recebe Bolsa Família, por nível de instrução e UF
pop_bolsafamilia <- estimar_totais(
	desenho = subset(desenho, V2009 >= 10),
	formula = ~Domicilio.Bolsa.Familia,
	por = ~VD3004
)

# visualizar tabela sidra e nossa estimativa a título de comparação
View(sidra_7447[c(4,7,3)])
View(pop_bolsafamilia[c(1, 2, 3, 5)])

# formatar tabela para melhor visualização
tab_7447 <- reshape_wide(pop_bolsafamilia[c(1, 2, 3)])
cv_7447  <- reshape_wide(pop_bolsafamilia[c(1, 2, 5)])

# salvar arquivo csv com a tabela
write.csv(tab_7447, "tab_7447.csv")
write.csv(cv_7447, "cv_7447.csv")

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
tab_7448 <- reshape_wide(pop_bolsafamilia[c(1, 2, 4)])
cv_7448  <- reshape_wide(pop_bolsafamilia[c(1, 2, 6)])

# salvar arquivo csv com a tabela
write.csv(tab_7448, "tab_7448.csv")
write.csv(cv_7448, "cv_7448.csv")

# 7454 --> 7447; V5001A

# obter informações sobre a tabela
info_sidra(7454)

# importar tabela para as PA, BA, MG e G
sidra_7454 <- get_sidra(
	x = 7454, variable = 10808, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7454)

# vetor com os ids dos domicílios em que ao menos um morador recebe BPC
ids_bpc <- tapply(
	desenho$variables$V5001A == "Sim", 
	desenho$variables$ID_DOMICILIO, 
	FUN = any
)

# criar coluna que indica se ao menos um morador do domicílio recebe BPC
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

# estimar total de pessoas de 10 anos ou mais cujo domicílio possui ao
# menos um morador que recebe BPC, por nível de instrução e UF
pop_bpc <- estimar_totais(
	desenho = subset(desenho, V2009 >= 10),
	formula = ~Domicilio.BPC,
	por = ~VD3004
)

# visualizar tabela sidra e nossa estimativa a título de comparação
View(sidra_7454[c(4,7,3)])
View(pop_bpc[c(1, 2, 3, 5)])

# formatar tabela para melhor visualização
tab_7454 <- reshape_wide(pop_bolsafamilia[c(1, 2, 3)])
cv_7454  <- reshape_wide(pop_bolsafamilia[c(1, 2, 5)])

# salvar arquivo csv com a tabela
write.csv(tab_7454, "tab_7454.csv")
write.csv(cv_7454, "cv_7454.csv")

# 7455 (Não) -> 7454 (Sim)
info_sidra(7455)

sidra_7455 <- get_sidra(
	x = 7455, variable = 10812, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7455)

# formatar tabela para melhor visualização
tab_7455 <- reshape_wide(pop_bolsafamilia[c(1, 2, 4)])
cv_7455  <- reshape_wide(pop_bolsafamilia[c(1, 2, 6)])

# salvar arquivo csv com a tabela
write.csv(tab_7455, "tab_7455.csv")
write.csv(cv_7455, "cv_7455.csv")


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
bolsafam_acesso <- estimar_totais(
	desenho = subset(
		desenho,
		# há apenas um responsável por domicílio, assim evitamos dupla contagem
		V2005 == "Pessoa responsável pelo domicílio"
	),
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
	por = ~Domicilio.Bolsa.Familia
)

# remover colunas em que os testes das variáveis suplementares foi FALSE
bolsafam_acesso <- bolsafam_acesso[-seq(3, 34, by = 2)]

# renomear as colunas de bens e serviços
rotulos_benservicos <- c(
	"Abastecimento.de.Agua",
	"Esgotamento.Sanitario",
	"Coleta.de.lixo",
	"Iluminacao.Eletrica",
	"Geladeira",
	"Maquina.de.lavar",
	"Televisao",
	"Microcomputador",
	"cv.Abastecimento.de.Agua",
	"cv.Esgotamento.Sanitario",
	"cv.Coleta.de.lixo",
	"cv.Iluminacao.Eletrica",
	"cv.Geladeira",
	"cv.Maquina.de.lavar",
	"cv.Televisao",
	"cv.Microcomputador"
)

colnames(bolsafam_acesso)[3:18] <- rotulos_benservicos

# visualizar tabela sidra e nossa estimativa a título de comparação
View(sidra_7449[c(4,7,3)])
# filtrar linhas em que algum morador recebe BOlsa Família
View(bolsafam_acesso[seq(1, 7, by = 2), -1])

# dividir tabela com os totais e os cv's
tab_7449 <- bolsafam_acesso[seq(1, 7, by = 2), c(2, 3:10)]
cv_7449 <-  bolsafam_acesso[seq(1, 7, by = 2), c(2, 11:18)]

# salvar arquivos CSV
write.csv(tab_7449, "tabelas/tab_7449.csv")
write.csv(cv_7449, "tabelas/cv_7449.csv")

# 7450 --> 7449
info_sidra(7450)

sidra_7450 <- get_sidra(
	x = 7450, variable = 10784, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)

# visualizar tabela sidra e nossa estimativa a título de comparação
View(sidra_7450[c(4,7,3)])
# filtrar linhas em que nenhum morador recebe BOlsa Família
View(bolsafam_acesso[1:4 * 2, -1])

# dividir tabela com os totais e os cv's
tab_7450 <- bolsafam_acesso[1:4 * 2, c(2, 3:10)]
cv_7450 <-  bolsafam_acesso[1:4 * 2, c(2, 11:18)]

# salvar arquivos CSV
write.csv(tab_7450, "tabelas/tab_7450.csv")
write.csv(cv_7450, "tabelas/cv_7450.csv")

# 7451 --> 7449; V5001A
info_sidra(7451)

sidra_7451 <- get_sidra(
	x = 7451, variable = 10798, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7431)

# estimar domicílios em que ao menos um morador recebe BPC
# por tipo de acesso ou posse de bens e serviços
bpc_acesso <- estimar_totais(
	desenho = subset(
		desenho,
		# há apenas um responsável por domicílio, assim evitamos dupla contagem
		V2005 == "Pessoa responsável pelo domicílio"
	),
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
	por = ~Domicilio.BPC
)

# remover colunas em que os testes das variáveis suplementares foi FALSE
bpc_acesso <- bpc_acesso[-seq(3, 34, by = 2)]

# renomear as colunas de bens e serviços
colnames(bpc_acesso)[3:18] <- rotulos_benservicos

# visualizar tabela sidra e nossa estimativa a título de comparação
View(sidra_7451[c(4,7,3)])
View(bpc_acesso[seq(1, 7, by = 2), -1])

# dividir tabela com os totais e os cv's
tab_7451 <- bpc_acesso[seq(1, 7, by = 2), c(2, 3:10)]
cv_7451 <-  bpc_acesso[seq(1, 7, by = 2), c(2, 11:18)]

# salvar arquivos CSV
write.csv(tab_7451, "tabelas/tab_7451.csv")
write.csv(cv_7451, "tabelas/cv_7451.csv")

# 7452 --> 7450; V5001A
info_sidra(7452)

sidra_7452 <- get_sidra(
	x = 7452, variable = 10802, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7431)

# visualizar tabela sidra e nossa estimativa a título de comparação
View(sidra_7452[c(4,7,3)])
View(bpc_acesso[1:4 * 2, -1])

# dividir tabela com os totais e os cv's
tab_7452 <- bpc_acesso[1:4 * 2, c(2, 3:10)]
cv_7452 <-  bpc_acesso[1:4 * 2, c(2, 11:18)]

# salvar arquivos CSV
write.csv(tab_7452, "tabelas/tab_7452.csv")
write.csv(cv_7452, "tabelas/cv_7452.csv")

# 7456 - média de moradores por domicílio por recbimento e tipo de programa
info_sidra(7456)

sidra_7456 <- get_sidra(
	x = 7456, variable = 10163, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7456)

# ids dos domicílios em que ao menos um morador recebe outros programas
ids_outrosprogramas <- tapply(
	desenho$variables$V5003A == "Sim", 
	desenho$variables$ID_DOMICILIO, 
	FUN = any
)

# criar coluna que indica se ao menos um morador do domicílio recebe Bolsa Família
desenho$variables <- transform(
	desenho$variables,
	Domicilio.Outros.Programas = factor(
		ifelse(
			ID_DOMICILIO %in% names(ids_outrosprogramas[ids_outrosprogramas]),
			"Sim", "Não"
		),
		levels = c("Sim", "Não")
	)
)

media_moradores_progs <- estimar_interaction(
	desenho = subset(desenho, V2005 == "Pessoa responsável pelo domicílio"),
	formula = ~V2001,
	FUN = svymean,
	progs = c("Domicilio.Bolsa.Familia", "Domicilio.BPC",
		"Domicilio.Outros.Programas")
)
media_moradores_progs <- agrupar_progs(media_moradores_progs)

# visualizar tabela sidra e nossa estimativa a título de comparação
View(sidra_7456[c(4,7,3)])
View(media_moradores_progs[[1]])

# dividir lista entre valores e cv's
tab_7456 <- Reduce(
	function(...) merge(..., sort = FALSE),
	media_moradores_progs[[1]]
)
cv_7456  <- Reduce(
	function(...) merge(..., sort = FALSE),
	media_moradores_progs[[2]]
)

# salvar arquivos CSV
write.csv(tab_7456, "tab_7456.csv")
write.csv(cv_7456, "cv_7456.csv")

# 7457 - total de domicílios, por recebimento e tipo de programa
info_sidra(7457)

sidra_7457 <- get_sidra(
	x = 7457, variable = 162, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7457)

dom_progs <- estimar_interaction(
	subset(desenho, V2005 == "Pessoa responsável pelo domicílio"),
	~V2005 == "Pessoa responsável pelo domicílio",
	FUN = svytotal,
	c("Domicilio.Bolsa.Familia", "Domicilio.BPC", "Domicilio.Outros.Programas")
)
# remover colunas em que o teste foi FALSE
dom_progs <- lapply(dom_progs, `[`, c(-2, -4))
dom_progs <- agrupar_progs(dom_progs)

# visualizar tabela sidra e nossa estimativa a título de comparação
View(sidra_7457[c(4,7,3)])
View(dom_progs)

# dividir lista entre valores e cv's
tab_7457 <- Reduce(
	function(...) merge(..., sort = FALSE),
	dom_progs[[1]]))
cv_7457  <- Reduce(
	function(...) merge(..., sort = FALSE),
	dom_progs[[2]]))

# salvar arquivos CSV
write.csv(tab_7457, "tab_7457.csv")
write.csv(cv_7457, "cv_7457.csv")

