############### RASCUNHO ##################

pacotes <- c("sidrar", "PNADcIBGE", "survey", "convey", "tibble")
lapply(pacotes, library, character.only = TRUE)
options(scipen = 999)

variaveis <- c("V2001", "V2005", "VD4019", "VD4048", "VD5007", "VD5008")

pnadc_ano = 2023
visita = 1
pnadc_dir = "Microdados"

if (file.exists("desenho_amostral.RDS")) {
	desenho_amostral <- readRDS("desenho_amostral.RDS")
} else {
	microdados <- list.files(
		pnadc_dir,
		paste0("^PNADC_", pnadc_ano, "_visita", visita, ".*txt$"),
		full.names = TRUE
	)
	input <- list.files(
		pnadc_dir,
		paste0("^input_PNADC_", pnadc_ano, "_visita", visita, ".*txt$"),
		full.names = TRUE
	)
	dicionario <- list.files(
		pnadc_dir,
		paste0("^dicionario_PNADC_microdados_", pnadc_ano,
			"_visita", visita, ".*xls$"),
		full.names = TRUE
	)
	deflator <- file.path(
		pnadc_dir,
		paste0("deflator_PNADC_", pnadc_ano, ".xls")
	)
	desenho_amostral <- pnadc_deflator(
		pnadc_labeller(
			data_pnadc = read_pnadc(
				microdata = microdados,
				input = input,
				vars = c(variaveis, "UF", "V2009")  # sempre importar UF e Idade
			),
			dictionary.file = dicionario
		),
		deflator.file = deflator
	)
	desenho_amostral <- pnadc_design(
		subset(desenho_amostral, UF == "Minas Gerais")
	)
}

# 2) Rendimento Domiciliar Per Capita a preços médios do último/próprio ano
# 7427(7428), 7526(7438), 7458, 7529(7521), (7527), (7530), 7533(7531),
# 7534(7532), 7564(7561)

# as 3 categorias abaixos são excluídas no cálculo da rendimento domiciliar
desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	V2005.Incluidas = ifelse(
		V2005 == "Pensionista" |
		V2005 == "Empregado(a) doméstico(a)" |
		V2005 == "Parente do(a) empregado(a) doméstico(a)",
		0, 1
	)
)

# moradores por domicílio incluídos no cálculo do rendimento domiciliar
desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	V2001.Incluidos = ave(V2005.Incluidas, ID_DOMICILIO, FUN = sum)
)

# ÚLTIMO ANO -----------------------
# rendimento habitual de todos os trabalhos e efetivo de outras fontes
# a preços médios do último ano
desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	VD4019.Real2 = ifelse(
		is.na(VD4019) | V2005.Incluidas == 0 | V2009 < 14,
		0, VD4019 * CO2
	),
	VD4048.Real2 = ifelse(
		is.na(VD4048) | V2005.Incluidas == 0,
		0, VD4048 * CO2e
	)
)

# rendimento domiciliar per capita a preços médios do último ano
desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	VD5007.Real2 = ave(
		VD4019.Real2 + VD4048.Real2,
		ID_DOMICILIO,
		FUN = sum
	)
)

# rendimento domiciliar per capita a preços médios do último ano
desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	VD5008.Real2 = ifelse(
		V2005.Incluidas == 0 | V2001.Incluidos == 0,
		0, VD5007.Real2 / V2001.Incluidos)
)

# 7526 - pequenas diferenças nos últimos dois quantis
sidra_7526 <- get_sidra(x = 7526, variable = 10838, period = "2023",
	geo = "State", geo.filter = 31, header = TRUE, format = 2)

est_7526 <- svyquantile(
	~VD5008.Real2,
	subset(desenho_amostral, V2005.Incluidas == 1),
	quantiles = c(0.05, seq(0.10, 0.90, by = 0.10), 0.95, 0.99),
	na.rm = TRUE
)
quantis <- est_7526[[1]][, 1]

print(est_7526)
unname(sidra_7526[c(7,3)])

# 7529 - valores bem parecidos, diferença maior em P10 - P20
sidra_7529 <- get_sidra(x = 7529, variable = 606, period = "2023",
	geo = "State", geo.filter = 31, header = TRUE, format = 2)
sidra_7529 <- transform(sidra_7529, Valor = Valor * 1000)

# classes simples de percentual (CSP)
desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	CSP.VD5008.Real2 = cut(
		VD5008.Real2,
		breaks = c(-Inf, quantis, Inf),
		labels = c(
			"Até P5",
			"Maior que P5 até P10",
			"Maior que P10 até P20",
			"Maior que P20 até P30",
			"Maior que P30 até P40",
			"Maior que P40 até P50",
			"Maior que P50 até P60",
			"Maior que P60 até P70",
			"Maior que P70 até P80",
			"Maior que P80 até P90",
			"Maior que P90 até P95",
			"Maior que P95 até P99",
			"Maior que P99"
		),
		right = TRUE
	)
)

est_7529 <- svyby(~V2005.Incluidas, ~CSP.VD5008.Real2, desenho_amostral, svytotal)
print(est_7529)
unname(sidra_7529[c(7,3)])

# 7564
sidra_7564 <- get_sidra(x = 7564, variable = 606, period = "2023",
	geo = "State", geo.filter = 31, header = TRUE, format = 2)
sidra_7564 <- transform(sidra_7564, Valor = Valor * 1000)

est_7564 <- data.frame(
	Classes.Acumuladas = c(paste0("Até P", c(5, 1:9 * 10, 95, 99)), "Total"),
	Populacao = cumsum(est_7529[[2]])
)

# 7427 - valores parecidos, mas a maioria é diferente
sidra_7427 <- get_sidra(x = 7427, variable = 10495, period = "2023",
	geo = "State", geo.filter = 31, header = TRUE, format = 2)
sidra_7427 <- transform(sidra_7427, Valor = Valor * 10^6)

est_7427 <- svyby(
	~VD5008.Real2,
	~CSP.VD5008.Real2,
	subset(desenho_amostral, V2005.Incluidas == 1),
	FUN = svytotal
)

print(est_7427)
unname(sidra_7427[c(7,3)])

# 7533 - valores bem parecidos, maiores diferenças em P95 e P99
sidra_7533 <- get_sidra(x = 7533, variable = 10816, period = "2023",
	geo = "State", geo.filter = 31, header = TRUE, format = 2)

est_7533 <- svyby(~VD5008.Real2, ~CSP.VD5008.Real2, desenho_amostral, svymean)
unname(sidra_7533[c(7,3)])

# 7534 - valores bem parecidos, maiores diferenças em P95 e P99
sidra_7534 <- get_sidra(x = 7534, variable = 10816, period = "2023",
	geo = "State", geo.filter = 31, header = TRUE, format = 2)

est_7534 <- data.frame(
	Classes.Acumuladas = c(paste0("Até P", c(5, 1:9 * 10, 95, 99)), "Total"),
	RMeDPC = cumsum(est_7427[[2]] * est_7533[[2]]) / cumsum(est_7533[[2]])
)

print(est_7534)
unname(sidra_7534[c(7,3)])
