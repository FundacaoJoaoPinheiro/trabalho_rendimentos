############### RASCUNHO ##################
# comparar valores estimados para MG na sessão do R com aqueles disponíveis 
# nas tabelas da plataforma SIDRA

pacotes <- c("sidrar", "PNADcIBGE", "survey", "convey")
lapply(pacotes, library, character.only = TRUE)
options(scipen = 999)
source("testes/utilitarios.R")

variaveis <- c("V2001", "V2005", "VD4019", "VD4048", "V5001A", "V5002A", "V5003A")

pnadc_ano = 2023
visita = 1
pnadc_dir = "Microdados"

if (file.exists("desenho_RDPC.RDS")) {
	desenho_amostral <- readRDS("desenho_RDPC.RDS")
} else {
	desenho_amostral <- gerar_DA(variaveis)
}
	
# 2) Rendimento Domiciliar Per Capita a preços médios do último/próprio ano
# 7427(7428), 7429, 7526(7438), 7458, 7529(7521), (7527), (7530), 7533(7531),
# 7534(7532), 7564(7561) --------------------------------------------------

# as 3 categorias abaixos são excluídas no cálculo da rendimento domiciliar
desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	V2005.Rendimento = ifelse(
		V2005 == "Pensionista" |
		V2005 == "Empregado(a) doméstico(a)" |
		V2005 == "Parente do(a) empregado(a) doméstico(a)",
		NA, 1
	)
)

# moradores por domicílio incluídos no cálculo do rendimento domiciliar
desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	V2001.Rendimento = ave(
		V2005.Rendimento,
		ID_DOMICILIO,
		FUN = function(x) sum(x, na.rm=T)
	)
)

# ÚLTIMO ANO -----------------------

# rendimento habitual de todos os trabalhos e efetivo de outras fontes
# a preços médios do próprio/último ano
# (obs: para o último ano, CO1 = CO2 e CO1e = CO2e)
desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	VD4019.Real1 = ifelse(is.na(VD4019), NA, VD4019 * CO1),
	VD4019.Real2 = ifelse(is.na(VD4019), NA, VD4019 * CO2),
	VD4048.Real1 = ifelse(is.na(VD4048), NA, VD4048 * CO1e),
	VD4048.Real2 = ifelse(is.na(VD4048), NA, VD4048 * CO2e)
)

# rendimento domiciliar a preços médios do último ano
desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	VD5007.Real2 = ave(
		V2005.Rendimento | ifelse(is.na(VD4019), 0, VD4019.Real2) +
		V2005.Rendimento | ifelse(is.na(VD4048), 0, VD4048.Real2),
		ID_DOMICILIO,
		FUN = sum
	)
)

# rendimento domiciliar per capita a preços médios do último ano
desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	VD5008.Real2 = ifelse(
		is.na(VD5007.Real2),
		NA, VD5007.Real2 / V2001.Rendimento
	)
)

# 7526 - pequenas diferenças nos últimos dois quantis
sidra_7526 <- get_sidra(
	x = 7526, variable = 10838, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)

quantis_RDPC2 <- svyby(
	~VD5008.Real2,
	~UF,
	desenho_amostral,
	quantiles = c(0.05, seq(0.10, 0.90, by = 0.10), 0.95, 0.99),
	FUN = svyquantile,
	na.rm = TRUE
)

View(quantis_RDPC2)
View(sidra_7526[c(4,7,3)])

quantis_RDPC2 <-  split(quantis_RDPC2[2:13], quantis_RDPC2$UF)

