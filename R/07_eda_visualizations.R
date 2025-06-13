# ----------------------------------------------------
# R/07_eda_visualizations.R
# Realiza Análise Exploratória de Dados (EDA) com visualizações usando ggplot2.
# Os gráficos gerados são salvos na pasta 'output/plots/'.
# ----------------------------------------------------

message("Iniciando Análise Exploratória de Dados (EDA) - Visualizações...")

# O dataframe deve star limpo está disponível
# Se se estiver a executar este script isoladamente, precisa de o carregar aqui:
# seoul_bike_sharing_df <- read_csv("data/processed/seoul_bike_sharing_cleaned.csv")

# --- PONTO 10: EDA com Visualização ---

# 1. e 2. Carregar o conjunto de dados e reformular DATE como data
# Estas etapas já foram tratadas no script 04_load_data.R e 05_data_cleaning.R
# seoul_bike_sharing_raw <- read_csv("data/raw/raw_seoul_bike_sharing.csv", locale = locale(encoding = "ISO-8859-1"))
# seoul_bike_sharing_df já está limpo e formatado com 'data' como Date.

# 3. Transmitir 'Hora' como uma variável categórica
# Já feita em 05_data_cleaning.R, mas garantindo que é um factor ordenado para o gráfico
seoul_bike_sharing_df <- seoul_bike_sharing_df %>%
  mutate(hora = factor(hora, levels = 0:23, ordered = TRUE))

# 4. Resumo completo do conjunto de dados
cat("\n--- Resumo do Conjunto de Dados de Seul ---\n")
message("Dimensões do dataframe:")
print(dim(seoul_bike_sharing_df))
message("\nPrimeiras linhas:")
print(head(seoul_bike_sharing_df))
message("\nResumo estatístico das variáveis numéricas:")
print(summary(seoul_bike_sharing_df))
message("\nEstrutura do dataframe:")
print(str(seoul_bike_sharing_df))
message("\nDistribuição de categorias para 'estacoes':")
print(table(seoul_bike_sharing_df$estacoes))
message("\nDistribuição de categorias para 'feriado':")
print(table(seoul_bike_sharing_df$feriado))

# 5. Número de feriados no df
num_feriados <- sum(seoul_bike_sharing_df$feriado == "Holiday")
cat("\n--- Informações sobre Feriados e Dias Funcionais ---\n")
cat("Número de feriados no conjunto de dados:", num_feriados, "\n")

# 6. Calcular a percentagem de registos que caem num feriado.
total_registros <- nrow(seoul_bike_sharing_df)
registros_feriado <- sum(seoul_bike_sharing_df$feriado == "Holiday")
percentagem_feriado <- (registros_feriado / total_registros) * 100
cat("Percentagem de registros que caem em um feriado:", round(percentagem_feriado, 2), "%\n")

# 7. - Dado que há exatamente um ano inteiro de dados, determinar o nr.de registos
dias_por_ano <- 365
horas_por_dia <- 24
registros_esperados <- dias_por_ano * horas_por_dia
cat("Número esperado de registros em um ano (365 * 24):", registros_esperados, "\n")

# 8 - Dadas as observações para o 'FUNCTIONING_DAY', quantos registos existem
dias_funcionais_contagem <- sum(seoul_bike_sharing_df$dia_funcional == "Yes")
registros_funcionais <- dias_funcionais_contagem * 24
cat("Número de registros para dias funcionais (dias com serviço * 24 horas):", registros_funcionais, "\n")

# 9. Precipitação total sazonal e a queda de neve por estação
dados_sazonais_precipitacao <- seoul_bike_sharing_df %>%
  group_by(estacoes) %>%
  summarize(
    precipitacao_total = sum(precipitacao, na.rm = TRUE),
    queda_neve_total = sum(queda_neve, na.rm = TRUE),
    .groups = 'drop'
  )
cat("\n--- Precipitação Total Sazonal e Queda de Neve por Estação ---\n")
print(dados_sazonais_precipitacao)

# 10. Gráfico de dispersão: Contagem de Bicicletas Alugadas ao longo do Tempo
plot1 <- ggplot(seoul_bike_sharing_df, aes(x = data, y = contagem_bicicletas_alugadas)) +
  geom_point(alpha = 0.5, color = "steelblue") +
  labs(
    title = "Contagem de Bicicletas Alugadas ao Longo do Tempo",
    x = "Data",
    y = "Número de Bicicletas Alugadas"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))
print(plot1)
ggsave("output/plots/scatter_bike_count_over_time.png", plot = plot1, width = 10, height = 6)
message("Gráfico 'scatter_bike_count_over_time.png' ")

