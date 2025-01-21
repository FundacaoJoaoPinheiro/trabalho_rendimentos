# EM CONSTRUÇÃO

# Pesquisa Nacional por Amostra de Domicílios Contínua Anual

Scripts em R que reproduzem as tabelas do SIDRA do tema
"Rendimento de todas as fontes" (referentes à PNAD contínua anual,
5ª visiita), adicionando o recorte territorial dos estratos geográficos de
Minas Gerais.

# Requisitos

- R >= 4.1.0
- [PNADcIBGE](https://cran.r-project.org/web/packages/PNADcIBGE/index.html)
- [survey](https://cran.r-project.org/web/packages/survey/index.html)

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

O arquivo `exemplo_tab7426.R` funciona de forma autônoma e é um arquivo teste
que trabalha separadamente com a tabela 7426. Ele cria um objeto com as
estimativas populacionais para cada variável por estrato geográfico, e cria
outro objeto com os respectivos coeficientes de variação

	source("exemplo_tab7426.R")
	# imprimir a pop. estimada que recebe aluguel por estrato geográfico
	print(pop_estimada_7426$aluguel)
	print(cv_7426$aluguel)

O arquivo `gerar_resultados.R` está em construção e deverá automatizar a tarefa
para todas as tabelas do tema "Rendimento de todas as fontes":

	source("gerar_resultados.R")

## Tabelas reproduzidas

- Tabela 7426 (x) - População residente com rendimento, por tipo de rendimento

- Tabela 7427 (x) - Massa de rendimento mensal real domiciliar per capita,
a preços médios do último ano, por classes simples de percentual das
pessoas em ordem crescente de rendimento domiciliar per capita

- Tabela 7428 (x) - Massa de rendimento mensal real domiciliar per capita,
a preços médios do ano, por classes simples de percentual das pessoas
em ordem crescente de rendimento domiciliar per capita

- Tabela 7429 (x) - Participação percentual na composição do rendimento
médio mensal real domiciliar per capita, a preços médios do ano, por
tipo de rendimento

- Tabela 7430 (-) - Massa de rendimento mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho,
de todos os trabalhos

- Tabela 7431 (x) - Pessoas de 14 anos ou mais de idade ocupadas na semana de
referência com rendimento, por cor ou raça

- Tabela 7432 (x) - Pessoas de 14 anos ou mais de idade ocupadas na semana de
referência com rendimento, por grupo de idade

- Tabela 7433 (x) - Pessoas de 14 anos ou mais de idade ocupadas na semana de
referência com rendimento, por nível de instrução

- Tabela 7434 (x) - Pessoas de 14 anos ou mais de idade ocupadas na semana de
referência com rendimento, por sexo

- Tabela 7435 (x) - Índice de Gini do rendimento domiciliar per capita,
a preços médios do ano

- Tabela 7436 (x) - População residente

- Tabela 7437 (x) - Rendimento médio mensal real da população residente
com rendimento, por tipo de rendimento

- Tabela 7438 (x) - Limites superiores das classes de percentual das pessoas em
ordem crescente de rendimento domiciliar per capita, a preços médios do ano

- Tabela 7439 (-) - Pessoas de 14 anos ou mais de idade ocupadas na semana de
referência com rendimento e responsáveis pelo domicílio

- Tabela 7440 (-) - Pessoas de 14 anos ou mais de idade ocupadas na semana de
referência com rendimento, por tipo de área geográfica

- Tabela 7441 (x) - Rendimento médio mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho,
de todos os trabalhos, a preços médios do último ano, por cor ou raça

- Tabela 7442 (x) - Rendimento médio mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho,
de todos os trabalhos, a preços médios do último ano, por grupo de idade

- Tabela 7443 (x) - Rendimento médio mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho,
de todos os trabalhos, a preços médios do último ano, por nível de
instrução

- Tabela 7444 (x) - Rendimento médio mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho,
de todos os trabalhos, a preços médios do último ano, por sexo

- Tabela 7445 (x) - Rendimento médio mensal real das pessoas de 14 anos
ou mais de idade ocupadas na semana de referência com rendimento de
trabalho, de todos os trabalhos, a preços médios do último ano, por
tipo de área geográfica

- Tabela 7446 (x) - Rendimento médio mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho
e responsáveis pelo domicílio, de todos os trabalhos, a preços médios
do último ano

- Tabela 7447 (x) - Pessoas de 10 anos ou mais de idade cujo domicílio possui
algum morador que recebeu rendimento do Programa Bolsa Família, por nível
de instrução

- Tabela 7448 (-) - Pessoas de 10 anos ou mais de idade cujo domicílio não
possui morador que recebeu rendimento do Programa Bolsa Família, por
nível de instrução

- Tabela 7449 (-) - Domicílios em que algum morador do domicílio recebeu
rendimento do Programa Bolsa Família, por posse ou acesso a bens ou
serviços

- Tabela 7450 (-) - Domicílios em que nenhum morador do domicílio recebeu
rendimento do Programa Bolsa Família, por posse ou acesso a bens ou
serviços

- Tabela 7451 (-) - Domicílios em que algum morador do domicílio recebeu
rendimento do Benefício de Prestação Continuada, por posse ou acesso
a bens ou serviços

- Tabela 7452 (-) - Domicílios em que nenhum morador do domicílio recebeu
rendimento do Benefício de Prestação Continuada, por posse ou acesso
a bens ou serviços

- Tabela 7453 (x) - Índice de Gini do rendimento médio mensal real das
pessoas de 14 anos ou mais de idade ocupadas na semana de referência
com rendimento de trabalho, habitualmente recebido em todos os trabalhos,
a preços médios do ano

- Tabela 7454 (-) - Pessoas de 10 anos ou mais de idade cujo domicílio possui
algum morador que recebeu rendimento do Benefício de Prestação Continuada,
por nível de instrução

- Tabela 7455 (-) - Pessoas de 10 anos ou mais de idade cujo domicílio
não possui morador que recebeu rendimento do Benefício de Prestação
Continuada, por nível de instrução

- Tabela 7456 (-) - Número médio de moradores por domicílio, por recebimento
de rendimento de programa social e tipo de programa social

- Tabela 7457 (-) - Domicílios, por recebimento de rendimento de programa
social e tipo de programa social

- Tabela 7458 (x) - Rendimento médio mensal real domiciliar per capita, a
preços médios do último ano, por recebimento de rendimento de programa
social e tipo de programa social

- Tabela 7521 (x) - População residente, por classes simples de percentual
das pessoas por rendimento domiciliar per capita, a preços médios do ano

- Tabela 7526 (x) - Limites superiores das classes de percentual das pessoas
em ordem crescente de rendimento domiciliar per capita, a preços médios
do último ano

- Tabela 7527 (x) - Distribuição da massa de rendimento mensal real domiciliar
per capita, a preços médios do ano, por classes simples de percentual
das pessoas em ordem crescente de rendimento domiciliar per capita

- Tabela 7529 (x) - População residente, por classes simples de percentual
das pessoas por rendimento domiciliar per capita, a preços médios do
último ano

- Tabela 7530 (x) - Distribuição da massa de rendimento mensal real domiciliar
per capita, a preços médios do ano, por classes acumuladas de percentual
das pessoas em ordem crescente de rendimento domiciliar per capita

- Tabela 7531 (x) - Rendimento médio mensal real domiciliar per capita,
a preços médios do ano, por classes simples de percentual das pessoas
em ordem crescente de rendimento domiciliar per capita

- Tabela 7532 (x) - Rendimento médio mensal real domiciliar per capita, a
preços médios do ano, por classes acumuladas de percentual das pessoas
em ordem crescente de rendimento domiciliar per capita

- Tabel 7533 (x) - Rendimento médio mensal real domiciliar per capita,
a preços médios do último ano, por classes simples de percentual das
pessoas em ordem crescente de rendimento domiciliar per capita

- Tabel 7534 (x) - Rendimento médio mensal real domiciliar per capita, a
preços médios do último ano, por classes acumuladas de percentual das
pessoas em ordem crescente de rendimento domiciliar per capita

- Tabela 7535 (x) - Rendimento médio mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho,
habitualmente recebido em todos os trabalhos, a preços médios do ano, por
classes simples de percentual das pessoas em ordem crescente de rendimento
habitualmente recebido

- Tabela 7536 (x) - Limites superiores das classes de percentual das pessoas
em ordem crescente de rendimento habitualmente recebido, a preços médios
do ano

- Tabela 7537 (x) - Pessoas de 14 anos ou mais de idade ocupadas na semana de
referência com rendimento de trabalho, por classes simples de percentual
das pessoas em ordem crescente de rendimento habitualmente recebido,
a preços médios do ano

- Tabela 7538 (x) - Rendimento médio mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho,
habitualmente recebido em todos os trabalhos, a preços médios do ano,
por classes acumuladas de percentual das pessoas em ordem crescente de
rendimento habitualmente recebido

- Tabela 7539 (x) - Rendimento médio mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho,
habitualmente recebido em todos os trabalhos, a preços médios do último
ano, por classes simples de percentual das pessoas em ordem crescente de
rendimento habitualmente recebido

- Tabela 7540 (x) - Limites superiores das classes de percentual das pessoas
em ordem crescente de rendimento habitualmente recebido, a preços médios
do último ano

- Tabela 7541 (x) - Pessoas de 14 anos ou mais de idade ocupadas na semana de
referência com rendimento de trabalho, por classes simples de percentual
das pessoas em ordem crescente de rendimento habitualmente recebido,
a preços médios do último ano

- Tabela 7542 (x) - Rendimento médio mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho,
habitualmente recebido em todos os trabalhos, a preços médios do último
ano, por classes acumuladas de percentual das pessoas em ordem crescente
de rendimento habitualmente recebido

- Tabela 7543 (-) - Distribuição da massa de rendimento mensal real das
pessoas de 14 anos ou mais de idade ocupadas na semana de referência
com rendimento de trabalho, habitualmente recebido em todos os trabalhos,
a preços médios do ano, por classes simples de percentual das pessoas
em ordem crescente de rendimento habitualmente recebido

- Tabela 7544 (x) - Distribuição da massa de rendimento mensal real das
pessoas de 14 anos ou mais de idade ocupadas na semana de referência com
rendimento de trabalho, habitualmente recebido em todos os trabalhos, a
preços médios do ano, por classes acumuladas de percentual das pessoas
em ordem crescente de rendimento habitualmente recebido

- Tabela 7545 (x) - Rendimento médio mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho,
efetivamente recebido em todos os trabalhos, a preços médios do ano, por
classes simples de percentual das pessoas em ordem crescente de rendimento
efetivamente recebido

- Tabela 7546 (x) - Limites superiores das classes de percentual das pessoas em
ordem crescente de rendimento efetivamente recebido, a preços médios do ano

- Tabela 7547 (x) - Pessoas de 14 anos ou mais de idade ocupadas na semana de
referência com rendimento de trabalho, por classes simples de percentual
das pessoas em ordem crescente de rendimento efetivamente recebido,
a preços médios do ano

- Tabela 7548 (x) - Rendimento médio mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho,
efetivamente recebido em todos os trabalhos, a preços médios do ano,
por classes acumuladas de percentual das pessoas em ordem crescente de
rendimento efetivamente recebido

- Tabela 7549 (x) - Rendimento médio mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho,
efetivamente recebido em todos os trabalhos, a preços médios do último
ano, por classes simples de percentual das pessoas em ordem crescente de
rendimento efetivamente recebido

- Tabela 7550 (x) - Limites superiores das classes de percentual das pessoas
em ordem crescente de rendimento efetivamente recebido, a preços médios
do último ano

- Tabela 7551 (x) - Pessoas de 14 anos ou mais de idade ocupadas na semana de
referência com rendimento de trabalho, por classes simples de percentual
das pessoas em ordem crescente de rendimento efetivamente recebido,
a preços médios do último ano

- Tabela 7552 (x) - Rendimento médio mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho,
efetivamente recebido em todos os trabalhos, a preços médios do último
ano, por classes acumuladas de percentual das pessoas em ordem crescente
de rendimento efetivamente recebido

- Tabela 7553 (x) - Distribuição da massa de rendimento mensal real das
pessoas de 14 anos ou mais de idade ocupadas na semana de referência
com rendimento de trabalho, efetivamente recebido em todos os trabalhos,
a preços médios do ano, por classes simples de percentual das pessoas
em ordem crescente de rendimento efetivamente recebido

- Tabela 7554 (x) - Distribuição da massa de rendimento mensal real das
pessoas de 14 anos ou mais de idade ocupadas na semana de referência
com rendimento de trabalho, efetivamente recebido em todos os trabalhos,
a preços médios do ano, por classes acumuladas de percentual das pessoas
em ordem crescente de rendimento efetivamente recebido

- Tabela 7559 (x) - Pessoas de 14 anos ou mais de idade ocupadas na semana
de referência com rendimento de trabalho, por classes acumuladas de
percentual das pessoas em ordem crescente de rendimento efetivamente
recebido, a preços médios do ano

- Tabela 7560 (x) - Pessoas de 14 anos ou mais de idade ocupadas na semana
de referência com rendimento de trabalho, por classes acumuladas de
percentual das pessoas em ordem crescente de rendimento efetivamente
recebido, a preços médios do último ano

- Tabela 7561 (x) - População residente, por classes acumuladas de percentual
das pessoas por rendimento domiciliar per capita, a preços médios do ano

- Tabela 7562 (-) - Pessoas de 14 anos ou mais de idade ocupadas na semana
de referência com rendimento de trabalho, por classes acumuladas de
percentual das pessoas em ordem crescente de rendimento habitualmente
recebido, a preços médios do ano

- Tabela 7563 (-) - Pessoas de 14 anos ou mais de idade ocupadas na semana
de referência com rendimento de trabalho, por classes acumuladas de
percentual das pessoas em ordem crescente de rendimento habitualmente
recebido, a preços médios do último ano

- Tabela 7564 (x) - População residente, por classes acumuladas de percentual
das pessoas por rendimento domiciliar per capita, a preços médios do
último ano

## Notas Técnicas Relevantes

- [Sobre a composição da variável renda domiciliar per capita](https://www.ibge.gov.br/novo-portal-destaques/25466-pnad-continua-mudanca-no-calculo-do-rendimento-domiciliar.html)
- 

## Links úteis:

- [Tabelas de referência](https://sidra.ibge.gov.br/pesquisa/pnadca/tabelas)
- [Pacote do R para análise da PNADc](https://rpubs.com/gabriel-assuncao-ibge/pnadc)
- [PNADcIBGE Renda Domiciliar Per Capita](https://github.com/Gabriel-Assuncao/PNADcIBGE-RDPC/tree/main)