# 7529 - valores bem parecidos, diferença maior em P5 - P10
sidra_7529 <- get_sidra(
	x = 7529, variable = 606, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
sidra_7529 <- transform(sidra_7529, Valor = Valor * 1000)

# classes simples de percentual (CSP)
rotulos_classe = c(
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

RDPC2_UF <- split(
	desenho_amostral$variables$VD5008.Real2,
	desenho_amostral$variables$UF
)

classes_RDPC2 <- Map(
	function(renda, breaks) {
		cut(
			renda,
			breaks = c(-Inf, unlist(breaks), Inf),
			labels = rotulos_classes,
			right = FALSE
		)
	},
	renda = RDPC2_UF,
	breaks = quantis_RDPC2
)

desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	CSP.VD5008.Real2 = unsplit(classes_RDPC2, UF)
)

pop2_classe <- svyby(
	V2005.Rendimento,
	~CSP.VD5008.Real2 + UF,
	desenho_amostral,
	FUN = svytotal,
	na.rm = TRUE
)
pop2_classe <- pop2_classe[c(2,1,3)]
colnames(pop2_classe)[3] <- "Populacao"

View(sidra_7529[c(4,7,3)])

# 7564 - evidentemente, o mesmo de 7529
sidra_7564 <- get_sidra(
	x = 7564, variable = 606, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
sidra_7564 <- transform(sidra_7564, Valor = Valor * 1000)

# classes acumuladas de percentual (CASP)
rotulos_acumul = c(paste0("Até P", c(5, 1:9 * 10, 95, 99)), "Total")

pop2_classe_UF <- split(pop2_classe$Populacao, pop2_classe$UF)

pop2_acumul_UF <- lapply(pop2_classe_UF, cumsum)

pop2_acumul <- data.frame(
	UF = rep(unidades_federativas, each = 13),
	Classes.Acumuladas = rotulos_acumul,
	Populacao = unlist(pop2_acumul_UF)
)

View(pop2_acumul)
View(sidra_7564[c(4,7,3)])

# 7427 - valores parecidos, mas a maioria é diferente
sidra_7427 <- get_sidra(
	x = 7427, variable = 10495, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
sidra_7427 <- transform(sidra_7427, Valor = Valor * 10^6)

massa_RDPC2 <- svyby(
	~VD5008.Real2,
	~CSP.VD5008.Real2 + UF,
	desenho_amostral,
	FUN = svytotal
)

View(massa_RDPC2)
View(sidra_7427[c(4,7,3)])

# 7533 - valores bem parecidos, maiores diferenças em P95 e P99
sidra_7533 <- get_sidra(
	x = 7533, variable = 10816, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)

RMeDPC2_classe <- svyby(
	~VD5008.Real2,
	~CSP.VD5008.R,
	desenho_amostral,
	FUN = svymean
)
unname(sidra_7533[c(7,3)])

# 7534 - valores bem parecidos
sidra_7534 <- get_sidra(
	x = 7534, variable = 10816, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)

RMeDPC2_acumul <- data.frame(
	Classes.Acumuladas = rotulos_acumul,
	RMe.Dom.Per.Capita =
		cumsum(RMeDPC2_classe[[2]] * pop_RDPC2_classe[[2]]) / # Somatório (RMe x pop) /
			cumsum(pop_RDPC2_classe[[2]])                  # Somatório (pop)
)

print(RMeDPC2_acumul)
unname(sidra_7534[c(7,3)])

# 7458
sidra_7458 <- get_sidra(
	x = 7458, variable = 10816, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)

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
		is.na(VD4019) | V2005.Rendimento | V2009 < 14,
		0, VD4019 * CO2
	),
	VD4048.Real1 = ifelse(
		is.na(VD4048) | V2005.Rendimento,
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
		V2005.Rendimento,
		0, VD5007.Real1 / V2001.Rendimento)
)

# 7438 - idêntica a 7526
sidra_7438 <- get_sidra(
	x = 7438, variable = 10769, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)

limites_RDPC1 <- svyquantile(
	~VD5008.Real1,
	desenho_amostral,
	quantiles = c(0.05, seq(0.10, 0.90, by = 0.10), 0.95, 0.99)
)
quantis_RDPC1 <- limites_RDPC1[[1]][, 1]

print(limites_RDPC1)
unname(sidra_7438[c(7,3)])

# 7521 - idêntica a 7526
sidra_7521 <- get_sidra(
	x = 7521, variable = 606, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
sidra_7521 <- transform(sidra_7521, Valor = Valor * 1000)

# classes simples de percentual (CSP)
desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	CSP.VD5008.Real2 = cut(
		VD5008.Real1,
		breaks = c(-Inf, quantis_RDPC1, Inf),
		labels = rotulos_classe,
		right = TRUE
	)
)

pop_RDPC1_classe <- svyby(
	V2005.Rendimento,
	~CSP.VD5008.R,
	desenho_amostral,
	FUN = svytotal,
	na.rm = TRUE
)

print(pop_RDPC1_classe)
unname(sidra_7521[c(7,3)])

# 7428 - idêntica a 7427
sidra_7428 <- get_sidra(
	x = 7428, variable = 10490, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
sidra_7428 <- transform(sidra_7428, Valor = Valor * 10^6)

massa_RDPC1 <- svyby(
	~VD5008.Real1,
	~CSP.VD5008.R,
	desenho_amostral
	FUN = , svytotal
)

print(massa_RDPC1)
unname(sidra_7428[c(7,3)])

# 7527 - valores consideravelmente próximos
sidra_7527 <- get_sidra(
	x = 7527, variable = 10826, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)

distribuicao_simples_RDPC1 <- data.frame(
	CSP.VD5008.Real2 = rotulos_classe,
	Distribuicao.Simples.RDPC1 = massa_RDPC1[[2]] * 100 / sum(massa_RDPC1[[2]])
)

# 7530 - valores consideravelmente próximos
sidra_7530 <- get_sidra(
	x = 7530, variable = 10826, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)

distribuicao_acumulada_RDPC1 <- data.frame(
	Classes.Acumulada = rotulos_acumul,
	Distribuicao.Acumulada.RDPC1 = cumsum(distribuicao_simples_RDPC1[[2]])
)

# 7527 - valores consideravelmente próximos
sidra_7527 <- get_sidra(
	x = 7527, variable = 10826, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)

distribuicao_simples_RDPC1 <- data.frame(
	CSP.VD5008.Real2 = rotulos_classe,
	Distribuicao.Simples.RDPC1 = massa_RDPC1[[2]] * 100 / sum(massa_RDPC1[[2]])
)

print(distribuicao_simples_RDPC1)
unname(sidra_7527[c(7,3)])

# 7530 - valores consideravelmente próximos
sidra_7530 <- get_sidra(
	x = 7530, variable = 10826, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)

distribuicao_acumulada_RDPC1 <- data.frame(
	Classes.Acumuladas = rotulos_acumul,
	Distribuicao.Acumulada.RDPC1 = cumsum(distribuicao_simples_RDPC1[[2]])
)

# 7435
sidra_7435 <- get_sidra(
	
	x = 7435, variable = 10681, period = "2023",
	geo = "State", geo.filter = list("State" = c(15,29,list("State" = c(15, 29, 31, 52)),52)),


header = TRUE, format = 2
)
names(sidra_7435)

teste <- svyby(
	~VD5008.Real1,
	~UF,
	desenho_amostral,
	FUN = svygini
	na.rm = TRUE
)
