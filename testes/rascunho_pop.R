############### RASCUNHO ##################
# comparar valores estimados para MG na sessão do R com aqueles disponíveis 
# nas tabelas da plataforma SIDRA

pacotes <- c("sidrar", "PNADcIBGE", "survey", "microbenchmark")
lapply(pacotes, library, character.only = TRUE
)
source("testes/utilitarios.R")
options(scipen = 999)

variaveis <- c("V2009", "VD4002", "VD4019", "VD4020", "VD4048", "V1023",
"V2010", "VD3004", "V2007", "V2005")

if (file.exists("desenho_pop.RDS")) {
	desenho_amostral <- readRDS("desenho_pop.RDS")
} else {
	desenho_amostral <- gerar_DA(variaveis)
}

# Pessoas ocupadas por categorias --------------------------------
all(
	is.na(desenho_amostral$variables$VD4019.Real1) ==
	is.na(desenho_amostral$variables$VD4020.Real1)
)

desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	Ocupadas.com.Rendimento = ifelse(
		V2009 >= 14 &
		VD4002 == "Pessoas ocupadas" &
		(!is.na(VD4019) | !is.na(VD4020)),
		1, NA
	)
)

# 7431 --> V2010, cor e raça;
sidra_7431 <- get_sidra(
	x = 7431, variable = 10765, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7431)

pop_cor <- svyby(
	~Ocupadas.com.Rendimento,
	~V2010 + UF,
	desenho_amostral,
	FUN = svytotal,
	vartype = "cv",
	na.rm = TRUE
)

View(pop_cor)
View(sidra_7431[c(4,7,3)])

# 7432 --> grupos de idade;
sidra_7432 <- get_sidra(
	x = 7432, variable = 10765, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7432)

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

pop_idade <- svyby(
	~Ocupadas.com.Rendimento,
	~Grupos.de.Idade + UF,
	desenho_amostral,
	FUN = svytotal,
	vartype = "cv",
	na.rm = TRUE
)

View(sidra_7432[c(4,7,3)])
View(teste)

# 7433 --> VD3004, instrução;
sidra_7433 <- get_sidra(
	x = 7433, variable = 10765, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7433)

pop_instrucao <- svyby(
	~Ocupadas.com.Rendimento,
	~VD3004 + UF,
	desenho_amostral,
	FUN = svytotal,
	vartype = "cv",
	na.rm = TRUE
)

View(sidra_7433[c(4,7,3)])
View(pop_instrucao)

# 7434 --> V2007, sexo;
sidra_7434 <- get_sidra(
	x = 7434, variable = 10765, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7434)

pop_sexo <- svyby(
	~Ocupadas.com.Rendimento,
	~V2007 + UF,
	desenho_amostral,
	FUN = svytotal,
	vartype = "cv",
	na.rm = TRUE
)

View(sidra_7434[c(4,7,3)])
View(pop_sexo)

# 7439 --> V2005, responsáveis;
sidra_7439 <- get_sidra(
	x = 7439, variable = 10770, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7434)

pop_responsaveis <- svyby(
	~Ocupadas.com.Rendimento,
	~UF,
	subset(
		desenho_amostral,
		V2005 == "Pessoa responsável pelo domicílio"
	),
	FUN = svytotal,
	vartype = "cv",
	na.rm = TRUE
)

print(sidra_7439[c(4,3)])
print(pop_responsaveis)

# 7440 --> V1023, área;
sidra_7440 <- get_sidra(
	x = 7440, variable = 10765, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7434)

pop_area <- svyby(
	~Ocupadas.com.Rendimento,
	~V1023 + UF,
	desenho_amostral,
	FUN = svytotal,
	vartype = "cv",
	na.rm = TRUE
)

View(sidra_7440[c(4,7,3)])
View(pop_area)

# 7436 --> populacao residente
sidra_7436 <- get_sidra(
	x = 7436, variable = 606, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7436)

pop_total <- svytotal(~UF, desenho_amostral)

print(sidra_7436[c(4,3)])
print(pop_total)

# Deflacionar variáveis de rendimento
desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	VD4019.Real1 = ifelse(is.na(VD4019), NA, VD4019 * CO1),
	VD4019.Real2 = ifelse(is.na(VD4019), NA, VD4019 * CO2),
	VD4020.Real1 = ifelse(is.na(VD4020), NA, VD4020 * CO1e),
	VD4020.Real2 = ifelse(is.na(VD4020), NA, VD4020 * CO2e),
	VD4048.Real1 = ifelse(is.na(VD4048), NA, VD4048 * CO1e),
	VD4048.Real2 = ifelse(is.na(VD4048), NA, VD4048 * CO2e),
	# rendimento efetivo de todas as fontes deflacionado
	VD4052.Real1 = ifelse(
		is.na(VD4020) | is.na(VD4048),
		NA, (VD4020 + VD4048) * CO1e
	),
	VD4052.Real2 = ifelse(
		is.na(VD4020) | is.na(VD4048),
		NA, (VD4020 + VD4048) * CO2e
	)
)

# 7536 --> VD4019:CO1; limites superiores; resultados bem parecidos
sidra_7536 <- get_sidra(
        x = 7536, variable = 10841, period = "2023",
        geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
        header = TRUE, format = 2
)
names(sidra_7536)

