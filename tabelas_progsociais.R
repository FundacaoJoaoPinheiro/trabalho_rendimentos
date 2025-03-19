# Reproduz tabelas SIDRA para os dez estratos geográficos de Minas Gerais.
# Tabelas referentes à domicílios em que moradores recebem benefício de
# programas sociais: 7447, 7448, 7449, 7450, 7451,7452, 7454, 7455, 7456 e 7457.
# ---------------------------------------------------------------------

# Preparar ambiente
pacotes <- c("PNADcIBGE", "survey")
#install.packages(setdiff(pacotes, rownames(installed.packages())))
lapply(pacotes, library, character.only = TRUE)

# carregar objetos e funções utilizados no script:
# gerar_desenho(); estimar_totais(); reshape_wide(); estimar_interacao();
# `tabelas_progsociais`;
source("utilitarios.R")

# ---------------------------------------------------------------------
# Criar colunas necessárias

desenho <- gerar_desenho(tabelas_progsociais)

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

ids_outrosprogramas <- tapply(
	desenho$variables$V5003A == "Sim", 
	desenho$variables$ID_DOMICILIO, 
	FUN = any
)

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

# ---------------------------------------------------------------------
# Reproduzir tabelas

# Tabela 7447 - Pessoas de 10 anos ou mais cujo domicílio possui morador
# que recebe bolsa família, por nível de instrução (VD3004)
pop_bolsafamilia <- estimar_totais(
	desenho = subset(desenho, V2009 >= 10),
	formula = ~Domicilio.Bolsa.Familia,
	por = ~VD3004
)

tab_7447 <- reshape_wide(pop_bolsafamilia[c(1, 2, 3)])
cv_7447  <- reshape_wide(pop_bolsafamilia[c(1, 2, 5)])
cv_7447[, -1] <- round(cv_7447[, -1] * 100, 1)

# Tabela 7448 - O mesmo que 7447, mas para domicílios que não possuem
# moradores beneficiários
tab_7448 <- reshape_wide(pop_bolsafamilia[c(1, 2, 4)])
cv_7448  <- reshape_wide(pop_bolsafamilia[c(1, 2, 6)])
cv_7448[, -1] <- round(cv_7448[, -1] * 100, 1)

# Tabela 7454 - O mesmo que 7447, mas para domicílios que possuem beneficiários
# do BPC-Loas
pop_bpc <- estimar_totais(
	desenho = subset(desenho, V2009 >= 10),
	formula = ~Domicilio.BPC,
	por = ~VD3004
)

tab_7454 <- reshape_wide(pop_bpc[c(1, 2, 3)])
cv_7454  <- reshape_wide(pop_bpc[c(1, 2, 5)])
cv_7454[, -1] <- round(cv_7454[, -1] * 100, 1)

# Tabela 7455 - O mesmo que 7454, mas para domicílios que não possuem
# beneficiários
tab_7455 <- reshape_wide(pop_bolsafamilia[c(1, 2, 4)])
cv_7455  <- reshape_wide(pop_bolsafamilia[c(1, 2, 6)])

