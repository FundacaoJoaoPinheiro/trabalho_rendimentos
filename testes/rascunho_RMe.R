############### RASCUNHO ##################
# comparar valores estimados para MG na sessão do R com aqueles disponíveis 
# nas tabelas da plataforma SIDRA

pacotes <- c("sidrar", "PNADcIBGE", "survey", "convey")
lapply(pacotes, library, character.only = TRUE)
source("testes/utilitarios.R")
options(scipen = 999)

variaveis <- c("V2010", "VD3004", "V2007", "V1023", "V2005", "VD4019", "VD4020",
	"VD4002")

pnadc_ano = 2023
visita = 1
pnadc_dir = "Microdados"

if (file.exists("desenho_RMe.RDS")) {
	desenho_amostral <- readRDS("desenho_RMe.RDS")
} else {
	desenho_amostral <- gerar_DA(variaveis)
}

# Rendimento médio mensal das pessoas ocupadas ----------------------------
# 7535(7538), 7539(7542), 7545(7548), 7549(7552)

# Deflacionar variáveis de rendimento
desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	VD4019.Real1 = ifelse(is.na(VD4019), NA, VD4019 * CO1),
	VD4019.Real2 = ifelse(is.na(VD4019), NA, VD4019 * CO2),
	VD4020.Real1 = ifelse(is.na(VD4020), NA, VD4020 * CO1e),
	VD4020.Real2 = ifelse(is.na(VD4020), NA, VD4020 * CO2e)
)


# 7441 --> CO2, V2010 ---------------------------------------
 sidra_7441 <- get_sidra(x = 7441, variable = c(10774, 10776), period = "2023",
	geo = "State", geo.filter = list("State" = c(15,29,31,52)), format = 2)

RMe2_cor_raca <- svyby(
	~VD4019.Real2 + VD4020.Real2,
	~V2010 + UF,
	desenho_amostral,
	svymean,
	vartype = "cv",
	na.rm = TRUE
)

sidra_7441 <- data.frame(
	UF = sidra_7441[c(1:4, 9:12, 17:20, 25:28), 4],
	Cor.ou.Raca = sidra_7441[1:16, 7],
	Habitual = sidra_7441[c(1:4, 9:12, 17:20, 25:28), 3],
	Efetivo  = sidra_7441[c(5:8, 13:16, 21:24, 29:32), 3]
)

View(sidra_7441)
View(RMe2_cor_raca)

# 7442 --> CO2, V2009 ---------------------------------------
# resultados foram bons menos para o primeiro grupo de idade
 sidra_7442 <- get_sidra(x = 7442, variable = c(10774, 10776), period = "2023",
	geo = "State", geo.filter = list("State" = c(15,29,31,52)), format = 2)

desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	Grupos.de.Idade = cut(
		V2009,
		breaks = c(13, 17, 19, 24, 29, 39, 49, 59, Inf),
		labels = c(
			"14 a 17 anos",
			"18 e 19 anos",
			"20 a 24 anos",
			"25 a 29 anos",
			"30 a 39 anos",
			"40 a 49 anos",
			"50 a 59 anos",
			"60 anos ou mais"
		),
		right = TRUE
	)
)

RMe2_idade <- svyby(
	~VD4019.Real2 + VD4020.Real2,
	~Grupos.de.Idade + UF,
	desenho_amostral,
	FUN = svymean,
	vartype = "cv",
	na.rm = TRUE
)

sidra_7442 <- data.frame(
	UF = sidra_7442[c(1:10,21:30, 41:50, 61:70), 4],
	Grupo.de.Idade = sidra_7442[1:40, 7],
	Habitual = sidra_7442[c(1:10,21:30, 41:50, 61:70), 3],
	Efetivo  = sidra_7442[c(11:20, 31:40, 51:60, 71:80), 3]
)

View(sidra_7442)
View(RMe2_idade)

# 7443 --> CO2, VD3004 ---------------------------------------
 sidra_7443 <- get_sidra(x = 7443, variable = c(10774, 10776), period = "2023",
	geo = "State", geo.filter = list("State" = c(15,29,31,52)), format = 2)

sidra_7443 <- data.frame(
	UF = sidra_7443[c(1:8, 17:24, 33:40, 49:56), 4],
	Grupo.de.Idade = sidra_7443[1:32, 7],
	Habitual = sidra_7443[c(1:8, 17:24, 33:40, 49:56), 3],
	Efetivo  = sidra_7443[c(9:16, 25:32, 41:48, 57:64), 3]
)

RMe2_instrucao <- svyby(
	~VD4019.Real2 + VD4020.Real2,
	~VD3004 + UF,
	desenho_amostral,
	svymean,
	vartype = "cv",
	na.rm = TRUE
)