# 11. Gráfico de dispersão com a variável 'hora' representada pela cor
plot2 <- ggplot(seoul_bike_sharing_df, aes(x = data, y = contagem_bicicletas_alugadas, color = hora)) +
  geom_point(alpha = 0.6) +
  scale_color_viridis_d(option = "plasma", name = "Hora do Dia") + # Melhor esquema de cores
  labs(
    title = "Contagem de Bicicletas Alugadas por Hora ao Longo do Tempo",
    x = "Data",
    y = "Número de Bicicletas Alugadas"
  ) +
  theme_light() +
  theme(plot.title = element_text(hjust = 0.5))
print(plot2)
ggsave("output/plots/scatter_bike_count_by_hour.png", plot = plot2, width = 12, height = 7)
message("Gráfico 'scatter_bike_count_by_hour.png' salvo.")

# 12. Histograma com a curva de densidade da Contagem de Bicicletas Alugadas
plot3 <- ggplot(seoul_bike_sharing_df, aes(x = contagem_bicicletas_alugadas)) +
  geom_histogram(aes(y = after_stat(density)), bins = 30, fill = "lightblue", color = "darkblue", alpha = 0.7) +
  geom_density(color = "red", linewidth = 1) +
  labs(
    title = "Distribuição da Contagem de Bicicletas Alugadas",
    x = "Contagem de Bicicletas Alugadas",
    y = "Densidade"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))
print(plot3)
ggsave("output/plots/histogram_bike_count_density.png", plot = plot3, width = 8, height = 5)
message("Gráfico 'histogram_bike_count_density.png' salvo.")

# 13. Gráfico de dispersão da correlação entre 'Rented Bike Count' e 'Temperatura' por 'Estações', usando 'Hora' como cor
# As estações já foram recodificadas para português em 05_data_cleaning.R
plot4 <- ggplot(seoul_bike_sharing_df, aes(x = temperatura, y = contagem_bicicletas_alugadas, color = hora)) +
  geom_point(alpha = 0.6) +
  facet_wrap(~ estacoes, scales = "free_y") + # 'scales = "free_y"' permite que os eixos Y variem por painel
  scale_color_viridis_d(option = "magma", name = "Hora do Dia") +
  labs(
    title = "Relação entre Aluguer de Bicicletas, Temperatura e Hora por Estação",
    x = "Temperatura (°C)",
    y = "Contagem de Bicicletas Alugadas"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))
print(plot4)
ggsave("output/plots/scatter_bike_temp_season_hour.png", plot = plot4, width = 12, height = 7)
message("Gráfico 'scatter_bike_temp_season_hour.png' salvo.")

# 14. Boxplots de 'Rented Bike Count' vs 'Hora' agrupados por 'Estações'
plot5 <- ggplot(seoul_bike_sharing_df, aes(x = hora, y = contagem_bicicletas_alugadas)) +
  geom_boxplot(fill = "lightblue", color = "darkblue", outlier.alpha = 0.3) +
  facet_wrap(~ estacoes, scales = "free_y") +
  labs(
    title = "Distribuição da Contagem de Bicicletas Alugadas por Hora e Estação",
    x = "Hora do Dia",
    y = "Contagem de Bicicletas Alugadas"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5),
    axis.text.x = element_text(angle = 45, hjust = 1) # Rotação dos rótulos do eixo X
  )
print(plot5)
ggsave("output/plots/boxplot_bike_count_hour_season.png", plot = plot5, width = 12, height = 7)
message("Gráfico 'boxplot_bike_count_hour_season.png' salvo.")

# 15. Agrupar os dados por 'data' e calcular a precipitação total e queda de neve
dados_diarios <- seoul_bike_sharing_df %>%
  group_by(data) %>%
  summarize(
    precipitacao_total_diaria = sum(precipitacao, na.rm = TRUE),
    queda_neve_total_diaria = sum(queda_neve, na.rm = TRUE),
    .groups = 'drop'
  )
cat("\n--- Precipitação Diária Total e Queda de Neve Diária Total ---\n")
print(head(dados_diarios)) # Mostra as primeiras linhas

# 16. Determinar quantos dias tiveram queda de neve
dias_com_queda_de_neve <- dados_diarios %>% # Usar o dataframe diário para evitar contagens repetidas
  filter(queda_neve_total_diaria > 0) %>%
  summarize(total_dias_com_neve = n())
cat("\n--- Dias com Queda de Neve ---\n")
print(dias_com_queda_de_neve)


message("Análise Exploratória de Dados (EDA) - Visualizações concluída. Gráficos salvos em 'output/plots/'.")