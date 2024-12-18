#=========== EM ELABORAÇÃO. NÃO UTILIZAR ==============#

# Reproduz tabelas SIDRA da PNADC/A, 5a visita, recortando os dados
# para os dez estratos geográficos de Minas Gerais.
# Tema das tabelas: Rendimento de todas as fontes.
#
# Gerar resultados automaticamente para todas as tabelas
#
# João Paulo Gonzaga Garcia: joaopauloggarcia@gmail.com
#----------------------------------------------------------

# PREPARAR O AMBIENTE

pacotes <- c("PNADcIBGE", "survey")
install.packages(setdiff(pacotes, rownames(installed.packages())))
lapply(pacotes, library, character.only = TRUE)

source("utilitarios.R")   # funções e objetos que podem ser utilizados manualmente

plano_amostral <- gerar_pa()  # ler e preparar os microdados

# TABELA 7426 - População residente com rendimento, por tipo de rendimento

plano_amostral$variables <- transform(
	plano_amostral$variables,
	Possui_Renda_Habitual = factor(
		ifelse(!is.na(VD4020), "Sim", "Não"),
		levels = c("Sim", "Não"),  # ordem padrão das variáveis (colunas)
	)
)

pop_estimada_7426 <- list(
	habitual = estimar_pop(plano_amostral, "Possui_Renda_Habitual"),
	aposent  = estimar_pop(plano_amostral, "V5004A"),
	aluguel  = estimar_pop(plano_amostral, "V5007A"),
	pensao_aliment = estimar_pop(plano_amostral, "V5006A"),
	outros = estimar_pop(plano_amostral, "V5008A")
)

# calcular coeficientes de variação
cv_7426 <- lapply(
	pop_estimada_7426,
	function(obj) { head(cv(obj), n = 10) }  # 10 primeiros correspondem a "Sim"
)
names(cv_7426) <- names(pop_estimada_7426)

# TABELA 7427- Massa de rendimento mensal real domiciliar per capita, a preços médios do último ano, por classes simples de percentual das pessoas em ordem crescente de rendimento domiciliar per capita

# classes de percentual das pessoas em ordem crescente de rendimento
# domiciliar per capita (5% em 5%)

# TABELA 7428 - Massa de rendimento mensal real domiciliar per capita, a preços médios do ano, por classes simples de percentual das pessoas em ordem crescente de rendimento domiciliar per capita

# TABELA 7429 - Participação percentual na composição do rendimento médio mensal real domiciliar per capita, a preços médios do ano, por tipo de rendimento
