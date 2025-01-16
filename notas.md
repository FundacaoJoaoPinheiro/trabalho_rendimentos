# Dúvidas e Observações

- Por que a pop. com rendimento habitual difere da pop. com rendimento
efetivo? O primeiro tipo está correspondendo com a tabela 7426, mas o
segundo está com o mesmo valor do primeiro, o que não corresponde com
a tabela.

- Para calcular a renda domiciliar per capita, para a renda estou escluindo
pensionistas, empregados e parentes de empregados, conforme nota no SIDRA.
Mas devo considerar todos os moradores no denominador? Os resultados foram
mais próximos das tabelas do SIDRA.

- Em relação às tabelas 7450 e 7451, como agrupar por posse ou acesso a bens
e serviços? Não encontrei variáveis no dicionário da quinta visita.

- Usar NA's ou zero no caso de rendimentos? Zero levou a estimativas mais
próximas das tabelas do SIDRA

# Pendências

- 7426: "Efetivamente recebido em todos os trabalhos". A pop. estimada com
rendimento habitual e efetivo estão iguais, embora sejam diferentes na
tabela do SIDRA.

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
| VD4019       | Rendimento mensal habitual de todos os trabalhos para pessoas de
|              | 14 anos ou mais
| VD4020       | Rendimento mensal efetivo de todos os trabalhos para pessoas de
|              | 14 anos ou mais
| VD4048       | Rendimento efetivo recebido de outras fontes
| VD5011       | Rendimento domiciliar per capita

# Testes

# Colunas Criadas

- Estrato_G - Estratos geográficos (todas as tabelas)
- V2005.incluidas (todas que lidam com RDPC)
- V2005.incluidos (o mesmo)
- VD4019.Real2 (todas que lidam com RDPC a preços médios do último ano)
- VD4048.Real2 (o mesmo)
- VD5007.Real2 (o mesmo)
- VD5008.Real2 (o mesmo)
- CSP_VD5008.Real (todas que lidam com classes percentuais de RDPC)
- VD4019.Real1 (todas que lidam com RDPC a preços médios do ano)
- VD4048.Real1 (o mesmo)
- VD5007.Real1 (o mesmo)
- VD5008.Real1 (o mesmo)
- CSP_VD5008.Real1 (7428,
