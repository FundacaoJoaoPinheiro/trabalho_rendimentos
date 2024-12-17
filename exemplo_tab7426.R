# Exemplo para apenas uma tabela (7426)
#----------------------------------------------------------

# Preparar o ambiente: listar pacotes; instalar pacotes não instalados;
# carregar a lista de pacotes.

pacotes <- c("PNADcIBGE", "survey")
install.packages(setdiff(pacotes, rownames(installed.packages())))
lapply(pacotes, library, character.only = TRUE)

# Ler os microdados: 1) ler os dados diretamente do armazenamento
# interno (por padrão, buscar arquivos na pasta "microdados"; edite os
# caminhos de acordo com sua preferência).

codvar_7426 <- c(
	"VD4019",  # Habitualmente recebido em todos os trabalhos
	"VD4020",  # Efetivamente recebido em todos os trabalhos
	"V5004A",  # Aposentadoria e pensão
	"V5007A",  # Aluguel e arrendamento
	"V5006A",  # Pensão alimentícia, doação e mesada de não morador
	"V5008A"   # Outros rendimentos (não incluí seguro-desemprego)
)

pnadc_BR <- pnadc_labeller(
	data_pnadc = read_pnadc(
		microdata = "Microdados/PNADC_2023_visita5.txt",
		input = "Microdados/input_PNADC_2023_visita5.txt",
		vars = codvar_7426
	),
	dictionary.file = "Microdados/dicionario_PNADC_microdados_2023_visita5.xls"
)

# Preparar dados: 1) Filtrar UF para Minas Gerais; 2) adicionar uma coluna
# "categorizando" a variável de renda efetiva; 3) formatar os dados para usar
# com o pacote "survey".

pnadc_MG <- subset(pnadc_BR, UF == "Minas Gerais")
rm(pnadc_BR)
pnadc_MG <- pnadc_design(pnadc_MG)

pnadc_MG$variables <- transform(
	pnadc_MG$variables,
	possui_renda_efetiva = factor(
		ifelse(!is.na(VD4020), "Sim", "Não"),
		levels = c("Sim", "Não"),     # definir essa ordem é útil para padronizar
	),                                # a saída da função svytotal() à frente
	estrato_geo = factor(substr(Estrato, 1, 4))   # 4 primeiros números do Estrato
)                                                 # formam o estrato geografico


# Estimar população e calcular coeficiente de variação. A função estimar_pop()
# cria uma string com a fórmula que será usada na função svytotal(), para estimar
# a população por tipo de rendimento (argumento var) e estrato geográfico.
# Ex: svytotal(x = ~interaction(estrato_geo, V5004A), desgin = pnadc_MG, na.rm = T)

estimar_pop <- function(data, var) {
	formula <- as.formula(paste0("~interaction(estrato_geo, ", var, ")"))
  	svytotal(x = formula, design = data, na.rm = TRUE)
}

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
