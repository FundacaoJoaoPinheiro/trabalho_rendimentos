# Projeto: Estatísticas experimentais de mercado de trabalho para o estratos geográficos de Minas Gerais - anual

Projeto desenvolvido pela **Coordenação de Indicadores Sociais da Diretoria de Estatística e Informações da Fundação João Pinheiro / Grupo de Pesquisa em Estatística Públicas (EstatPúblicas)**.  

**Objetivo:** Estudar a qualidade das informações da Pesquisa Nacional por Amostra de Domicílios Contínua Anual (PNAD Contínua) em estratos geográficos de Minas Gerais.  

**Financiamento:** FAPEMIG  

## Conteúdo do Diretório
Nesse diretório são apresentados os scripts em R que reproduzem as tabelas do SIDRA do tema
"Rendimento de todas as fontes" (referentes à  PNAD contínua anual,
5ª visita), adicionando o recorte territorial dos estratos geográficos de
Minas Gerais.

## Requisitos
- **R** (versão >= 4.1.0)
- Pacotes R necessários:
  - [`PNADcIBGE`](https://cran.r-project.org/web/packages/PNADcIBGE/index.html) (para acesso aos microdados da PNAD Contínua)
  - [`survey`](https://cran.r-project.org/web/packages/survey/index.html) (para análise de dados amostrais complexos)
  - *Opcional*: [`sidrar`](https://cran.r-project.org/web/packages/sidrar/index.html) (para comparação com tabelas oficiais do SIDRA)

## Instruções

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

- Tabela 7426 - População residente com rendimento, por tipo de rendimento

- Tabela 7427 - Massa de rendimento mensal real domiciliar per capita,
a preços médios do último ano, por classes simples de percentual das
pessoas em ordem crescente de rendimento domiciliar per capita

- Tabela 7428 - Massa de rendimento mensal real domiciliar per capita,
a preços médios do ano, por classes simples de percentual das pessoas
em ordem crescente de rendimento domiciliar per capita

- Tabela 7429 - Participação percentual na composição do rendimento
médio mensal real domiciliar per capita, a preços médios do ano, por
tipo de rendimento

- Tabela 7430 - Massa de rendimento mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho,
de todos os trabalhos

- Tabela 7431 - Pessoas de 14 anos ou mais de idade ocupadas na semana de
referência com rendimento, por cor ou raça

- Tabela 7432 - Pessoas de 14 anos ou mais de idade ocupadas na semana de
referência com rendimento, por grupo de idade

- Tabela 7433 - Pessoas de 14 anos ou mais de idade ocupadas na semana de
referência com rendimento, por nível de instrução

- Tabela 7434 - Pessoas de 14 anos ou mais de idade ocupadas na semana de
referência com rendimento, por sexo

- Tabela 7435 - Índice de Gini do rendimento domiciliar per capita,
a preços médios do ano

- Tabela 7436 - População residente

- Tabela 7437 - Rendimento médio mensal real da população residente
com rendimento, por tipo de rendimento

- Tabela 7438 - Limites superiores das classes de percentual das pessoas em
ordem crescente de rendimento domiciliar per capita, a preços médios do ano

- Tabela 7439 - Pessoas de 14 anos ou mais de idade ocupadas na semana de
referência com rendimento e responsáveis pelo domicílio

- Tabela 7441 - Rendimento médio mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho,
de todos os trabalhos, a preços médios do último ano, por cor ou raça

- Tabela 7442 - Rendimento médio mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho,
de todos os trabalhos, a preços médios do último ano, por grupo de idade

- Tabela 7443 - Rendimento médio mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho,
de todos os trabalhos, a preços médios do último ano, por nível de
instrução

- Tabela 7444 - Rendimento médio mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho,
de todos os trabalhos, a preços médios do último ano, por sexo

- Tabela 7445 - Rendimento médio mensal real das pessoas de 14 anos
ou mais de idade ocupadas na semana de referência com rendimento de
trabalho, de todos os trabalhos, a preços médios do último ano, por
tipo de área geográfica

- Tabela 7446 - Rendimento médio mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho
e responsáveis pelo domicílio, de todos os trabalhos, a preços médios
do último ano

- Tabela 7447 - Pessoas de 10 anos ou mais de idade cujo domicílio possui
algum morador que recebeu rendimento do Programa Bolsa Família, por nível
de instrução

- Tabela 7448 - Pessoas de 10 anos ou mais de idade cujo domicílio não
possui morador que recebeu rendimento do Programa Bolsa Família, por
nível de instrução

- Tabela 7449 - Domicílios em que algum morador do domicílio recebeu
rendimento do Programa Bolsa Família, por posse ou acesso a bens ou
serviços

- Tabela 7450 - Domicílios em que nenhum morador do domicílio recebeu
rendimento do Programa Bolsa Família, por posse ou acesso a bens ou
serviços

- Tabela 7451 - Domicílios em que algum morador do domicílio recebeu
rendimento do Benefício de Prestação Continuada, por posse ou acesso
a bens ou serviços

- Tabela 7452 - Domicílios em que nenhum morador do domicílio recebeu
rendimento do Benefício de Prestação Continuada, por posse ou acesso
a bens ou serviços

- Tabela 7453 - Índice de Gini do rendimento médio mensal real das
pessoas de 14 anos ou mais de idade ocupadas na semana de referência
com rendimento de trabalho, habitualmente recebido em todos os trabalhos,
a preços médios do ano

- Tabela 7454 - Pessoas de 10 anos ou mais de idade cujo domicílio possui
algum morador que recebeu rendimento do Benefício de Prestação Continuada,
por nível de instrução

- Tabela 7455 - Pessoas de 10 anos ou mais de idade cujo domicílio
não possui morador que recebeu rendimento do Benefício de Prestação
Continuada, por nível de instrução

- Tabela 7456 - Número médio de moradores por domicílio, por recebimento
de rendimento de programa social e tipo de programa social

- Tabela 7457 - Domicílios, por recebimento de rendimento de programa
social e tipo de programa social

- Tabela 7458 - Rendimento médio mensal real domiciliar per capita, a
preços médios do último ano, por recebimento de rendimento de programa
social e tipo de programa social

- Tabela 7521 - População residente, por classes simples de percentual
das pessoas por rendimento domiciliar per capita, a preços médios do ano

- Tabela 7526 - Limites superiores das classes de percentual das pessoas
em ordem crescente de rendimento domiciliar per capita, a preços médios
do último ano

- Tabela 7527 - Distribuição da massa de rendimento mensal real domiciliar
per capita, a preços médios do ano, por classes simples de percentual
das pessoas em ordem crescente de rendimento domiciliar per capita

- Tabela 7529 - População residente, por classes simples de percentual
das pessoas por rendimento domiciliar per capita, a preços médios do
último ano

- Tabela 7530 - Distribuição da massa de rendimento mensal real domiciliar
per capita, a preços médios do ano, por classes acumuladas de percentual
das pessoas em ordem crescente de rendimento domiciliar per capita

- Tabela 7531 - Rendimento médio mensal real domiciliar per capita,
a preços médios do ano, por classes simples de percentual das pessoas
em ordem crescente de rendimento domiciliar per capita

- Tabela 7532 - Rendimento médio mensal real domiciliar per capita, a
preços médios do ano, por classes acumuladas de percentual das pessoas
em ordem crescente de rendimento domiciliar per capita

- Tabel 7533 - Rendimento médio mensal real domiciliar per capita,
a preços médios do último ano, por classes simples de percentual das
pessoas em ordem crescente de rendimento domiciliar per capita

- Tabel 7534 - Rendimento médio mensal real domiciliar per capita, a
preços médios do último ano, por classes acumuladas de percentual das
pessoas em ordem crescente de rendimento domiciliar per capita

- Tabela 7535 - Rendimento médio mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho,
habitualmente recebido em todos os trabalhos, a preços médios do ano, por
classes simples de percentual das pessoas em ordem crescente de rendimento
habitualmente recebido

- Tabela 7536 - Limites superiores das classes de percentual das pessoas
em ordem crescente de rendimento habitualmente recebido, a preços médios
do ano

- Tabela 7537 - Pessoas de 14 anos ou mais de idade ocupadas na semana de
referência com rendimento de trabalho, por classes simples de percentual
das pessoas em ordem crescente de rendimento habitualmente recebido,
a preços médios do ano

- Tabela 7538 - Rendimento médio mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho,
habitualmente recebido em todos os trabalhos, a preços médios do ano,
por classes acumuladas de percentual das pessoas em ordem crescente de
rendimento habitualmente recebido

- Tabela 7539 - Rendimento médio mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho,
habitualmente recebido em todos os trabalhos, a preços médios do último
ano, por classes simples de percentual das pessoas em ordem crescente de
rendimento habitualmente recebido

- Tabela 7540 - Limites superiores das classes de percentual das pessoas
em ordem crescente de rendimento habitualmente recebido, a preços médios
do último ano

- Tabela 7541 - Pessoas de 14 anos ou mais de idade ocupadas na semana de
referência com rendimento de trabalho, por classes simples de percentual
das pessoas em ordem crescente de rendimento habitualmente recebido,
a preços médios do último ano

- Tabela 7542 - Rendimento médio mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho,
habitualmente recebido em todos os trabalhos, a preços médios do último
ano, por classes acumuladas de percentual das pessoas em ordem crescente
de rendimento habitualmente recebido

- Tabela 7543 - Distribuição da massa de rendimento mensal real das
pessoas de 14 anos ou mais de idade ocupadas na semana de referência
com rendimento de trabalho, habitualmente recebido em todos os trabalhos,
a preços médios do ano, por classes simples de percentual das pessoas
em ordem crescente de rendimento habitualmente recebido

- Tabela 7544 - Distribuição da massa de rendimento mensal real das
pessoas de 14 anos ou mais de idade ocupadas na semana de referência com
rendimento de trabalho, habitualmente recebido em todos os trabalhos, a
preços médios do ano, por classes acumuladas de percentual das pessoas
em ordem crescente de rendimento habitualmente recebido

- Tabela 7545 - Rendimento médio mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho,
efetivamente recebido em todos os trabalhos, a preços médios do ano, por
classes simples de percentual das pessoas em ordem crescente de rendimento
efetivamente recebido

- Tabela 7546 - Limites superiores das classes de percentual das pessoas em
ordem crescente de rendimento efetivamente recebido, a preços médios do ano

- Tabela 7547 - Pessoas de 14 anos ou mais de idade ocupadas na semana de
referência com rendimento de trabalho, por classes simples de percentual
das pessoas em ordem crescente de rendimento efetivamente recebido,
a preços médios do ano

- Tabela 7548 - Rendimento médio mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho,
efetivamente recebido em todos os trabalhos, a preços médios do ano,
por classes acumuladas de percentual das pessoas em ordem crescente de
rendimento efetivamente recebido

- Tabela 7549 - Rendimento médio mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho,
efetivamente recebido em todos os trabalhos, a preços médios do último
ano, por classes simples de percentual das pessoas em ordem crescente de
rendimento efetivamente recebido

- Tabela 7550 - Limites superiores das classes de percentual das pessoas
em ordem crescente de rendimento efetivamente recebido, a preços médios
do último ano

- Tabela 7551 - Pessoas de 14 anos ou mais de idade ocupadas na semana de
referência com rendimento de trabalho, por classes simples de percentual
das pessoas em ordem crescente de rendimento efetivamente recebido,
a preços médios do último ano

- Tabela 7552 - Rendimento médio mensal real das pessoas de 14 anos ou
mais de idade ocupadas na semana de referência com rendimento de trabalho,
efetivamente recebido em todos os trabalhos, a preços médios do último
ano, por classes acumuladas de percentual das pessoas em ordem crescente
de rendimento efetivamente recebido

- Tabela 7553 - Distribuição da massa de rendimento mensal real das
pessoas de 14 anos ou mais de idade ocupadas na semana de referência
com rendimento de trabalho, efetivamente recebido em todos os trabalhos,
a preços médios do ano, por classes simples de percentual das pessoas
em ordem crescente de rendimento efetivamente recebido

- Tabela 7554 - Distribuição da massa de rendimento mensal real das
pessoas de 14 anos ou mais de idade ocupadas na semana de referência
com rendimento de trabalho, efetivamente recebido em todos os trabalhos,
a preços médios do ano, por classes acumuladas de percentual das pessoas
em ordem crescente de rendimento efetivamente recebido

- Tabela 7559 - Pessoas de 14 anos ou mais de idade ocupadas na semana
de referência com rendimento de trabalho, por classes acumuladas de
percentual das pessoas em ordem crescente de rendimento efetivamente
recebido, a preços médios do ano

- Tabela 7560 - Pessoas de 14 anos ou mais de idade ocupadas na semana
de referência com rendimento de trabalho, por classes acumuladas de
percentual das pessoas em ordem crescente de rendimento efetivamente
recebido, a preços médios do último ano

- Tabela 7561 - População residente, por classes acumuladas de percentual
das pessoas por rendimento domiciliar per capita, a preços médios do ano

- Tabela 7562 - Pessoas de 14 anos ou mais de idade ocupadas na semana
de referência com rendimento de trabalho, por classes acumuladas de
percentual das pessoas em ordem crescente de rendimento habitualmente
recebido, a preços médios do ano

- Tabela 7563 - Pessoas de 14 anos ou mais de idade ocupadas na semana
de referência com rendimento de trabalho, por classes acumuladas de
percentual das pessoas em ordem crescente de rendimento habitualmente
recebido, a preços médios do último ano

- Tabela 7564 - População residente, por classes acumuladas de percentual
das pessoas por rendimento domiciliar per capita, a preços médios do
último ano

## Notas Técnicas Relevantes

- [Sobre a composição da variável renda domiciliar per capita](https://www.ibge.gov.br/novo-portal-destaques/25466-pnad-continua-mudanca-no-calculo-do-rendimento-domiciliar.html)

## Links úteis:

- [Tabelas de referência](https://sidra.ibge.gov.br/pesquisa/pnadca/tabelas)
- [Pacote do R para análise da PNADc](https://rpubs.com/gabriel-assuncao-ibge/pnadc)
- [PNADcIBGE Renda Domiciliar Per Capita](https://github.com/Gabriel-Assuncao/PNADcIBGE-RDPC/tree/main)

## Equipe Técnica:
- Coordenação de Indicadores Sociais: Caio Gonçalves
- Núcleo de Emprego, Renda, Educação e Gênero: Nícia Raies
- Desenvolvimento dos Scripts: João Paulo Garcia

## Dúvidas ou Contribuições
Abra uma issue neste repositório ou contate-nos via: dados@fjp.mg.gov.br


