pacotes <- c("sidrar", "PNADcIBGE", "survey", "convey")
lapply(pacotes, library, character.only = TRUE)
source("utilitarios.R")
options(scipen = 999)

desenho <- gerar_desenho(c(tabelas_distribuicao, tabelas_RMe2))

# rascunho_distribuicao -------------------------------------------------------

# Deflacionar variáveis de rendimento
desenho$variables <- transform(
	desenho$variables,
	VD4019.Real1 = ifelse(is.na(VD4019) | V2009 <= 14, NA, VD4019 * CO1),
	VD4019.Real2 = ifelse(is.na(VD4019) | V2009 <= 14, NA, VD4019 * CO2),
	VD4020.Real1 = ifelse(is.na(VD4020) | V2009 <= 14, NA, VD4020 * CO1e),
	VD4020.Real2 = ifelse(is.na(VD4020) | V2009 <= 14, NA, VD4020 * CO2e)
)

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

quantis2 <- svyby(
	~VD4019.Real1,
	~Estrato.Geo,
	desenho,
	FUN = svyquantile,
	quantiles = c(0.05, seq(0.10, 0.90, by = 0.10), 0.95, 0.99),
	na.rm = TRUE,
	keep.names = FALSE
)

rendimento_EG1 <- split(
	desenho$variables$VD4019.Real1,
	desenho$variables$Estrato.Geo
)

quantis_EG1 <-  split(quantis2[2:13], quantis2[[1]])

classes_simples1 <- Map(
	function(renda, breaks) {
		cut(
			renda,
			breaks = c(-Inf, as.numeric(breaks), Inf),
			labels = rotulos_classe,
			right = FALSE
		)
	},
	renda = rendimento_EG1,
	breaks = quantis_EG1
)

# adicionar coluna com as classes simples por percentual (CSP)
desenho$variables <- transform(
	desenho$variables,
	CSP.VD4019.Real1 = unsplit(classes_simples1, Estrato.Geo)
)

massa_rendimento1 <- svyby(
	~VD4019.Real1,
	~CSP.VD4019.Real1 + Estrato.Geo,
	desenho,
	FUN = svytotal,
	na.rm = TRUE,
	keep.names = FALSE
)

massa_rendimento1_EG1 = split(
	massa_rendimento1$VD4019.Real1,
	massa_rendimento1$Estrato.Geo
)

distribuicao_EG1 <- lapply(massa_rendimento1_EG1, function(x) x * 100/ sum(x))

distribuicao1 <- data.frame(
	Estrato.Geo = rep(estratos_geo, each = 13),
	Classes.Simples = rep(rotulos_classe, times = 10),
	Distribuicao.Simples.RDPC1 = unlist(distribuicao_EG1)
)

distribuicao_acumulada_EG1 <- lapply(distribuicao_EG1, cumsum)

distribuicao_acumulada1 <- data.frame(
	Estrato.Geo = rep(estratos_geo, each = 13),
	Classes.Acumuladas = rep(rotulos_cap, times = 10),
	Distribuicao.Simples.RDPC1 = unlist(distribuicao_acumulada_EG1)
)

# rascunho_RMe -------------------------------------------------------

# Deflacionar variáveis de rendimento
desenho$variables <- transform(
	desenho$variables,
	VD4019.Real1 = ifelse(is.na(VD4019), NA, VD4019 * CO1),
	VD4019.Real2 = ifelse(is.na(VD4019), NA, VD4019 * CO2),
	VD4020.Real1 = ifelse(is.na(VD4020), NA, VD4020 * CO1e),
	VD4020.Real2 = ifelse(is.na(VD4020), NA, VD4020 * CO2e)
)


# 7441 --> CO2, V2010 ---------------------------------------

RMe2_cor_raca <- svyby(
	~VD4019.Real2 + VD4020.Real2,
	~V2010 + Estrato.Geo,
	subset(desenho, V2009 >= 14 & (VD4019 > 0 | VD4020 > 0)),
	svymean,
	vartype = "cv",
	keep.names = FALSE,
	drop.empty.groups = FALSE,
	na.rm = TRUE
)

colnames(RMe2_cor_raca)[3:6] <- c("Habitual", "Efetiva", "cv.Habitual",
	"cv.Efetiva")

tab_7441 <- reshape(
	RMe2_cor_raca[1:4],
	idvar = "Estrato.Geo",
	timevar = "V2010",
	direction = "wide"
)
tab_7441 <- tab_7441[c(1, seq(2, 12, by = 2), seq(3, 13, by = 2))]
tab_7441[, 1] <- estratos_geo

cv_7441 <- reshape(
	RMe2_cor_raca[c(1, 2, 5, 6)],
	idvar = "Estrato.Geo",
	timevar = "V2010",
	direction = "wide"
)
cv_7441 <- cv_7441[c(1, seq(2, 12, by = 2), seq(3, 13, by = 2))]
cv_7441[, -1] <- cv_7441[, -1] * 100

