# EM CONSTRUÇÃO

# Pesquisa Nacional por Amostra de Domicílios Contínua Anual

Scripts em R que reproduzem as tabelas do SIDRA do tema
"Rendimento de todas as fontes" (referentes à PNAD contínua anual,
5ª visiita), adicionando o recorte territorial dos estratos geográficos de
Minas Gerais.

# Requisitos

* R >= 4.1.0
* [PNADcIBGE](https://cran.r-project.org/web/packages/PNADcIBGE/index.html)
* [survey](https://cran.r-project.org/web/packages/survey/index.html)

# Instruções

O arquivo `utilitarios.R` define alguns objetos e funções que podem ser utilizados
manualmente. Abaixo, seguem alguns exemplos de como utilizar essas funções.

Criar um objeto com o plano amostral, fazendo o download dos arquivos
de microdados do FTP do IBGE e importando as variáveis relevantes para as
tabelas 7426 a 7429:

	library(PNADcIBGE)
	source("utilitarios.R")
	plano_amostral <- gerar_pa(c(7426:7429), download=TRUE)

Ler os dados diretamente do armazenamento interno pode ser mais rápido. Para
isso, os arquivos devem ser armazenados na pasta "Microdados". O shell
script baixar_microdados.sh pode ser usado no Linux e no macOs e faz o
download dos arquivos na pasta "Microdados" automaticamente. Usuários do
Windows podem copiar os links e colar no navegador para baixar (e mover os
arquivos para a pasta correta manualmente). O caminho para os arquivos de
microdados pode ser alterado com o objeto [`input_dir`](utilitarios.R#L14):

	library(PNADcIBGE)
	source("utilitarios.R")
	input_dir <- "Diretorio-Alternativo"
	plano_amostral <- gerar_pa(c(7426:7429))

Criar uma lista com as estimativas populacionais por variável (da tabela
7426) e estrato geográfico de MG, e outra lista com os respectivos coeficientes
de variação:

	library(PNADcIBGE)
	library(survey)
	source("utilitarios.R")
	plano_amostral <- gerar_pa(c(7426))
	pop_estimada_7426 <- list(
		efetiva  = estimar_pop(pnadc_MG, "possui_renda_efetiva"),
		aposent  = estimar_pop(pnadc_MG, "V5004A"),
		aluguel  = estimar_pop(pnadc_MG, "V5007A"),
		pensao_aliment = estimar_pop(pnadc_MG, "V5006A"),
		outros = estimar_pop(pnadc_MG, "V5008A")
	)
	cv_7426 <- lapply(
		pop_estimada_7426,
		function(obj) { head(cv(obj), n = 10) }  # 10 primeiros correspondem a "Sim"
	)
	names(cv_7426) <- names(pop_estimada_7426)

O arquivo exemplo_tab7426.R funciona de forma autônoma e é um arquivo teste
que trabalha separadamente com a tabela 7426. Ele cria um objeto com as
estimativas populacionais para cada variável por estrato geográfico, e cria
outro objeto com os respectivos coeficientes de variação

	source("exemplo_tab7426.R")
	# imprimir a pop. estimada que recebe aluguel por estrato geográfico
	print(pop_estimada_7426$aluguel)
	print(cv_7426$aluguel)

O arquivo gerar_resultados.R está em construção e deverá automatizar a tarefa
para todas as tabelas do tema "Rendimento de todas as fontes":

	source("gerar_resultados.R")

## Tabelas reproduzidas

* Tabela 7426 - População residente com rendimento, por tipo de rendimento
(em andamento)
* Tabela 7427 (por fazer)
* Tabela 7428 (por fazer)
* Tabela 7429 (por fazer)
* Tabela 7430 (por fazer)
* Tabela 7431 (por fazer)
* Tabela 7432 (por fazer)
* Tabela 7433 (por fazer)
* Tabela 7434 (por fazer)
* Tabela 7435 (por fazer)
* Tabela 7436 (por fazer)
* Tabela 7437 (por fazer)
* Tabela 7438 (por fazer)
* Tabela 7439 (por fazer)
* Tabela 7440 (por fazer)
* Tabela 7441 (por fazer)
* Tabela 7442 (por fazer)
* Tabela 7443 (por fazer)
* Tabela 7444 (por fazer)
* Tabela 7445 (por fazer)
* Tabela 7446 (por fazer)
* Tabela 7447 (por fazer)
* Tabela 7448 (por fazer)
* Tabela 7449 (por fazer)
* Tabela 7450 (por fazer)
* Tabela 7451 (por fazer)
* Tabela 7452 (por fazer)
* Tabela 7453 (por fazer)
* Tabela 7454 (por fazer)
* Tabela 7455 (por fazer)
* Tabela 7456 (por fazer)
* Tabela 7457 (por fazer)
* Tabela 7458 (por fazer)
* Tabela 7521 (por fazer)
* Tabela 7526 (por fazer)
* Tabela 7527 (por fazer)
* Tabela 7529 (por fazer)
* Tabela 7530 (por fazer)
* Tabela 7531 (por fazer)
* Tabela 7532 (por fazer)
* Tabela 7533 (por fazer)
* Tabela 7534 (por fazer)
* Tabela 7535 (por fazer)
* Tabela 7536 (por fazer)
* Tabela 7537 (por fazer)
* Tabela 7538 (por fazer)
* Tabela 7539 (por fazer)
* Tabela 7540 (por fazer)
* Tabela 7541 (por fazer)
* Tabela 7542 (por fazer)
* Tabela 7543 (por fazer)
* Tabela 7544 (por fazer)
* Tabela 7545 (por fazer)
* Tabela 7546 (por fazer)
* Tabela 7547 (por fazer)
* Tabela 7548 (por fazer)
* Tabela 7549 (por fazer)
* Tabela 7550 (por fazer)
* Tabela 7551 (por fazer)
* Tabela 7552 (por fazer)
* Tabela 7553 (por fazer)
* Tabela 7554 (por fazer)
* Tabela 7559 (por fazer)
* Tabela 7560 (por fazer)
* Tabela 7561 (por fazer)
* Tabela 7562 (por fazer)
* Tabela 7563 (por fazer)
* Tabela 7564 (por fazer)

## Links úteis:

* [Tabelas de referência](https://sidra.ibge.gov.br/pesquisa/pnadca/tabelas)
* [Pacote do R para análise da PNADc](https://rpubs.com/gabriel-assuncao-ibge/pnadc)