# Tabela 7449 - Domicílios com beneficiários do Bolsa Família, por posse
# ou acesso a bens e serviços
acesso_bolsafam <- estimar_totais(
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
acesso_bolsafam <- acesso_bolsafam[, -seq(3, 34, by = 2)]

rotulos_benservicos <- c(
	"Abastecimento.de.Agua",
	"Esgotamento.Sanitario",
	"Coleta.de.lixo",
	"Iluminacao.Eletrica",
	"Geladeira",
	"Maquina.de.lavar",
	"Televisao",
	"Microcomputador"
)

tab_7449 <- acesso_bolsafam[seq(1, 19 , by = 2), c(2, 3:10)]
cv_7449 <-  acesso_bolsafam[seq(1, 19 , by = 2), c(2, 11:18)]
cv_7449[, -1] <- round(cv_7449[, -1] * 100, 1)

colnames(tab_7449) <- c("Estrato.Geo", rotulos_benservicos)
colnames(cv_7449)  <- c("Estrato.Geo", rotulos_benservicos)
tab_7449$Estrato.Geo <- estratos_geo
cv_7449$Estrato.Geo  <- estratos_geo

# Tabela 7450 - O mesmo que 7449, mas para domicílios que não possuem
# beneficiários
tab_7450 <- acesso_bolsafam[1:10 * 2, c(2, 3:10)]
cv_7450 <-  acesso_bolsafam[1:10 * 2, c(2, 11:18)]
cv_7450[, -1] <- round(cv_7450[, -1] * 100, 1)

colnames(tab_7450) <- c("Estrato.Geo", rotulos_benservicos)
colnames(cv_7450)  <- c("Estrato.Geo", rotulos_benservicos)
tab_7450$Estrato.Geo <- estratos_geo
cv_7450$Estrato.Geo  <- estratos_geo

# Tabela 7451 - O mesmo que 7449, mas para beneficiários do BPC-Loas
acesso_bpc <- estimar_totais(
	desenho = subset(
		desenho,
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

acesso_bpc <- acesso_bpc[-seq(3, 34, by = 2)]

tab_7451 <- acesso_bpc[seq(1, 19 , by = 2), c(2, 3:10)]
cv_7451 <-  acesso_bpc[seq(1, 19 , by = 2), c(2, 11:18)]
cv_7451[, -1] <- round(cv_7451[, -1] * 100, 1)

colnames(tab_7451) <- c("Estrato.Geo", rotulos_benservicos)
colnames(cv_7451)  <- c("Estrato.Geo", rotulos_benservicos)
tab_7451$Estrato.Geo <- estratos_geo
cv_7451$Estrato.Geo  <- estratos_geo

# Tabela 7452 - o mesmo que 7451, mas para domicílios sem beneficiários do BPC
tab_7452 <- acesso_bpc[seq(2, 20, by = 2), c(2, 3:10)]
cv_7452 <-  acesso_bpc[seq(2, 20, by = 2), c(2, 11:18)]
cv_7452[, -1] <- round(cv_7452[, -1] * 100, 1)

colnames(tab_7452) <- c("Estrato.Geo", rotulos_benservicos)
colnames(cv_7452)  <- c("Estrato.Geo", rotulos_benservicos)
tab_7452$Estrato.Geo <- estratos_geo
cv_7452$Estrato.Geo  <- estratos_geo

# Tabela 7456 - média de moradores por domicílio por recbimento e tipo de programa
media_moradores_progs <- estimar_interacao(
	desenho = subset(desenho, V2005 == "Pessoa responsável pelo domicílio"),
	formula = ~V2001,
	FUN = svymean,
	vars = c("Domicilio.Bolsa.Familia", "Domicilio.BPC",
		"Domicilio.Outros.Programas")
)
media_moradores_progs <- agrupar_progs(media_moradores_progs)

tab_7456 <- Reduce(
	function(...) merge(..., sort = FALSE),
	media_moradores_progs[[1]]
)
cv_7456  <- Reduce(
	function(...) merge(..., sort = FALSE),
	media_moradores_progs[[2]]
)
cv_7456[, -1] <- round(cv_7456[, -1] * 100, 1)

# Tabela 7457 - total de domicílios, por recebimento e tipo de programa
dom_progs <- estimar_interacao(
	subset(desenho, V2005 == "Pessoa responsável pelo domicílio"),
	~V2005 == "Pessoa responsável pelo domicílio",
	FUN = svytotal,
	c("Domicilio.Bolsa.Familia", "Domicilio.BPC", "Domicilio.Outros.Programas")
)
# remover colunas em que o teste foi FALSE
dom_progs <- lapply(dom_progs, `[`, c(-2, -4))
dom_progs <- agrupar_progs(dom_progs)

tab_7457 <- Reduce(
	function(...) merge(..., sort = FALSE),
	dom_progs[[1]]
)
cv_7457  <- Reduce(
	function(...) merge(..., sort = FALSE),
	dom_progs[[2]]
)
cv_7457[, -1] <- round(cv_7457[, -1] * 100, 1)