write.csv2(tab_7441, "tabelas/tab_7441.csv")
write.csv2(cv_7441, "tabelas/cv_7441.csv")

# 7442 --> CO2, V2009 ---------------------------------------

desenho$variables <- transform(
	desenho$variables,
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
	~Grupos.de.Idade + Estrato.Geo,
	desenho,
	FUN = svymean,
	vartype = "cv",
	keep.names = FALSE,
	drop.empty.groups = FALSE,
	na.rm = TRUE
)

colnames(RMe2_idade)[3:6] <- c("Habitual", "Efetiva", "cv.Habitual",
	"cv.Efetiva")

tab_7442 <- reshape(
	RMe2_idade[1:4],
	idvar = "Estrato.Geo",
	timevar = "Grupos.de.Idade",
	direction = "wide"
)
tab_7442 <- tab_7442[c(1, seq(2, 12, by = 2), seq(3, 13, by = 2))]
tab_7442[, 1] <- estratos_geo

cv_7442 <- reshape(
	RMe2_idade[c(1, 2, 5, 6)],
	idvar = "Estrato.Geo",
	timevar = "Grupos.de.Idade",
	direction = "wide"
)
cv_7442 <- cv_7442[c(1, seq(2, 12, by = 2), seq(3, 13, by = 2))]
cv_7442[, -1] <- cv_7442[, -1] * 100

write.csv2(tab_7442, "tabelas/tab_7442.csv")
write.csv2(cv_7442, "tabelas/cv_7442.csv")

# 7443 --> CO2, VD3004 ---------------------------------------

RMe2_instrucao <- svyby(
	~VD4019.Real2 + VD4020.Real2,
	~VD3004 + Estrato.Geo,
	desenho,
	svymean,
	vartype = "cv",
	keep.names = FALSE,
	drop.empty.groups = FALSE,
	na.rm = TRUE
)

colnames(RMe2_instrucao)[3:6] <- c("Habitual", "Efetiva", "cv.Habitual",
	"cv.Efetiva")

tab_7443 <- reshape(
	RMe2_instrucao[1:4],
	idvar = "Estrato.Geo",
	timevar = "VD3004",
	direction = "wide"
)
tab_7443 <- tab_7443[c(1, seq(2, 12, by = 2), seq(3, 13, by = 2))]
tab_7443[, 1] <- estratos_geo

cv_7443 <- reshape(
	RMe2_instrucao[c(1, 2, 5, 6)],
	idvar = "Estrato.Geo",
	timevar = "VD3004",
	direction = "wide"
)
cv_7443 <- cv_7443[c(1, seq(2, 12, by = 2), seq(3, 13, by = 2))]
cv_7443[, -1] <- cv_7443[, -1] * 100

write.csv2(tab_7443, "tabelas/tab_7443.csv")
write.csv2(cv_7443, "tabelas/cv_7443.csv")

# 7444 --> CO2, V2007 ---------------------------------------

RMe2_sexo <- svyby(
	~VD4019.Real2 + VD4020.Real2,
	~V2007 + Estrato.Geo,
	desenho,
	svymean,
	vartype = "cv",
	na.rm = TRUE,
	keep.names = FALSE
)

colnames(RMe2_sexo)[3:6] <- c("Habitual", "Efetiva", "cv.Habitual",
	"cv.Efetiva")

tab_7444 <- reshape(
	RMe2_sexo[1:4],
	idvar = "Estrato.Geo",
	timevar = "V2007",
	direction = "wide"
)
tab_7444[, 1] <- estratos_geo

cv_7444 <- reshape(
	RMe2_sexo[c(1, 2, 5, 6)],
	idvar = "Estrato.Geo",
	timevar = "V2007",
	direction = "wide"
)
cv_7444[, -1] <- cv_7444[, -1] * 100

write.csv2(tab_7444, "tabelas/tab_7444.csv")
write.csv2(cv_7444, "tabelas/cv_7444.csv")

# 7445 --> CO2, V1023 ---------------------------------------

RMe2_area <- svyby(
	~VD4019.Real2 + VD4020.Real2,
	~V1023 + Estrato.Geo,
	desenho,
	svymean,
	vartype = "cv",
	na.rm = TRUE,
	keep.names = FALSE
)

colnames(RMe2_area)[3:6] <- c("Habitual", "Efetiva", "cv.Habitual",
	"cv.Efetiva")

tab_7445 <- reshape(
	RMe2_area[1:4],
	idvar = "Estrato.Geo",
	timevar = "V1023",
	direction = "wide"
)
tab_7445 <- tab_7445[c(1, seq(2, 9, by = 2), seq(3, 9, by = 2))]
tab_7445[, 1] <- estratos_geo

