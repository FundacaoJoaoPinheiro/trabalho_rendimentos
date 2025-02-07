# Reproduzir tabelas SIDRA para os dez estratos geográficos de Minas Gerais.
# Tabelas referentes à domicílios em que moradores recebem benefício de
# programas sociais: 7447, 7448, 7449, 7450, 7451,7452, 7454, 7455, 7456 e 7457.
# ---------------------------------------------------------------------

# Preparar ambiente
pacotes <- c("PNADcIBGE", "survey")
install.packages(setdiff(pacotes, rownames(installed.packages())))
lapply(pacotes, library, character.only = TRUE)
source("utilitarios.R")     # objetos e funções utilizados abaixo

pnadc_ano = 2023
pnadc_dir = "Microdados"
desenho <- gerar_desenho(tabelas_fontes)

# ---------------------------------------------------------------------

# Criar colunas necessárias

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
		)
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
		)
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
		)
	)
)

# ---------------------------------------------------------------------

# Tabela 7447 - Pessoas de 10 anos ou mais cujo domicílio possui morador
# que recebe bolsa família, por nível de instrução (VD3004)

pop_bolsafamilia <- estimar_totais(
	desenho = subset(desenho, V2009 >= 10),
	formula = ~Domicilio.Bolsa.Familia,
	por = ~VD3004
)

# reformatar tabela com uma coluna para cada nível de instrução
tab_7447 <- reshape_wide(pop_bolsafamilia[c(1, 2, 4)])
cv_7447  <- reshape_wide(pop_bolsafamilia[c(1, 2, 6)])

write.csv(tab_7447, "tab_7447.csv")
write.csv(cv_7447, "cv_7447.csv")

# Tabela 7448 - O mesmo que 7447, mas para domicílios que não possuem
# moradores beneficiários

tab_7448 <- reshape_wide(pop_bolsafamilia[c(1, 2, 3)])
cv_7448  <- reshape_wide(pop_bolsafamilia[c(1, 2, 5)])

write.csv(tab_7448, "tab_7448.csv")
write.csv(cv_7448, "cv_7448.csv")

# Tabela 7454 - O mesmo que 7447, mas para domicílios que possuem beneficiários
# do BPC-Loas

pop_bpc <- estimar_totais(
	desenho = subset(desenho, V2009 >= 10),
	formula = ~Domicilio.BPC,
	por = ~VD3004
)

tab_7454 <- reshape_wide(pop_bolsafamilia[c(1, 2, 4)])
cv_7454  <- reshape_wide(pop_bolsafamilia[c(1, 2, 6)])

write.csv(tab_7454, "tab_7454.csv")
write.csv(cv_7454, "cv_7454.csv")

# Tabela 7455 - O mesmo que 7454, mas para domicílios que não possuem beneficiários

tab_7455 <- reshape_wide(pop_bolsafamilia[c(1, 2, 3)])
cv_7455  <- reshape_wide(pop_bolsafamilia[c(1, 2, 5)])

write.csv(tab_7455, "tab_7455.csv")
write.csv(cv_7455, "cv_7455.csv")

# Tabela 7449 - Domicílios com beneficiários do Bolsa Família, por posse
# ou acesso a bens e serviços

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

tab_7449 <- bolsafam_acesso[1:4 * 2, c(2, 3:10)]
cv_7449 <-  bolsafam_acesso[1:4 * 2, c(2, 11:18)]

write.csv(tab_7449, "tabelas/tab_7449.csv")
write.csv(cv_7449, "tabelas/cv_7449.csv")

# Tabela 7450 - O mesmo que 7449, mas para domicílios que não possuem beneficiários

tab_7450 <- bolsafam_acesso[seq(1, 7, by = 2), c(2, 3:10)]
cv_7450 <-  bolsafam_acesso[seq(1, 7, by = 2), c(2, 11:18)]

write.csv(tab_7450, "tabelas/tab_7450.csv")
write.csv(cv_7450, "tabelas/cv_7450.csv")

# Tabela 7451 - O mesmo que 7449, mas para beneficiários do BPC-Loas

bpc_acesso <- estimar_totais(
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

bpc_acesso <- bpc_acesso[-seq(3, 34, by = 2)]
colnames(bpc_acesso)[3:18] <- rotulos_benservicos

tab_7451 <- bpc_acesso[1:4 * 2, c(2, 3:10)]
cv_7451 <-  bpc_acesso[1:4 * 2, c(2, 11:18)]

write.csv(tab_7451, "tabelas/tab_7451.csv")
write.csv(cv_7451, "tabelas/cv_7451.csv")























