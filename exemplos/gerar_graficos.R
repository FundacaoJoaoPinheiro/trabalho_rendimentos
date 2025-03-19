library(ggplot2)
library(flextable)

# CHATGPT #################################################

# Fontes de rendimento ------------------------------------

fontes_g1 <- ggplot(df, aes(x = Populacao, y = Rendimento, size = Peso, label = Estrato)) +
	geom_point(alpha = 0.6, color = "blue", fill = "lightblue", shape = 21) +
	geom_text(vjust = -1, size = 3) +  # Adiciona os nomes dos estratos
	scale_size(range = c(2, 12)) +  # Ajusta o tamanho das bolhas
	labs(title = "Dispersão entre População e Rendimento",
		 x = "População com Rendimento",
		 y = "Rendimento Médio (R$)",
		 size = "Participação (%)") +
	theme_minimal()

ggsave("grafico_dispersao.png", plot = fontes_g1, width = 8, height = 6, dpi = 300)

fontes_t2 <- data.frame(
	Estratos.Geo = estratos_geo,
	Todas.as.Fontes = estimar_totais(desenho, ~VD4052.Real)[[2]],
	Trabalho = estimar_totais(desenho, ~VD4019.Real)[[2]],
	Outras.Fontes = estimar_totais(desenho, ~VD4048.Real)[[2]]
)

# Gerar tabelas com as frequências dos CV's

arquivos_cv <- list.files("saida", pattern = "^cv_7.*\\.csv$",
	recursive = TRUE, full.names = TRUE)

# Ocupada ---------------------------------------------------

tabelas_cv <- ls(pattern = "^cv_7\\d+$")  

# Função para contar valores >15, NA ou NaN por estrato
contar_valores <- function(arq, limite = 15) {
  df <- read.csv2(arq)
  rowSums(is.na(df) | df > limite, na.rm = TRUE)
}

# Aplicar a função a todos os dataframes e combinar os resultados
freq_cv15 <- data.frame(
  Estrato.Geo = estratos_geo,
  sapply(arquivos_cv, contar_valores, limite = 15, simplify = T, USE.NAMES = T)
)
colnames(freq_cv15)[-1] <- gsub("^saida/.*/", "", gsub(".csv$", "", arquivos_cv))

freq_cv30 <- data.frame(
  Estrato.Geo = estratos_geo,
  sapply(arquivos_cv, contar_valores, limite = 30, simplify = T, USE.NAMES = T)
)
colnames(freq_cv30)[-1] <- gsub("^saida/.*/", "", gsub(".csv$", "", arquivos_cv))

exportar_tabela <- function(frequencias, titulo, path = NULL) {
	# Se o caminho não for fornecido, usar o nome do objeto de frequências + ".png"
	if (is.null(path)) {
		nome_objeto <- deparse(substitute(frequencias))  # Captura o nome do objeto
		path <- paste0(nome_objeto, ".png")  # Adiciona o sufixo ".png"
	}

	# Criar a tabela com flextable
	tabela <- flextable(frequencias)

	# Adicionar um título à tabela
	tabela <- set_caption(
		tabela,
		caption = titulo, 
		style = "Table Caption", align_with_table = TRUE
	)

	# Adicionar bordas horizontais internas
	tabela <- border_inner_h(tabela)

	# Centralizar todos os valores da tabela
	tabela <- align(tabela, align = "center", part = "all")

	# Exportar a tabela como uma imagem PNG
	save_as_image(tabela, path = path)

	# Mensagem de confirmação
	cat("Tabela exportada com sucesso para:", path, "\n")
}

freq_cv15 <- reshape(
  freq_cv15, 
  direction = "long", 
  varying = colnames(freq_cv15)[-1], 
  v.names = "Frequência", 
  idvar = "Estrato.Geo", 
  timevar = "Tabela", 
  times = colnames(freq_cv15)[-1]
)

freq_cv30 <- reshape(
  freq_cv30, 
  direction = "long", 
  varying = colnames(freq_cv30)[-1], 
  v.names = "Frequência", 
  idvar = "Estrato.Geo", 
  timevar = "Tabela", 
  times = colnames(freq_cv30)[-1]
)

# Resetando os rownames para evitar problemas de indexação
rownames(freq_cv15) <- NULL
rownames(freq_cv30) <- NULL

# gráfico de barras
cores_suaves <- c("#88CCEE", "#DDCC77", "#CC6677", "#AA4499", "#44AA99",
	"#999933", "#882255")

ggplot(freq_cv15, aes(x = Estrato.Geo, y = Frequência, fill = Tabela)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_manual(values = cores_suaves) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) +
  labs(title = "Frequência de CV's maiores que 15% ou Ausentes",
       x = "Estrato Geográfico",
       y = "Frequência",
       fill = "Tabela")
ggsave("saida/ocupada/bar_cv15.png", width = 8, height = 6)

ggplot(freq_cv30, aes(x = Estrato.Geo, y = Frequência, fill = Tabela)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_manual(values = cores_suaves) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) +
  labs(title = "Frequência de CV's maiores que 30% ou Ausentes",
       x = "Estrato Geográfico",
       y = "Frequência",
       fill = "Tabela")
ggsave("saida/bar_cv30.png", width = 8, height = 6)

# Criar o heatmap para frequências acima de 15
ggplot(freq_cv15, aes(x = Tabela, y = Estrato.Geo, fill = Frequência)) +
  geom_tile() +
  scale_fill_gradient(low = "green", high = "red") +  # Escala de cores (verde para baixo, vermelho para alto)
  labs(title = "Frequência de CVs > 15 por Estrato e Tabela",
       x = "Tabela", y = "Estrato Geográfico", fill = "Frequência") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotacionar rótulos do eixo x

##########################################################
