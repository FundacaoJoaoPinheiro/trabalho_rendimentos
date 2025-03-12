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

- opcional: [sidrar](https://cran.r-project.org/web/packages/sidrar/index.html)).

# Instruções

O arquivo `utilitarios.R` define alguns objetos e funções que podem ser utilizados
manualmente. Abaixo, seguem alguns exemplos de como utilizar essas funções.

Criar um objeto com o plano amostral, fazendo o download dos arquivos
de microdados do FTP do IBGE e importando as variáveis relevantes para as
tabelas 7426 a 7429:

	library(PNADcIBGE)
	source("utilitarios.R")
	desenho <- gerar_desenho(c(7426:7429), download=TRUE)

Ler os dados diretamente do armazenamento interno pode ser mais rápido. Para
isso, os arquivos devem ser armazenados na pasta "Microdados". O shell
script baixar_microdados.sh pode ser usado no Linux e no macOs e faz o
download dos arquivos na pasta "Microdados" automaticamente. Usuários do
Windows podem copiar os links e colar no navegador para baixar (e mover os
arquivos para a pasta correta manualmente). O caminho para os arquivos de
microdados pode ser alterado com o objeto [`pnadc_dir`](utilitarios.R#L14):

	library(PNADcIBGE)
	source("utilitarios.R")
	pnadc_dir <- "Diretorio-Alternativo"
	desenho <- gerar_desenho(c(7426:7429))

O diretório `testes` possui rascunhos que fazem testes com os resultados para
4 UF's (Pará, Bahia, Minas Gerais e Goiás), comparando as estimativas com
as tabelas disponíveis no SIDRA (opcinonalmente, utilizando o pacote
[sidrar](https://cran.r-project.org/web/packages/sidrar/index.html)).

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

- Tabela 7439 (x) - Pessoas de 14 anos ou mais de idade ocupadas na semana de
referência com rendimento e responsáveis pelo domicílio

- Tabela 7440 (x) - Pessoas de 14 anos ou mais de idade ocupadas na semana de
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

- Tabela 7448 (x) - Pessoas de 10 anos ou mais de idade cujo domicílio não
possui morador que recebeu rendimento do Programa Bolsa Família, por
nível de instrução

- Tabela 7449 (x) - Domicílios em que algum morador do domicílio recebeu
rendimento do Programa Bolsa Família, por posse ou acesso a bens ou
serviços

- Tabela 7450 (x) - Domicílios em que nenhum morador do domicílio recebeu
rendimento do Programa Bolsa Família, por posse ou acesso a bens ou
serviços

- Tabela 7451 (x) - Domicílios em que algum morador do domicílio recebeu
rendimento do Benefício de Prestação Continuada, por posse ou acesso
a bens ou serviços

- Tabela 7452 (x) - Domicílios em que nenhum morador do domicílio recebeu
rendimento do Benefício de Prestação Continuada, por posse ou acesso
a bens ou serviços

- Tabela 7453 (x) - Índice de Gini do rendimento médio mensal real das
pessoas de 14 anos ou mais de idade ocupadas na semana de referência
com rendimento de trabalho, habitualmente recebido em todos os trabalhos,
a preços médios do ano

- Tabela 7454 (x) - Pessoas de 10 anos ou mais de idade cujo domicílio possui
algum morador que recebeu rendimento do Benefício de Prestação Continuada,
por nível de instrução

- Tabela 7455 (x) - Pessoas de 10 anos ou mais de idade cujo domicílio
não possui morador que recebeu rendimento do Benefício de Prestação
Continuada, por nível de instrução

- Tabela 7456 (x) - Número médio de moradores por domicílio, por recebimento
de rendimento de programa social e tipo de programa social

- Tabela 7457 (x) - Domicílios, por recebimento de rendimento de programa
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

- Tabela 7562 (x) - Pessoas de 14 anos ou mais de idade ocupadas na semana
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
