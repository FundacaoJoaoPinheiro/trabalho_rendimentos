# Reproduz tabelas SIDRA para os dez estratos geográficos de Minas Gerais.
# Tabelas referentes à fontes de rendimento: 7426, 7429, 7437.

# ---------------------------------------------------------------------
# Preparar ambiente

pacotes <- c("PNADcIBGE", "survey")
#install.packages(setdiff(pacotes, rownames(installed.packages())))
lapply(pacotes, library, character.only = TRUE)

# carregar objetos e funções utilizados no script:
# gerar_desenho(); ad_rdpc(); deflacionar(); estimar_medias(); estimar_totais();
# `tabelas_fontes`; `estratos_geo`.
source("../utilitarios.R")

# ---------------------------------------------------------------------
# Criar colunas necessárias

desenho <- gerar_desenho(tabelas_fontes)

desenho$variables <- transform(
	desenho$variables,
	Outros.Rendimentos = rowSums(
		cbind(V5001A2, V5002A2, V5003A2, V5005A2, V5008A2),
		na.rm = TRUE
	)
)
desenho$variables <- transform(
	desenho$variables,
	Outros.Rendimentos = ifelse(
		Outros.Rendimentos == 0,
		NA, Outros.Rendimentos
	)
)

desenho$variables <- transform(
	desenho$variables,
	Recebe.Todas.Fontes  = ifelse(!is.na(VD4052), 1, 0),
	Recebe.Trabalho.Hab  = ifelse(!is.na(VD4019), 1, 0),
	Recebe.Trabalho.Efet = ifelse(!is.na(VD4020) & VD4020 > 0, 1, 0),
	Recebe.Outras.Fontes = ifelse(!is.na(VD4048), 1, 0),
	Recebe.Aposentadoria = ifelse(!is.na(V5004A2), 1, 0),
	Recebe.Arrendamento  = ifelse(!is.na(V5007A2), 1, 0),
	Recebe.Pensao.Alimen = ifelse(!is.na(V5006A2), 1, 0),
	Recebe.Outros.Rendim = ifelse(!is.na(Outros.Rendimentos), 1, 0)
)

desenho$variables <- ad_rdpc(      # Renda Domiciliar Per Capita (RDPC)
	desenho$variables,
	c("VD4019", "VD4048", "V5004A2", "Outros.Rendimentos")
)

cod_vars = c("VD4052", "VD4019", "VD4020", "VD4048", "V5004A2",
	"V5007A2", "V5006A2", "Outros.Rendimentos")

desenho$variables <- deflacionar(
	desenho$variables,
	vars = cod_vars[-1],
	ano.base = 1
)

# rendimento de trabalho é deflacionado com CO1 e de outras fontes é deflacionado
# com CO1e, por isso o rendimento de todas as fontes real é calculado assim:
desenho$variables <- transform(
	desenho$variables,
	VD4052.Real = rowSums(
		cbind(VD4019.Real, VD4048.Real),
		na.rm = TRUE
	)
)
desenho$variables <- transform(
	desenho$variables,
	VD4052.Real = ifelse(is.na(VD4019) & is.na(VD4048), NA, VD4052.Real)
)

# ---------------------------------------------------------------------
# Reproduzir tabelas

# 7426 - População residente com rendimento, por fonte de rendimento
pop_fontes <- estimar_totais(
	desenho,
	formula = ~
		Recebe.Todas.Fontes  +
		Recebe.Trabalho.Hab  +
		Recebe.Trabalho.Efet +
		Recebe.Outras.Fontes +
	 	Recebe.Aposentadoria +
		Recebe.Arrendamento  +
		Recebe.Pensao.Alimen +
		Recebe.Outros.Rendim
)

tab_7426 <- pop_fontes[, c(1, 2:9)]
cv_7426  <- pop_fontes[, c(1, 10:17)]

# 7429 - participação % de cada fonte no rendimento médio domiciliar per capita
part_rdpc <- svyby(
	~VD5008 + VD4019.DPC + VD4048.DPC + V5004A2.DPC + Outros.Rendimentos.DPC,
	by = ~Estrato.Geo,
	denominator = ~VD5008,    # rendimento total dom. per capita
	design = subset(desenho, V2005.Rendimento == 1),    # incluídos na renda dom.
	FUN = svyratio,
	vartype = "cv",
	keep.names = FALSE,
	drop.empty.groups = FALSE,
	na.rm = TRUE
)

tab_7429 <- part_rdpc[c(1, 2:6)]
cv_7429  <- part_rdpc[c(1, 7:11)]

# 7437 - RMe da pop. com rendimento, por fonte de rendimento,
# a preços médios do ano
rme_fontes <- lapply(
	cod_vars,
	function(var) {
		estimar_medias(
			subset(desenho, get(var) > 0),        # apenas pop. com rendimento
			as.formula(paste0("~", var, ".Real"))
		)
	}
)
rme_fontes <- Reduce(function(...) merge(..., sort = FALSE), rme_fontes)

tab_7437 <- rme_fontes[, c(1, 1:8 * 2)]
cv_7437  <- rme_fontes[, c(1, seq(3, 17, by = 2))]

# ---------------------------------------------------------------------
# Formatar tabelas geradas

for (obj in ls(pattern = "^(cv|tab)_7")) {
	df <- get(obj)
	df[[1]] <- estratos_geo
	assign(obj, df)
}

for (obj in ls(pattern = "^cv_7")) {
	df <- get(obj)
	df[, -1] <- round(df[, -1] * 100, 1)
	assign(obj, df)
}

tab_7426[, -1] <- round(tab_7426[, -1] / 1000)    # mil pessoas
tab_7429[, -1] <- round(tab_7429[, -1] * 100, 1)  # %
tab_7437[, -1] <- round(tab_7437[, -1], 2)        # R$

for (obj in ls(pattern = "_74(26|37)$")) {
	df <- get(obj)
	colnames(df) <- c("Estrato", fontes_rendimento)
	assign(obj, df)
}

colnames(tab_7429) <- c("Estrato", fontes_rendimento[c(1, 2, 4, 5, 8)])
colnames(cv_7429)  <- c("Estrato", fontes_rendimento[c(1, 2, 4, 5, 8)])

# ---------------------------------------------------------------------
# Salvar arquivos 

for (obj in ls(pattern = "^(cv|tab)_7")) {
	write.csv2(
		get(obj),
		paste0("saida/fontes/", obj, ".csv"),
		row.names = FALSE
	)
}