quantis_habitual1 <- svyby(
	~VD4019.Real1,
	~UF,
	desenho_amostral,
	quantiles = c(0.05, seq(0.10, 0.90, by = 0.10), 0.95, 0.99),
	FUN = svyquantile,
	na.rm = TRUE
)

View(sidra_7536[c(4,7,3)])
View(quantis_habitual1)

# 7537 --> VD4019:CO1; classes simples; alguns valores parecidos, outros mais
# distantes... em MG, as vaixas 50-60 e 60-70
sidra_7537 <- get_sidra(
        x = 7537, variable = 10844, period = "2023",
        geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
        header = TRUE, format = 2
)
names(sidra_7537)

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

quantis_UF1 <- split(quantis_habitual1[2:13], quantis_habitual1[[1]])

habitual_UF1 <- split(
	desenho_amostral$variables$VD4019.Real1,
	desenho_amostral$variables$UF
)

classes_habitual <- Map(
	function(renda, breaks) {
		cut(
			renda,
			breaks = c(-Inf, as.numeric(breaks), Inf),
			labels = rotulos_classes,
			right = FALSE,
			include.lowest = TRUE
		)
	},
	renda = habitual_UF1,
	breaks = quantis_UF1
)

desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	CSP.VD4019.Real1 = unsplit(classes_habitual, UF)
)

pop_habitual1 <- svyby(
	~Ocupadas.com.Rendimento,
	~CSP.VD4019.Real1 + UF,
	desenho_amostral,
	svytotal,
	vartype = "cv",
	na.rm = TRUE
)

View(sidra_7537[c(4,7,3)])
View(pop_habitual1)

# 7540 --> 7546; VD4019:CO2; limites simples

# 7541 --> 7537; VD4019:CO2; classes simples
sidra_7541 <- get_sidra(
        x = 7541, variable = 10844, period = "2023",
        geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
        header = TRUE, format = 2
)
names(sidra_7541)

# 7546 --> VD4020:CO1e; limites simples; resultados estão próximos
sidra_7546 <- get_sidra(
        x = 7546, variable = 10841, period = "2023",
        geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
        header = TRUE, format = 2
)
names(sidra_7546)

quantis_efetiva1 <- svyby(
	~VD4020.Real1,
	~UF,
	desenho_amostral,
	quantiles = c(0.05, seq(0.10, 0.90, by = 0.10), 0.95, 0.99),
	FUN = svyquantile,
	na.rm = TRUE
)

View(sidra_7446[c(4,7,3)])
View(quantis_efetiva1)

# 7547 --> VD4020:CO1e; classes simples; resultados bem diferentes
sidra_7547 <- get_sidra(
        x = 7547, variable = 10844, period = "2023",
        geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
        header = TRUE, format = 2
)
names(sidra_7547)

quantis_efetiva_UF1 <- split(quantis_efetiva1[2:13], quantis_efetiva1[[1]])

efetiva_UF1 <- split(
	desenho_amostral$variables$VD4020.Real1,
	desenho_amostral$variables$UF
)

classes_efetiva <- Map(
	function(renda, breaks) {
		cut(
			renda,
			breaks = c(-Inf, as.numeric(breaks), Inf),
			labels = rotulos_classes,
		)
	},
	renda = efetiva_UF1,
	breaks = quantis_efetiva_UF1
)

desenho_amostral$variables <- transform(
	desenho_amostral$variables,
	CSP.VD4020.Real1 = unsplit(classes_efetiva, UF)
)

pop_efetiva1 <- svyby(
	~Ocupadas.com.Rendimento,
	~CSP.VD4020.Real1 + UF,
	desenho_amostral,
	svytotal,
	vartype = "cv",
	na.rm = TRUE
)

View(sidra_7547[c(4,7,3)])
View(pop_efetiva1)

# 7550 --> 7546; VD4020:CO2e; limites simples

# 7551 --> 7547; VD4020:CO2e; classes simples

# 7559 --> VD4020:CO1e; classes acumuladas; resultados razoáveis
sidra_7559 <- get_sidra(
        x = 7559, variable = 10844, period = "2023",
        geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
        header = TRUE, format = 2
)
names(sidra_7559)

# classes acumuladas de percentual (CASP)
rotulos_acumuladas = c(paste0("Até P", c(5, 1:9 * 10, 95, 99)), "Total")

pop_efetiva_UF1 <- split(pop_efetiva1$Ocupadas.com.Rendimento, pop_efetiva1$UF)

pop_acumulada_UF1 <- lapply(pop_efetiva_UF1, cumsum)

pop_acumulada1 <- data.frame(
	UF = rep(unidades_federativas, each = 13),
	Classes.Acumuladas = rep(rotulos_acumuladas, 4),
	Renda.Media.Real1  = unlist(pop_acumulada_UF1)
)

View(sidra_7559[c(4,7,3)])
View(pop_acumulada1)

# 7560 --> 7559; VD4020:CO2e; classes acumuladas

# 7562 --> VD4019:CO1; classes acumuladas

# 7563 --> 7559; VD4019:CO2; classes acumuladas
