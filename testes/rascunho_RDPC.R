############### RASCUNHO ##################
# comparar valores estimados para MG na sessão do R com aqueles disponíveis 
# nas tabelas da plataforma SIDRA

pacotes <- c("sidrar", "PNADcIBGE", "survey", "convey")
lapply(pacotes, library, character.only = TRUE)
options(scipen = 999)
source("testes/utilitarios.R")

# variaveis: V2001, V2005, VD4019, VD4048, V5001A, V5002A, V5003A.
if (file.exists("desenho_RDPC.RDS")) {
	desenho <- readRDS("desenho_RDPC.RDS")
} else {
	desenho <- gerar_desenho(tabelas_RDPC1)
}
	
# 2) Rendimento Domiciliar Per Capita a preços médios do último/próprio ano
# 7427(7428), 7429, 7526(7438), 7458, 7529(7521), (7527), (7530), 7533(7531),
# 7534(7532), 7564(7561) --------------------------------------------------

# as 3 categorias abaixos são excluídas no cálculo da rendimento domiciliar
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
sidra_7526 <- get_sidra(
	x = 7526, variable = 10838, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)

limites_sup <- estimar_quantis(~VD5008.Real, desenho)

write.csv(limites_sup, "tab_7526.csv")

# 7529 - valores bem parecidos, diferença maior em P5 - P10
sidra_7529 <- get_sidra(
	x = 7529, variable = 606, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
sidra_7529 <- transform(sidra_7529, Valor = Valor * 1000)

# adicionar coluna com as classes simples por percentual (CSP)
desenho$variables <- transform(
	desenho$variables,
	Faixas.Simples = add_faixas_simples(VD5008.Real, UF, limites_sup)
)

pop_simples2022 <- svyby(
	~V2005.Rendimento,
	~Faixas.Simples + UF,
	desenho,
	FUN = svytotal,
	vartype = "cv",
	keep.names = FALSE,	
	na.rm = TRUE
)
pop_simples2022 <- pop_simples2022[c(2,1,3)]
colnames(pop_simples2022) <- c("UF", "Faixas.Simples", "Valor")

View(sidra_7529[c(4,7,3)])
View(pop_simples2022)

# 7564 - evidentemente, o mesmo de 7529
sidra_7564 <- get_sidra(
	x = 7564, variable = 606, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
sidra_7564 <- transform(sidra_7564, Valor = Valor * 1000)

pop_simples_UF2022 <- split(pop_simples2022$Valor, pop_simples2022$UF)

pop_acumuladas2 <- data.frame(
	UF = rep(unidades_federativas, each = 13),
	Classes.Acumuladas = rep(rotulos_acumuladas, times = 4),
	Populacao = ave(
		pop_simples2022$Valor,
		pop_simples2022$UF,
		FUN = cumsum
	)
)

View(pop_acumuladas2)
View(sidra_7564[c(4,7,3)])

# 7427 - valores parecidos, mas a maioria é diferente
sidra_7427 <- get_sidra(
	x = 7427, variable = 10495, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
sidra_7427 <- transform(sidra_7427, Valor = Valor * 10^6)

massa_rendimento <- svyby(
	~VD5008.Real,
	~Faixas.Simples + UF,
	desenho,
	FUN = svytotal,
	vartype = "cv",
	keep.names = FALSE,	
	na.rm = TRUE
)

massa_rendimento <- data.frame(
	Faixas.Simples = c(faixas_simples, paste0("cv.", faixas_simples)),
	Pará = c(massa_rendimento[1:13, 3], massa_rendimento[1:13, 4]),
	Bahia = c(massa_rendimento[1:13, 3], massa_rendimento[1:13, 4]),
	Minas.Gerais = c(massa_rendimento[27:39, 3], massa_rendimento[27:39, 4]),
	Goiás = c(massa_rendimento[40:52, 3], massa_rendimento[40:52, 4])
)

View(massa_rendimento)
View(sidra_7427[c(4,7,3)])

# 7533 - valores bem parecidos, maiores diferenças em P95 e P99
sidra_7533 <- get_sidra(
	x = 7533, variable = 10816, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)

rme_simples <- svyby(
	~VD5008.Real,
	~Faixas.Simples + UF,
	desenho,
	FUN = svymean,
	keep.names = FALSE,
	vartype = "cv",
	na.rm = TRUE
)

rme_simples <- data.frame(
	Faixas.Simples = c(faixas_simples, paste0("cv.", faixas_simples)),
	Pará = c(rme_simples[1:13, 3], rme_simples[1:13, 4]),
	Bahia = c(rme_simples[1:13, 3], rme_simples[1:13, 4]),
	Minas.Gerais = c(rme_simples[27:39, 3], rme_simples[27:39, 4]),
	Goiás = c(rme_simples[40:52, 3], rme_simples[40:52, 4])
)

View(sidra_7533[c(4,7,3)])
View(rme_simples)

# 7534 - valores bem parecidos
sidra_7534 <- get_sidra(
	x = 7534, variable = 10816, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
sidra_7534 <- reformatar_sidra_uf(sidra_7534)

rme_simples_UF2022 <- split(
	rme_simples$VD5008.Real,
	rme_simples$UF
)

rme_acumul <- Map(
	function(renda, pop) {
		cumsum(renda * pop) / cumsum(pop)
	},
	renda = as.list(rme_simples),
	pop   = pop_simples_UF2022
)
rme_acumul$Classes.Acumulada <- rotulos_acumuladas

View(rme_acumul[c(5,1:4)])
View(sidra_7534)

# 7458 - resultados bem distintos, principalmente para o Pará...
sidra_7458 <- get_sidra(
	x = 7458, variable = 10816, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)

rme_progsocial2022 <- svybys(
	~VD5008.Real,
	by = ~interaction(UF, V5001A) +
          interaction(UF, V5002A) +
          interaction(UF, V5003A),
	desenho,
	FUN = svymean,
	keep.names = FALSE,
	na.rm = TRUE
)

colnames(rme_progsocial2022[[1]])[1:2] <- c("UF.BPC", "Valor")
colnames(rme_progsocial2022[[2]])[1:2] <- c("UF.Bolsa.Familia", "Valor")
colnames(rme_progsocial2022[[3]])[1:2] <- c("UF.Outros.Programas", "Valor")

View(rme_progsocial2022)
View(sidra_7458[c(4,7,3)])

# PRÓPRIO ANO -----------------------
# Observação: no ano mais recente, não há diferença entre os deflatores
# do último ano e do próprio ano.

# 7438 - idêntica a 7526
sidra_7438 <- get_sidra(
	x = 7438, variable = 10769, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2

# 7521 - idêntica a 7526
sidra_7521 <- get_sidra(
	x = 7521, variable = 606, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
sidra_7521 <- transform(sidra_7521, Valor = Valor * 1000)

# 7428 - idêntica a 7427
sidra_7428 <- get_sidra(
	x = 7428, variable = 10490, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
sidra_7428 <- transform(sidra_7428, Valor = Valor * 10^6)

# 7527 - valores consideravelmente próximos
sidra_7527 <- get_sidra(
	x = 7527, variable = 10826, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)

# Como 2023 é o ano mais recente, não tem diferença entre as variáveis reais

massa_rendimento_UF = as.list(massa_rendimento[1:13, -1])

distribuicao_UF <- lapply(massa_rendimento_UF, function(x) x * 100/ sum(x))
distribuicao_UF$Faixas.Simples = faixas_simples

distribuicao <- distribuicao_UF[c(5, 1:4)]

distribuicao <- data.frame(
	Faixas.Simples = c(faixas_simples, paste0("cv.", faixas_simples)),
	Pará = c(distribuicao[1:13, 3], distribuicao[1:13, 4]),
	Bahia = c(distribuicao[1:13, 3], distribuicao[1:13, 4]),
	Minas.Gerais = c(distribuicao[27:39, 3], distribuicao[27:39, 4]),
	Goiás = c(distribuicao[40:52, 3], distribuicao[40:52, 4])
)

View(sidra_7527[c(4,7,3)])
View(distribuicao)

# 7530 - valores consideravelmente próximos
sidra_7530 <- get_sidra(
	x = 7530, variable = 10826, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)

distribuicao_acumulada_UF <- lapply(distribuicao_UF, cumsum)

distribuicao_acumulada <- data.frame(
	UF = rep(unidades_federativas, each = 13),
	Faixas.Simples = rep(faixas_simples, times = 4),
	Distribuicao.Simples.RDPC1 = unlist(distribuicao_acumulada_UF)
)

View(sidra_7530[c(4,7,3)])
View(distribuicao_acumulada)

# 7435 - valores próximos, iguais arredondando
sidra_7435 <- get_sidra(
	x = 7435, variable = 10681, period = "2023",
	geo = "State", geo.filter = list("State" = c(15, 29, 31, 52)),
	header = TRUE, format = 2
)
names(sidra_7435)

gini1 <- svyby(
	~VD5008.Real,
	~UF,
	desenho,
	FUN = svygini,
	keep.names = FALSE,	
	na.rm = TRUE
)

print(sidra_7435[c(4,3)])
print(gini1)
