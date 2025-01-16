############### RASCUNHO ##################
# comparar valores estimados para MG na sessão do R com aqueles disponíveis 
# nas tabelas da plataforma SIDRA

pacotes <- c("sidrar", "PNADcIBGE", "survey")
lapply(pacotes, library, character.only = TRUE)
options(scipen = 999)

variaveis <- c("V2001", "V2005", "VD4019", "VD4048", "V5001A", "V5002A", "V5003A")

pnadc_ano = 2023
visita = 1
pnadc_dir = "Microdados"

if (file.exists("desenho_ocupadas.RDS")) {
	desenho_amostral <- readRDS("desenho_ocupadas.RDS")
} else {
	microdados <- "Microdados/PNADC_2023_visita1.txt"
	input <- "Microdados/input_PNADC_2023_visita1_20241220.txt"
	dict <- "Microdados/dicionario_PNADC_microdados_2023_visita1_20241220.xls"
	deflator <- "Microdados/deflator_PNADC_2023.xls"
	desenho_amostral <- pnadc_deflator(
		pnadc_labeller(
			data_pnadc = read_pnadc(
				microdata = microdados,
				input = input,
				vars = c(variaveis, "UF", "V2009")  # sempre importar UF e Idade
			),
			dictionary.file = dict
		),
		deflator.file = deflator
	)
	desenho_amostral <- pnadc_design(
		subset(desenho_amostral, UF == "Minas Gerais")
	)
}
	
desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	Estrato_G = factor(substr(Estrato, 1, 4))
)

# 2) Rendimento Domiciliar Per Capita a preços médios do último/próprio ano
# 7427(7428), 7429, 7526(7438), 7458, 7529(7521), (7527), (7530), 7533(7531),
# 7534(7532), 7564(7561) --------------------------------------------------

# as 3 categorias abaixos são excluídas no cálculo da rendimento domiciliar
desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	V2005.Incluidas = ifelse(
		V2005 == "Pensionista" |
		V2005 == "Empregado(a) doméstico(a)" |
		V2005 == "Parente do(a) empregado(a) doméstico(a)",
		NA, 1
	)
)

# moradores por domicílio incluídos no cálculo do rendimento domiciliar
desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	V2001.Incluidos = ave(
		V2005.Incluidas,
		ID_DOMICILIO,
		FUN = function(x) sum(x, na.rm=T)
	)
)

# ÚLTIMO ANO -----------------------

# rendimento habitual de todos os trabalhos e efetivo de outras fontes
# a preços médios do último ano (obs: em 2023 CO1 = CO2 e CO1e = CO2e)
desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	VD4019.Real2 = ifelse(
		is.na(VD4019) | is.na(V2005.Incluidas) | V2009 < 14,
		0, VD4019 * CO2
	),
	VD4048.Real2 = ifelse(
		is.na(VD4048) | is.na(V2005.Incluidas),
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
		is.na(V2005.Incluidas),
		0, VD5007.Real2 / V2001.Incluidos
	)
)

# 7526 - pequenas diferenças nos últimos dois quantis
sidra_7526 <- get_sidra(x = 7526, variable = 10838, period = "2023",
	geo = "State", geo.filter = 31, header = TRUE, format = 2)

limites_RDPC2 <- svyquantile(
	~VD5008.Real2,
	desenho_amostral,
	quantiles = c(0.05, seq(0.10, 0.90, by = 0.10), 0.95, 0.99)
)
quantis2 <- limites_RDPC2[[1]][, 1]

print(limites_RDPC2)
unname(sidra_7526[c(7,3)])

# 7529 - valores bem parecidos, diferença maior em P5 - P10
sidra_7529 <- get_sidra(x = 7529, variable = 606, period = "2023",
	geo = "State", geo.filter = 31, header = TRUE, format = 2)
sidra_7529 <- transform(sidra_7529, Valor = Valor * 1000)

# classes simples de percentual (CSP)
rotulos_CSP = c(
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
)

desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	CSP.VD5008.Real2 = cut(
		VD5008.Real2,
		breaks = c(-Inf, quantis2, Inf),
		labels = rotulos_CSP,
		right = TRUE
	)
)

pop_CSP_RDPC2 <- svyby(
	~V2005.Incluidas,
	~CSP.VD5008.Real2,
	desenho_amostral,
	FUN = svytotal,
	na.rm = TRUE
)

print(pop_CSP_RDPC2)
unname(sidra_7529[c(7,3)])

# 7564 - evidentemente, o mesmo de 7529
sidra_7564 <- get_sidra(x = 7564, variable = 606, period = "2023",
	geo = "State", geo.filter = 31, header = TRUE, format = 2)
sidra_7564 <- transform(sidra_7564, Valor = Valor * 1000)

# classes acumuladas de percentual (CASP)
rotulos_CAP = c(paste0("Até P", c(5, 1:9 * 10, 95, 99)), "Total")

pop_CAP_RDPC2 <- data.frame(
	Classes.Acumuladas = rotulos_CAP,
	Populacao = cumsum(pop_CSP_RDPC2[[2]])
)

print(pop_CAP_RDPC2)
unname(sidra_7564[c(7,3)])

# 7427 - valores parecidos, mas a maioria é diferente
sidra_7427 <- get_sidra(x = 7427, variable = 10495, period = "2023",
	geo = "State", geo.filter = 31, header = TRUE, format = 2)
sidra_7427 <- transform(sidra_7427, Valor = Valor * 10^6)

massa_RDCP2 <- svyby(
	~VD5008.Real2,
	~CSP.VD5008.Real2,
	desenho_amostral,
	FUN = svytotal
)

print(massa_RDCP2)
unname(sidra_7427[c(7,3)])

# 7533 - valores bem parecidos, maiores diferenças em P95 e P99
sidra_7533 <- get_sidra(x = 7533, variable = 10816, period = "2023",
	geo = "State", geo.filter = 31, header = TRUE, format = 2)

RMeDPC2_CSP <- svyby(
	~VD5008.Real2,
	~CSP.VD5008.Real2,
	desenho_amostral,
	FUN = svymean
)
unname(sidra_7533[c(7,3)])

# 7534 - valores bem parecidos
sidra_7534 <- get_sidra(x = 7534, variable = 10816, period = "2023",
	geo = "State", geo.filter = 31, header = TRUE, format = 2)

RMeDPC2_CAP <- data.frame(
	Classes.Acumuladas = rotulos_CAP,
	RMe.Dom.Per.Capita =
		cumsum(RMeDPC2_CSP[[2]] * pop_CSP_RDPC2[[2]]) / # Somatório (RMe x pop) /
			cumsum(pop_CSP_RDPC2[[2]])                  # Somatório (pop)
)

print(RMeDPC2_CAP)
unname(sidra_7534[c(7,3)])

# 7429

# 7458
sidra_7458 <- get_sidra(x = 7458, variable = 10816, period = "2023",
	geo = "State", geo.filter = 31, header = TRUE, format = 2)

RMeDPC2_prog_social <- svybys(
	~VD5008.Real2,
	~V5001A + V5002A + V5003A,
	desenho_amostral,
	FUN = svymean
)

print(RMeDPC2_prog_social)
unname(sidra_7458[c(7,3)])

# PRÓPRIO ANO -----------------------
# Observação: no ano mais recente, não há diferença entre os deflatores
# do último ano e do próprio ano.

# rendimento habitual de todos os trabalhos e efetivo de outras fontes
# a preços médios do ano
desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	VD4019.Real1 = ifelse(
		is.na(VD4019) | is.na(V2005.Incluidas) | V2009 < 14,
		0, VD4019 * CO2
	),
	VD4048.Real1 = ifelse(
		is.na(VD4048) | is.na(V2005.Incluidas),
		0, VD4048 * CO2e
	)
)

# rendimento domiciliar per capita a preços médios do último ano
desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	VD5007.Real1 = ave(
		VD4019.Real1 + VD4048.Real1,
		ID_DOMICILIO,
		FUN = sum
	)
)

