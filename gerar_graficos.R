library(ggplot2)

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
