# Reproduzir tabelas SIDRA para os dez estratos geográficos de Minas Gerais.
# Tabelas referentes à população ocupada com rendimento: 7431, 7432, 7433,
# 7434, 7436, 7439, 7440, 7537, 7541, 7546, 7547, 7559, 7560, 7562, 7563
# ---------------------------------------------------------------------

# Preparar ambiente
pacotes <- c("PNADcIBGE", "survey")
install.packages(setdiff(pacotes, rownames(installed.packages())))
lapply(pacotes, library, character.only = TRUE)
source("utilitarios.R")     # objetos e funções utilizados abaixo

pnadc_ano = 2023
pnadc_dir = "Microdados"
desenho <- gerar_desenho(tabelas_ocupada)

# ---------------------------------------------------------------------

# Criar colunas necessárias

desenho$variables <- transform(
	desenho$variables,
	Ocupada.com.Rendimento = ifelse(
		VD4002 == "Pessoas ocupadas" & V2009 >= 14 & VD4019 > 0,
		1, NA
	)
)

desenho$variables <- transform(
	desenho$variables,
	Grupos.de.Idade = add_grupos_idade(V2009)
)

# ---------------------------------------------------------------------

# Tabela 7431 - população ocupada por cor/raça

ocupada_cor <- estimar_totais(desenho, ~Ocupada.com.Rendimento, ~V2010)
tab_7431 <- reshape_wide(ocupada_cor[-4])
cv_7431 <- reshape_wide(ocupada_cor[-3])

write.csv2(tab_7431, "saida/tab_7431.csv")
write.csv2(cv_7431, "saida/cv_7431.csv")

# Tabela 7432 - população ocupada por grupos de idade

ocupada_idade <- estimar_totais(desenho, ~Ocupada.com.Rendimento, ~Grupos.de.Idade)
tab_7432 <- reshape_wide(ocupada_idade[-4])
cv_7432 <- reshape_wide(ocupada_idade[-3])

# Tabela 7433 - população ocupada por VD3004, instrução;

ocupada_instrucao <- estimar_totais(desenho, ~Ocupada.com.Rendimento, ~VD3004)
tab_7433 <- reshape_wide(ocupada_instrucao[-4])
cv_7433 <- reshape_wide(ocupada_instrucao[-3])

write.csv2(tab_7433, "saida/tab_7433.csv")
write.csv2(cv_7433, "saida/cv_7433.csv")

# Tabela 7434 - população ocupada por V2007, sexo;

ocupada_sexo <- estimar_totais(desenho, ~Ocupada.com.Rendimento, ~V2007)
tab_7434 <- reshape_wide(ocupada_sexo[-4])
cv_7434 <- reshape_wide(ocupada_sexo[-3])

write.csv2(tab_7434, "saida/tab_7434.csv")
write.csv2(cv_7434, "saida/cv_7434.csv")

# Tabela 7439 - população ocupada por V2005, responsáveis;

ocupada_responsavel <- estimar_totais(
	subset(desenho, V2005 == "Pessoa responsável pelo domicílio"),
	~Ocupada.com.Rendimento
)

tab_7439 <- ocupada_responsavel[1:2]
cv_7439 <- ocupada_responsavel[-2]

write.csv2(tab_7439, "saida/tab_7439.csv")
write.csv2(cv_7439, "saida/cv_7439.csv")

# Tabela 7440 - população ocupada por V1023, área;

ocupada_area <- estimar_totais(desenho, ~Ocupada.com.Rendimento, ~V1023)
levels(ocupada_area$V1023) <- areas_geograficas
tab_7440 <- reshape_wide(ocupada_area[-4])
cv_7440 <- reshape_wide(ocupada_area[-3])

write.csv2(tab_7440, "saida/tab_7440.csv")
write.csv2(cv_7440, "saida/cv_7440.csv")

# Tabela 7436 - população ocupada por populacao residente

ocupada_total <- svytotal(~Estrato.Geo, desenho)
tab_7436 <- data.frame(
	Estrato.Geo <- estratos_geo,
	Populacao.Residente = ocupada_total[[1]],
	cv = cv(ocupada_total)
)

write.csv2(tab_7436, "saida/tab_7436.csv")