# rendimento domiciliar per capita a preços médios do último ano
desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	VD5008.Real1 = ifelse(
		is.na(V2005.Incluidas),
		0, VD5007.Real1 / V2001.Incluidos)
)

# 7438 - idêntica a 7526
sidra_7438 <- get_sidra(x = 7438, variable = 10769, period = "2023",
	geo = "State", geo.filter = 31, header = TRUE, format = 2)

limites_RDPC1 <- svyquantile(
	~VD5008.Real1,
	desenho_amostral,
	quantiles = c(0.05, seq(0.10, 0.90, by = 0.10), 0.95, 0.99)
)
quantis1 <- limites_RDPC1[[1]][, 1]

print(limites_RDPC1)
unname(sidra_7438[c(7,3)])

# 7521 - idêntica a 7526
sidra_7521 <- get_sidra(x = 7521, variable = 606, period = "2023",
	geo = "State", geo.filter = 31, header = TRUE, format = 2)
sidra_7521 <- transform(sidra_7521, Valor = Valor * 1000)

# classes simples de percentual (CSP)
desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	CSP.VD5008.Real1 = cut(
		VD5008.Real1,
		breaks = c(-Inf, quantis1, Inf),
		labels = rotulos_CSP,
		right = TRUE
	)
)

pop_CSP_RDPC1 <- svyby(
	~V2005.Incluidas,
	~CSP.VD5008.Real1,
	desenho_amostral,
	FUN = svytotal,
	na.rm = TRUE
)

print(pop_CSP_RDPC1)
unname(sidra_7521[c(7,3)])

# 7428 - idêntica a 7427
sidra_7428 <- get_sidra(x = 7428, variable = 10490, period = "2023",
	geo = "State", geo.filter = 31, header = TRUE, format = 2)
sidra_7428 <- transform(sidra_7428, Valor = Valor * 10^6)

massa_RDCP1 <- svyby(
	~VD5008.Real1,
	~CSP.VD5008.Real1,
	desenho_amostra
	FUN = , svytotal
)

print(massa_RDCP1)
unname(sidra_7428[c(7,3)])

# 7527 - valores consideravelmente próximos
sidra_7527 <- get_sidra(x = 7527, variable = 10826, period = "2023",
	geo = "State", geo.filter = 31, header = TRUE, format = 2)

distribuicao_simples_RDCP1 <- data.frame(
	Classes.Simples = rotulos_CSP,
	Distribuicao.Simples.RDCP1 = massa_RDCP1[[2]] * 100 / sum(massa_RDCP1[[2]])
)

# 7530 - valores consideravelmente próximos
sidra_7530 <- get_sidra(x = 7530, variable = 10826, period = "2023",
	geo = "State", geo.filter = 31, header = TRUE, format = 2)

distribuicao_acumulada_RDCP1 <- data.frame(
	Classes.Acumulada = rotulos_CAP,
	Distribuicao.Acumulada.RDCP1 = cumsum(distribuicao_simples_RDCP1[[2]])
)

# 7527 - valores consideravelmente próximos
sidra_7527 <- get_sidra(x = 7527, variable = 10826, period = "2023",
	geo = "State", geo.filter = 31, header = TRUE, format = 2)

distribuicao_simples_RDCP1 <- data.frame(
	Classes.Simples = rotulos_CSP,
	Distribuicao.Simples.RDCP1 = massa_RDCP1[[2]] * 100 / sum(massa_RDCP1[[2]])
)

print(distribuicao_simples_RDCP1)
unname(sidra_7527[c(7,3)])

# 7530 - valores consideravelmente próximos
sidra_7530 <- get_sidra(x = 7530, variable = 10826, period = "2023",
	geo = "State", geo.filter = 31, header = TRUE, format = 2)

distribuicao_acumulada_RDCP1 <- data.frame(
	Classes.Acumuladas = rotulos_CAP,
	Distribuicao.Acumulada.RDCP1 = cumsum(distribuicao_simples_RDCP1[[2]])
)
