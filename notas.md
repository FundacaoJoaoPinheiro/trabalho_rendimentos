# Dúvidas e Observações

- Por que a pop. com rendimento habitual difere da pop. com rendimento
efetivo? O primeiro tipo está correspondendo com a tabela 7426, mas o
segundo está com idem valor do primeiro, o que não corresponde com
a tabela.

- Para calcular a renda domiciliar per capita, para a renda estou excluindo
pensionistas, empregados e parentes de empregados, conforme nota no SIDRA.
Mas devo considerar todos os moradores no denominador?

# Comparando resultados com o SIDRA

## Resultados praticamente idênticos

Tabelas: 7526, 7533, 7534, 7527, 7530, 7435, 7544, 7431, 7432, 7433,
7434, 7439, 7436, 7447, 7441, 7442, 7443, 7444, 7445, 7446, 7453,
7534, 7538, 7539, 7542, 7426*, 7429

* rendimento efetivamente recebido em todos os trabalhos é o único diferente.

## Resultados mais ou menos próximos

Tabelas: 7529, 7564, 7427, 7431, 7432, 7433, 7434, 7449, 7431, 7432, 7433,
7434

## Resultados diferentes
Tabelas: 7458

## CV' altos (muitos valores acima de 20%)
* RPDC: 7521;
* progsociais: 7447, 7454, 7451;

## CV's médios (muitos valores entre 10% e 20%)
* RPDC: 7537, 7538, 7438;
* ocupada: 7432 (valores médios todos concentrados nos dois primeiros grupos
de idade), 7433 (valores bem altos para "sem instrução", muuitos próximos de
15% e alguns acima de 25%); 7537, 7547
* RMe: 7537;
* progsociais: 7448 (médio-baixo), 7449;

## CV's baixos (próximos de 10% em média)
* RPDC: 7435, 7535 (1 valor alto), 7545 (2 valores altos), 7548, 7435,
* ocupada: 7431 (baixos para Branca, Preta e Parda), 7434, 7439, 7559, 7562;
* fontes: 7426 (maioria abaixo de 10%, com valores médios nas últimas três
fontes), 7429, 7437 (parecido com 7426);
* RMe: 7453, 7535 (um valor prox. a 50%), 7538, 7545 (2 NA's e 4 CV's
acima de 20%), 7548 (2 NA's);
* progsociais: 7450, 7452, 7456, 7457;

## Não consegui reproduzir os CV's
* RPDC: 7527, 7530

# Variáveis utilizadas

| Variável     | Descrição
|--------------|-----------------------
| ID_DOMICILIO | UPA + V1008 + V1014
| UF           | Unidade Federativa
| V1023        | Tipo de Área
| V2001        | Número de pessoas no domicílio
| V2005        | Condição no domicílio
| V2007        | Sexo
| V2009        | Idade do morador na data de referência
| V2010        | Cor ou raça
| V4009        | Quantos trabalhos tinha na semana de referência?
| V4033        | Qual era o rendimento bruto mensal que recebia nesse trabalho?
| V5001A       | Recebeu rendimentos de Benefício Assistencial de Prestação
|              | Continuada?
| V5002A       | Recebeu rendimentos de Programa Bolsa Família?
| V5003A       | Recebeu rendimentos de outros programas sociais do governo?
| V5004A       | Recebeu rendimentos de aposentadoria ou pensão de INSS
| V5004A2      | Valor efetivamente recebido
| V5005A       | Recebeu rendimentos de seguro/desemprego, seguro/defeso?
| V5005A2      | Valor efetivamente recebido
| V5006A       | Recebeu rendimentos de pensão alimentícia...
| V5006A2      | Valor efetivamente recebido
| V5007A       | Recebeu rendimentos de aluguel ou arrendamento?
| V5007A2      | Valor efetivamente recebido
| V5008A       | Recebeu outros rendimentos (bolsa de estudos, etc)
| V5008A2      | Valor efetivamente recebido
| V4034        | Qual foi o rendimento bruto que recebeu/fez nesse trabalho
| VD3004       | Nível de instrução mais elevado alcançado
| VD4002       | Condição de ocupação
| VD4019       | Rendimento mensal habitual de todos os trabalhos para pessoas de
|              | 14 anos ou mais
| VD4020       | Rendimento mensal efetivo de todos os trabalhos para pessoas de
|              | 14 anos ou mais
| VD4048       | Rendimento efetivo recebido de outras fontes
| VD4052       | Rendimento de todas as fontes
| S01007       | Forma de abastecimento de água
| S01012A      | Para onde vai o esgoto do banheiro
| S01013       | Qual é o (principal) destino dado ao lixo?
| S01014       | Origem da energia elétrica utilizada neste domicílio?
| S01023       | Este domicílio tem geladeira?
| S01024       | Este domicílio tem máquina de lavar roupa?
| S01025       | Este domicílio tem televisão?
| S01028       | Este domicílio tem microcomputador?
