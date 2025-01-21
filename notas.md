# Dúvidas e Observações

- Por que a pop. com rendimento habitual difere da pop. com rendimento
efetivo? O primeiro tipo está correspondendo com a tabela 7426, mas o
segundo está com idem valor do primeiro, o que não corresponde com
a tabela.

- Para calcular a renda domiciliar per capita, para a renda estou escluindo
pensionistas, empregados e parentes de empregados, conforme nota no SIDRA.
Mas devo considerar todos os moradores no denominador? Os resultados foram
mais próximos das tabelas do SIDRA.

# Pendências

- 7426: "Efetivamente recebido em todos os trabalhos". A pop. estimada com
rendimento habitual e efetivo estão iguais, embora sejam diferentes na
tabela do SIDRA.

# Resultados Preliminares

- 7536: CV's acima de 25% apareceram para o estrato geográfico
"Integrada de Brasília em Minas Gerais" (3140)

- 7438 : CV's acima dos apresentados no SIDRA, mas em geral ficam em torno
de 10%, passando de 20% apenas nas últimas classes

- 7428: CV's mais altos

- 7441: CV's bastante altos. `svyby()` retornou erros, talvez tenha algo errado

- 7442: a maioria dos CV's está abaixo de 10%, mas alguns estão acima

- 7443: a maioria dos CV's está abaixo de 10%, mas alguns estão acima

- 7535: maior parte dis CV's abaixo de 10% e poucos passam de 20%

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

# Colunas Criadas

- Estrato.Geo - Estratos geográficos (todas as tabelas)
- Outros.Rendimentos (Tipo de Rendimento)
- V2005.incluidas (todas que lidam com RDPC)
- V2005.incluidos (idem)
- VD4019.Real2 (todas que lidam com RDPC a preços médios do último ano)
- VD4048.Real2 (idem)
- VD5007.Real2 (idem)
- VD5008.Real2 (idem)
- CSP_VD5008.Real2 (idem)
- VD4019.Real1 (todas que lidam com RDPC a preços médios do ano)
- VD4048.Real1 (idem)
- VD5007.Real1 (idem)
- VD5008.Real1 (idem)
- CSP_VD5008.Real1 (idem)
- Ocupadas.com.Rendimento (7431 a 7434)