View(sidra_7443)
View(RMe2_instrucao)

# 7444 --> CO2, V2007 ---------------------------------------
 sidra_7444 <- get_sidra(x = 7444, variable = c(10774, 10776), period = "2023",
	geo = "State", geo.filter = list("State" = c(15,29,31,52)), format = 2)


sidra_7444 <- data.frame(
	UF = sidra_7444[c(4:6, 10:12, 16:18, 22:24), 4],
	Cor.ou.Raca = sidra_7444[1:12,7],
	Habitual = sidra_7444[c(1:3, 7:9, 13:15, 19:21), 3],
	Efetivo  = sidra_7444[c(4:6, 10:12, 16:18, 22:24), 3]
)

RMe2_sexo <- svyby(
	~VD4019.Real2 + VD4020.Real2,
	~V2007 + UF,
	desenho_amostral,
	svymean,
	vartype = "cv",
	na.rm = TRUE
)

View(sidra_7444)
View(RMe2_sexo)

# 7445 --> CO2, V1023 ---------------------------------------
 sidra_7445 <- get_sidra(x = 7445, variable = c(10774, 10776), period = "2023",
	geo = "State", geo.filter = list("State" = c(15,29,31,52)), format = 2)

RMe2_area <- svyby(
	~VD4019.Real2 + VD4020.Real2,
	~V1023 + UF,
	desenho_amostral,
	svymean,
	vartype = "cv",
	na.rm = TRUE
)

sidra_7445 <- data.frame(
	UF = sidra_7445[c(1:5, 11:15, 21:25, 31:35), 4],
	Area = sidra_7445[1:20, 7],
	Habitual = sidra_7445[c(1:5, 11:15, 21:25, 31:35), 3],
	Efetivo  = sidra_7445[c(6:10, 16:20, 26:30, 36:40), 3]
)

View(sidra_7445)
View(RMe2_area)

# 7446 --> CO2, V2005 ---------------------------------------
 sidra_7446 <- get_sidra(x = 7446, variable = c(10778, 10780), period = "2023",
	geo = "State", geo.filter = list("State" = c(15,29,31,52)), format = 2)

RMe2_responsavel <- svyby(
	~VD4019.Real2 + VD4020.Real2,
	~UF,
	subset(
		desenho_amostral,
		V2005 == "Pessoa responsável pelo domicílio"
	),
	svymean,
	vartype = "cv",
	na.rm = TRUE
)

sidra_7446 <- data.frame(
	UF = sidra_7446[c(1,3,5,7), 4],
	Habitual = sidra_7446[c(1,3,5,7), 3],
	Efetivo  = sidra_7446[c(2,4,6,8), 3]
)

print(sidra_7446)
print(RMe2_responsavel)

# 7453 --> CO1, VD4019 ---------------------------------------
 sidra_7453 <- get_sidra(x = 7453, variable = 10806, period = "2023",
	geo = "State", geo.filter = list("State" = c(15,29,31,52)), format = 2)

RMe2_gini <- svyby(
	~VD4019.Real1,
	~UF,
	desenho_amostral,
	FUN = svygini,
	na.rm = TRUE
)

unname(sidra_7453[c(4,3)])
print(RMe2_gini)

# 7535 --> CO1, VD4019 ---------------------------------------
 sidra_7535 <- get_sidra(x = 7535, variable = 10842, period = "2023",
	geo = "State", geo.filter = list("State" = c(15,29,31,52)), format = 2)

# classes simples de percentual (CSP)
rotulos_classes = c(
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

quantis1 <- svyby(
	~VD4019.Real1,
	~UF,
	desenho_amostral,
	quantiles = c(0.05, seq(0.10, 0.90, by = 0.10), 0.95, 0.99),
	FUN = svyquantile,
	na.rm = TRUE
)

quantis_UF1 <- split(quantis1[2:13], quantis1[[1]])

VD4019_real1_UF <- split(
	desenho_amostral$variables$VD4019.Real1,
	desenho_amostral$variables$UF
)

classes_VD4019_real1 <- Map(
	function(renda, breaks) {
		cut(
			renda,
			breaks = c(-Inf, unlist(breaks), Inf),
			labels = rotulos_classes,
			right = FALSE
		)
	},
	renda = VD4019_real1_UF,
	breaks = quantis_UF1
)

desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	CSP.VD4019.Real1 = unsplit(classes_VD4019_real1, UF)
)

RMe1_classe <- svyby(
	~VD4019.Real1,
	~CSP.VD4019.Real1 + UF,
	desenho_amostral,
	svymean,
	vartype = "cv",
	na.rm = TRUE
)

