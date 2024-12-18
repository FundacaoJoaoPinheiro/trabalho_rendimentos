library(PNADcIBGE)
library(survey)

codvar_7426 <- c(
	"VD4019",  # Habitualmente recebido em todos os trabalhos (numeric)
	"VD4020",  # Efetivamente recebido em todos os trabalhos (numeric)
	"V5004A",  # Aposentadoria e pensão (factor)
	"V5007A",  # Aluguel e arrendamento (factor)
	"V5006A",  # Pensão alimentícia, doação e mesada de não morador (factor)
	"V5008A"   # Outros rendimentos (não inclui seguro-desemprego) (factor)
)

pnadc_5v <- pnadc_labeller(
	data_pnadc = read_pnadc(
		microdata = "Microdados/PNADC_2023_visita5.txt",
		input = "Microdados/input_PNADC_2023_visita5.txt",
		vars = codvar_7426
	),
dictionary.file = "Microdados/dicionario_PNADC_microdados_2023_visita5.xls"
)

pnadc_MG <- subset(pnadc_5v, UF == "Minas Gerais")
pnadc_MG <- pnadc_design(pnadc_MG)

pnadc_MG$variables <- transform(
	pnadc_MG$variables,
	possui_renda_efetiva = factor(
		ifelse(!is.na(VD4020), "Sim", "Não"),
		levels = c("Sim", "Não"),        # definir a ordem dos fatores será útil
	),
	estrato_geo = factor(substr(Estrato, 1, 4))  # 4 primeiros números do Estrato
)                                                # formam o estrato geografico

estimar_pop <- function(data, var) {
	formula <- as.formula(paste0("~interaction(estrato_geo, ", var, ")"))
  	svytotal(x = formula, design = data, na.rm = TRUE)
}

pop_estimada_7426 <- list(
	habitual = estimar_pop(pnadc_MG, "possui_renda_efetiva"),
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

#======================== Funcionando até aqui ==============================#
