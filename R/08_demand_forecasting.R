# ----------------------------------------------------
# R/08_demand_forecasting.R
# Previsão da Procura de Partilha de Bicicletas usando Modelos de Regressão.
# Inclui preparação de dados, treino, avaliação e salvamento do modelo.
# ----------------------------------------------------

message("Iniciando a fase de Previsão da Procura de Bicicletas (Modelagem)...")

# --- Carregar o dataset limpo de Seul (se não estiver já em ambiente) ---
if (!exists("seoul_bike_sharing_df")) {
  seoul_bike_sharing_df <- read_csv("data/processed/seoul_bike_sharing_cleaned.csv", show_col_types = FALSE) %>%
    mutate(
      data = as.Date(data),
      hora = factor(hora, levels = 0:23, ordered = TRUE),
      estacoes = factor(estacoes, levels = c("Inverno", "Primavera", "Verão", "Outono"))
    )
  message("Carregado 'seoul_bike_sharing_cleaned.csv' para modelagem.")
}

# --- 8.1. Feature Engineering (Criação de Novas Variáveis) ---
# Criar variáveis que possam ser úteis para a previsão
seoul_model_df <- seoul_bike_sharing_df %>%
  mutate(
    dia_da_semana = wday(data, label = TRUE, abbr = FALSE),
    mes = month(data, label = TRUE, abbr = FALSE),
    ano = year(data),
    hora_numerica = as.numeric(as.character(hora)),
    temp_x_hora = temperatura * hora_numerica,
    feriado = factor(feriado),
    dia_funcional = factor(dia_funcional),
    estacoes = factor(estacoes)
  ) %>%
  # Mantenha a coluna 'data' para a divisão treino/teste baseada no tempo.
  # Remova apenas a variável target 'contagem_bicicletas_alugadas' para as variáveis preditoras (X)
  # ao construir a matriz para o glmnet, mas não do dataframe principal de modelagem ainda.
  select(
    data, # <--- Mantenha a coluna 'data' aqui!
    contagem_bicicletas_alugadas, temperatura, humidade, velocidade_vento,
    visibilidade, temperatura_ponto_orvalho, radiacao_solar,
    precipitacao, queda_neve, estacoes, feriado, dia_funcional,
    dia_da_semana, mes, hora_numerica, temp_x_hora
  ) %>%
  drop_na()

message("Feature Engineering concluído.")

# --- 8.2. Divisão dos Dados: Treino e Teste ---
# Para modelos de séries temporais, é melhor dividir por tempo
# Divisão simples por data, e.g., 80% para treino, 20% para teste
set.seed(123) # Para reprodutibilidade

# Determinar a data de corte (80% dos dados para treino)
data_corte <- quantile(as.numeric(seoul_model_df$data), 0.8)
data_corte <- as.Date(data_corte, origin = "1970-01-01")

dados_treino <- seoul_model_df %>%
  filter(data <= data_corte)
dados_teste <- seoul_model_df %>%
  filter(data > data_corte)

message(paste("Dados divididos: Treino =", nrow(dados_treino), "linhas, Teste =", nrow(dados_teste), "linhas."))

# --- 8.3. Treino do Modelo de Regressão ---
# 'glmnet' para uma regressão linear com regularização (Ridge/Lasso)

# Preparar a matriz de design (X) e o vetor de resposta (y)
x_treino <- model.matrix(contagem_bicicletas_alugadas ~ . - data, data = dados_treino)[, -1] # Remove a coluna 'data' e a coluna do intercept
y_treino <- dados_treino$contagem_bicicletas_alugadas

x_teste <- model.matrix(contagem_bicicletas_alugadas ~ . - data, data = dados_teste)[, -1]
y_teste <- dados_teste$contagem_bicicletas_alugadas

message("A treinar o modelo de regressão com glmnet (Elastic Net)...")
# Treina o modelo usando validação cruzada para encontrar o melhor lambda
# alpha = 1 para Lasso, alpha = 0 para Ridge. Usamos 0.5 (Elastic Net)
modelo_glmnet <- cv.glmnet(x_treino, y_treino, alpha = 0.5, family = "gaussian")

message("Modelo treinado com sucesso.")

# --- 8.4. Avaliação do Modelo ---
# Fazer previsões no conjunto de teste
previsoes_glmnet <- predict(modelo_glmnet, newx = x_teste, s = "lambda.min")
previsoes_glmnet <- as.numeric(previsoes_glmnet)

# Calcular métricas de avaliação (RMSE e R-quadrado)
rmse <- sqrt(mean((y_teste - previsoes_glmnet)^2))
r_squared <- cor(y_teste, previsoes_glmnet)^2

cat("\n--- Avaliação do Modelo de Regressão ---\n")
cat("RMSE (Root Mean Squared Error):", round(rmse, 2), "\n")
cat("R-quadrado:", round(r_squared, 4), "\n")

# Visualizar as previsões vs. valores reais
plot_previsoes <- ggplot(data.frame(Reais = y_teste, Previsoes = previsoes_glmnet), aes(x = Reais, y = Previsoes)) +
  geom_point(alpha = 0.5, color = "darkgreen") +
  geom_abline(intercept = 0, slope = 1, color = "red", linetype = "dashed", size = 1) +
  labs(
    title = "Previsões do Modelo vs. Valores Reais",
    x = "Contagem Real de Bicicletas Alugadas",
    y = "Contagem Prevista de Bicicletas Alugadas"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))
print(plot_previsoes)
ggsave("output/plots/model_predictions_vs_actual.png", plot = plot_previsoes, width = 8, height = 6)
message("Gráfico de Previsões vs. Reais salvo em 'output/plots/model_predictions_vs_actual.png'.")

# --- 8.5. Importância das Variáveis (usando 'vip') ---
# Requer um modelo treinado de forma que 'vip' possa interpretar.
# glmnet funciona bem com vip.
message("Calculando e visualizando a importância das variáveis...")
plot_vip <- vip(modelo_glmnet, num_features = 10, geom = "point", aesthetics = list(color = "darkblue", size = 4)) +
  labs(title = "Importância das Variáveis no Modelo de Demanda") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))
print(plot_vip)
ggsave("output/plots/variable_importance.png", plot = plot_vip, width = 9, height = 6)
message("Gráfico de Importância das Variáveis salvo em 'output/plots/variable_importance.png'.")

# --- 8.6. Guardar o Modelo Treinado ---
# Guardar o modelo para uso posterior no Shiny Dashboard ou outras análises
if (!dir.exists("output/models")) {
  dir.create("output/models", recursive = TRUE)
  message("Pasta 'output/models/' criada.")
}
saveRDS(modelo_glmnet, "output/models/modelo_glmnet_demanda_bicicletas.rds")
message("Modelo treinado salvo em 'output/models/modelo_glmnet_demanda_bicicletas.rds'.")

message("Fase de Previsão da Procura de Bicicletas concluída.")