cv_7445 <- reshape(
	RMe2_area[c(1, 2, 5, 6)],
	idvar = "Estrato.Geo",
	timevar = "V1023",
	direction = "wide"
)
cv_7445 <- cv_7445[c(1, seq(2, 9, by = 2), seq(3, 9, by = 2))]
cv_7445[, -1] <- cv_7445[, -1] * 100

write.csv2(tab_7445, "tabelas/tab_7445.csv")
write.csv2(cv_7445, "tabelas/cv_7445.csv")

# 7446

RMe2_responsavel <- svyby(
	~VD4019.Real2 + VD4020.Real2,
	~Estrato.Geo,
	subset(
		desenho,
		V2005 == "Pessoa responsável pelo domicílio"
	),
	svymean,
	vartype = "cv",
	na.rm = TRUE,
	keep.names = FALSE
)

tab_7446 <- RMe2_responsavel
tab_7446[, 1] <- estratos_geo
tab_7446[, -1] <- tab_7446[, -1:-3] * 100

write.csv2(tab_7446, "tabelas/tab_7446.csv")

# 7453 --> CO1, VD4019 ---------------------------------------

RMe2_gini <- svyby(
	~VD4019.Real1,
	~Estrato.Geo,
	desenho,
	FUN = svygini,
	na.rm = TRUE,
	keep.names = FALSE
)

tab_7453 <- RMe2_gini
tab_7453[, 1] <- estratos_geo
tab_7453[, -1] <- tab_7453[, -1:-3] * 100

write.csv2(tab_7453, "tabelas/tab_7453.csv")

# 7534 --> CO1, VD4019 ---------------------------------------

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
	~Estrato.Geo,
	desenho,
	quantiles = c(0.05, seq(0.10, 0.90, by = 0.10), 0.95, 0.99),
	FUN = svyquantile,
	na.rm = TRUE,
	keep.names = FALSE
)

quantis_EG1 <- split(quantis1[2:13], quantis1[[1]])

VD4019_real1_UF <- split(
	desenho$variables$VD4019.Real1,
	desenho$variables$Estrato.Geo
)

classes_VD4019_real1 <- Map(
	function(renda, breaks) {
		cut(
			renda,
			breaks = c(-Inf, as.numeric(breaks), Inf),
			labels = rotulos_classes,
			right = FALSE
		)
	},
	renda = VD4019_real1_UF,
	breaks = quantis_EG1
)

desenho$variables <- transform(
	desenho$variables,
	CSP.VD4019.Real1 = unsplit(classes_VD4019_real1, Estrato.Geo)
)

RMe1_classe <- svyby(
	~VD4019.Real1,
	~CSP.VD4019.Real1 + Estrato.Geo,
	desenho,
	svymean,
	vartype = "cv",
	na.rm = TRUE,
	keep.names = FALSE
)

tab_7534 <- reshape_wide(RMe1_classe[c(1:2, 3)])
tab_7534[, 1] <- estratos_geo
cv_7534  <- reshape_wide(RMe1_classe[c(1:2, 4)])
cv_7534[, -1] <- cv_7534[, -1] * 100

write.csv(tab_7534, "tabelas/tab_7534.csv")
write.csv(cv_7534, "tabelas/cv_7534.csv")

# 7538 --> CO1, VD4019 ---------------------------------------

# classes acumuladas de percentual (CASP)
rotulos_acumul = c(paste0("Até P", c(5, 1:9 * 10, 95, 99)), "Total")

pop_classes_UF <- svyby(
	~!is.na(VD4019.Real1),
	~CSP.VD4019.Real1 + Estrato.Geo,
	desenho,
	svytotal,
	na.rm = TRUE,
	keep.names = FALSE
)
names(pop_classes_UF)[4] <- "Populacao"
pop_classes_UF <- split(pop_classes_UF$Populacao, pop_classes_UF$Estrato.Geo)

RMe1_classe_UF <- split(RMe1_classe$VD4019.Real1, RMe1_classe$Estrato.Geo)

RMe1_acumul_UF <- Map(
	function(renda, pop) {
		cumsum(renda * pop) / cumsum(pop)
	},
	renda = RMe1_classe_UF,
	pop   = pop_classes_UF
)

tab_7538 <- data.frame(
	Classes.Acumuladas = factor(rep(rotulos_acumul, 10)),
	Estrato.Geo = rep(estratos_geo, each = 13),
	Renda.Media.Real1  = unlist(RMe1_acumul_UF)
)
tab_7538 <- reshape_wide(tab_7538)

write.csv(tab_7538, "tabelas/tab_7538.csv")

# 7539 --> CO2, VD4019 ---------------------------------------

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
	~Estrato.Geo,
	desenho,
	quantiles = c(0.05, seq(0.10, 0.90, by = 0.10), 0.95, 0.99),
	FUN = svyquantile,
	na.rm = TRUE,
	keep.names = FALSE
)
quantis_RMe2 <- split(quantis_RMe2[2:13], quantis_RMe2[[1]])