View(sidra_7535[c(4,7,3)])
View(RMe1_classe)

# 7538 --> CO1, VD4019 ---------------------------------------
 sidra_7538 <- get_sidra(x = 7538, variable = 10842, period = "2023",
	geo = "State", geo.filter = list("State" = c(15,29,31,52)), format = 2)

# classes acumuladas de percentual (CASP)
rotulos_acumul = c(paste0("Até P", c(5, 1:9 * 10, 95, 99)), "Total")

pop_classes_UF <- svyby(
	~!is.na(VD4019.Real1),
	~CSP.VD4019.Real1 + UF,
	desenho_amostral,
	svytotal,
	na.rm = TRUE
)
names(pop_classes_UF)[4] <- "Populacao"
pop_classes_UF <- split(pop_classes_UF$Populacao, pop_classes_UF$UF)

RMe1_classe_UF <- split(RMe1_classe$VD4019.Real1, RMe1_classe$UF)

RMe1_acumul_UF <- Map(
	function(renda, pop) {
		cumsum(renda * pop) / cumsum(pop)
	},
	renda = RMe1_classe_UF,
	pop   = pop_classes_UF
)

RMe1_acumul <- data.frame(
	UF = rep(unidades_federativas, each = 13),
	Classes.Acumuladas = rep(rotulos_acumul, 4),
	Renda.Media.Real1  = unlist(RMe1_acumul_UF)
)

View(sidra_7538[c(4, 7, 3)])
View(RMe1_acumul)

# 7539 --> CO2, VD4019 ---------------------------------------
sidra_7539 <- get_sidra(x = 7539, variable = 10842, period = "2023",
	geo = "State", geo.filter = list("State" = c(15,29,31,52)), format = 2)

# classes simples de percentual (CSP)
rotulos_classes = c(
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

quantis_RMe2 <- svyby(
	~VD4019.Real2,
	~UF,
	desenho_amostral,
	quantiles = c(0.05, seq(0.10, 0.90, by = 0.10), 0.95, 0.99),
	FUN = svyquantile,
	na.rm = TRUE
)
quantis_RMe2 <- split(quantis_RMe2[2:13], quantis_RMe2[[1]])

VD4019_real2_UF <- split(
	desenho_amostral$variables$VD4019.Real2,
	desenho_amostral$variables$UF
)

classes_VD4019_real2 <- Map(
	function(renda, breaks) {
		cut(
			renda,
			breaks = c(-Inf, unlist(breaks), Inf),
			labels = rotulos_classes,
			right = FALSE
		)
	},
	renda = VD4019_real2_UF,
	breaks = quantis_RMe2
)

desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	CSP.VD4019.Real2 = unsplit(classes_VD4019_real2, UF)
)

RMe2_classe <- svyby(
	~VD4019.Real2,
	~CSP.VD4019.Real2 + UF,
	desenho_amostral,
	svymean,
	vartype = "cv",
	na.rm = TRUE
)

# 7542 --> CO2, VD4019 ---------------------------------------
 sidra_7542 <- get_sidra(x = 7542, variable = 10842, period = "2023",
	geo = "State", geo.filter = list("State" = c(15,29,31,52)), format = 2)

# classes acumuladas de percentual (CASP)
rotulos_acumul = c(paste0("Até P", c(5, 1:9 * 10, 95, 99)), "Total")

pop_classes_UF <- svyby(
	~!is.na(VD4019.Real2),
	~CSP.VD4019.Real2 + UF,
	desenho_amostral,
	svytotal,
	na.rm = TRUE
)
names(pop_classes_UF)[4] <- "Populacao"
pop_classes_UF <- split(pop_classes_UF$Populacao, pop_classes_UF$UF)

RMe2_classe_UF <- split(RMe2_classe$VD4019.Real2, RMe2_classe$UF)
RMe2_classe_UF <- Map(
	function(renda, pop) {
		cumsum(renda * pop) / cumsum(pop)
	},
	renda = RMe2_classe_UF,
	pop   = pop_classes_UF
)

RMe2_acumul <- data.frame(
	UF = rep(unidades_federativas, each = 13),
	Classes.Acumuladas = rep(rotulos_acumul, 4),
	Renda.Media.Real2  = unlist(RMe2_classe_UF)
)

View(sidra_7542[c(4, 7, 3)])
View(RMe2_acumul)

# 7545 --> CO1, VD4020 ---------------------------------------

# 7548 --> CO1, VD4020 ---------------------------------------

# 7549 --> CO2, VD4020 ---------------------------------------

# 7552 --> CO2, VD4020 ---------------------------------------