VD4019_real2_UF <- split(
	desenho$variables$VD4019.Real2,
	desenho$variables$Estrato.Geo
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

desenho$variables <- transform(
	desenho$variables,
	CSP.VD4019.Real2 = unsplit(classes_VD4019_real2, Estrato.Geo)
)

RMe2_classe <- svyby(
	~VD4019.Real2,
	~CSP.VD4019.Real2 + Estrato.Geo,
	desenho,
	svymean,
	vartype = "cv",
	na.rm = TRUE,
	keep.names = FALSE
)

tab_7539 <- reshape_wide(RMe2_classe[c(1:2, 3)])
tab_7539[, 1] <- estratos_geo
cv_7539  <- reshape_wide(RMe2_classe[c(1:2, 4)])
cv_7539[, -1] <- cv_7539[, -1] * 100

write.csv2(tab_7539, "tabelas/tab_7539.csv")
write.csv2(tab_7539, "tabelas/tab_7539.csv")

# rascunho_RDPC ------------------------------------------------------

desenho$variables <- transform(
	desenho$variables,
	V2005.Rendimento = ifelse(
		V2005 == "Pensionista" |
		V2005 == "Empregado(a) doméstico(a)" |
		V2005 == "Parente do(a) empregado(a) doméstico(a)",
		NA, 1
	)
)

# moradores por domicílio incluídos no cálculo do rendimento domiciliar
desenho$variables <- transform(
	desenho$variables,
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
desenho$variables <- transform(
	desenho$variables,
	VD4019.Real = ifelse(is.na(VD4019), NA, VD4019 * CO1),
	VD4048.Real = ifelse(is.na(VD4048), NA, VD4048 * CO1e)
)

# rendimento de todas as fontes
desenho$variables <- transform(
	desenho$variables,
	VD4052.Real =
		ifelse(is.na(VD4019), 0, VD4019.Real) +
		ifelse(is.na(VD4048), 0, VD4048.Real)
)

# rendimento domiciliar a preços médios do último ano
desenho$variables <- transform(
	desenho$variables,
	VD5007.Real = ave(VD4052.Real, ID_DOMICILIO, FUN = sum)
)

# rendimento domiciliar per capita a preços médios do último ano
desenho$variables <- transform(
	desenho$variables,
	VD5008.Real = ifelse(
		is.na(V2005.Rendimento),
		NA, VD5007.Real / V2001.Rendimento
	)
)

# 7526 - pequenas diferenças nos últimos dois limites_sup

limites_sup <- estimar_quantis(desenho, ~VD5008.Real)

tab_7526 <- limites_sup[c(1, 2:13)]
tab_7526[, 1] <- estratos_geo
cv_7526  <- limites_sup[c(1, 14:25)]
cv_7526[, -1] <- cv_7526[, -1] * 100

write.csv(tab_7526, "tab_7526.csv")
write.csv(cv_7526, "cv_7526.csv")

# adicionar coluna com as classes simples por percentual (CSP)
desenho$variables <- transform(
	desenho$variables,
	Faixas.Simples = add_faixas_simples(
		VD5008.Real, Estrato.Geo, limites_sup[1:13]
	)
)

pop_simples2022 <- svyby(
	~V2005.Rendimento,
	~Faixas.Simples + Estrato.Geo,
	desenho,
	FUN = svytotal,
	vartype = "cv",
	keep.names = FALSE,	
	na.rm = TRUE
)
colnames(pop_simples2022) <- c("Faixas.Simples", "Estrato.Geo", "Populacao",
	"cv.Populacao")

tab_7526 <- reshape_wide(pop_simples2022[c(1:2, 3)])
tab_7526[, 1] <- estratos_geo
cv_7526  <- reshape_wide(pop_simples2022[c(1:2, 4)])
cv_7526[, -1] <- cv_7526[, -1] * 100

write.csv2(tab_7526, "tabelas/tab_7526.csv")
write.csv2(cv_7526, "tabelas/cv_7526.csv")

# 7533

rme_simples <- svyby(
	~VD5008.Real,
	~Faixas.Simples + Estrato.Geo,
	desenho,
	FUN = svymean,
	keep.names = FALSE,
	vartype = "cv",
	na.rm = TRUE
)

tab_7533 <- reshape_wide(rme_simples[c(1:2, 3)])
tab_7533[, 1] <- estratos_geo
cv_7533  <- reshape_wide(rme_simples[c(1:2, 4)])
cv_7533[, -1] <- cv_7533[, -1] * 100

write.csv2(tab_7533, "tabelas/tab_7533.csv")
write.csv2(cv_7533, "tabelas/cv_7533.csv")
