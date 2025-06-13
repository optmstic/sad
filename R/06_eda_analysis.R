# ----------------------------------------------------
# R/06_eda_analysis.R
# Realiza Análise Exploratória de Dados (EDA) utilizando Tidyverse (dplyr).
# ----------------------------------------------------

message("Iniciando Análise Exploratória de Dados (EDA) - Análise Numérica...")

# Certificar se  os dataframes limpos estão disponíveis
# Se se estiver a executar este script isoladamente, é necessário carregá-los aqui:
# seoul_bike_sharing_df <- read_csv("data/processed/seoul_bike_sharing_cleaned.csv")
# cities_weather_forecast_df <- read_csv("data/processed/cities_weather_forecast_cleaned.csv")
# world_cities_df <- read_csv("data/processed/world_cities_cleaned.csv")
# bike_sharing_systems_df <- read_csv("data/processed/bike_sharing_systems_cleaned.csv") # Já limpo pelo 05_data_cleaning.R

# --- PONTO 9: Realizar Análise Exploratória de Dados com SQL, Tidyverse ---

# 1. Contagem de Registos no dataset de Seul
n_registos <- nrow(seoul_bike_sharing_df)
cat("\n--- Contagem de Registos ---\n")
cat("Número de registos no conjunto de dados 'seoul_bike_sharing':", n_registos, "\n")

# 2. Horário de Funcionamento: Quantas horas tiveram uma contagem de bicicletas alugadas diferente de zero?
horas_com_registos <- seoul_bike_sharing_df %>%
  filter(contagem_bicicletas_alugadas > 0) %>%
  distinct(hora) %>%
  nrow()
cat("\n--- Horário de Funcionamento ---\n")
cat("Número de horas com contagem diferente de zero:", horas_com_registos, "\n")

# 3. Perspectivas Meteorológicas: Previsão do tempo para Seul nas próximas 3 horas
cat("\n--- Previsão Meteorológica para Seul (Próximas 3 Horas) ---\n")
hora_atual <- Sys.time()
seoul_3h_previsao <- cities_weather_forecast_df %>%
  filter(cidade == "Seoul") %>%
  filter(data_previsao > hora_atual & data_previsao <= hora_atual + lubridate::dhours(3)) %>%
  arrange(data_previsao) %>%
  select(data_previsao, temperatura, clima, humidade) # Seleciona algumas colunas relevantes
if (nrow(seoul_3h_previsao) > 0) {
  print(seoul_3h_previsao)
} else {
  cat("Nenhuma previsão disponível para as próximas 3 horas para Seul (ou API não retornou dados para este intervalo).\n")
}

# 4. Estações: Quais as estações incluídas no dataset de partilha de bicicletas de Seul?
cat("\n--- Estações no Dataset de Seul ---\n")
# As estações já foram recodificadas para português em 05_data_cleaning.R
estacoes_pt <- seoul_bike_sharing_df %>%
  distinct(estacoes) %>%
  pull(estacoes)
cat("As estações presentes no conjunto de dados de Seul são:", paste(estacoes_pt, collapse = ", "), "\n")

# 5. Intervalo de Datas: Encontrar a primeira e última data no dataset
intervalo_datas <- range(seoul_bike_sharing_df$data)
cat("\n--- Intervalo de Datas ---\n")
cat("Intervalo de datas no conjunto de dados de Seul:",
    format(intervalo_datas[1], "%d/%m/%Y"), "a",
    format(intervalo_datas[2], "%d/%m/%Y"), "\n")

# 6. Subconsulta - 'Máximo Histórico': Data e hora com mais alugueres de bicicletas
max_alugueres <- seoul_bike_sharing_df %>%
  filter(contagem_bicicletas_alugadas == max(contagem_bicicletas_alugadas)) %>%
  select(data, hora, contagem_bicicletas_alugadas)
cat("\n--- Máximo Histórico de Alugueres ---\n")
cat("Data e hora com mais alugueres de bicicletas:\n")
print(max_alugueres)

# 7. Popularidade Horária e Temperatura por Estação (Top 10)
pop_temp_estacao <- seoul_bike_sharing_df %>%
  group_by(estacoes, hora) %>%
  summarise(
    temp_media = mean(temperatura, na.rm = TRUE),
    alugueres_media = mean(contagem_bicicletas_alugadas, na.rm = TRUE),
    .groups = 'drop' # Adiciona para evitar mensagens de grupo
  ) %>%
  arrange(desc(alugueres_media)) %>%
  head(10)
cat("\n--- Top 10 Popularidade Horária e Temperatura por Estação ---\n")
print(pop_temp_estacao)

# 8. Sazonalidade do Aluguer: Contagem horária média de bicicletas por estação
sazonalidade_aluguer <- seoul_bike_sharing_df %>%
  group_by(estacoes) %>%
  summarise(
    aluguer_media = mean(contagem_bicicletas_alugadas, na.rm = TRUE),
    aluguer_min = min(contagem_bicicletas_alugadas, na.rm = TRUE),
    aluguer_max = max(contagem_bicicletas_alugadas, na.rm = TRUE),
    aluguer_sd = sd(contagem_bicicletas_alugadas, na.rm = TRUE),
    .groups = 'drop'
  )
cat("\n--- Sazonalidade do Aluguer de Bicicletas por Estação ---\n")
print(sazonalidade_aluguer)

# 9. Sazonalidade Meteorológica: Clima por estação (média das condições)
sazonalidade_clima <- seoul_bike_sharing_df %>%
  group_by(estacoes) %>%
  summarise(
    temp_media = mean(temperatura, na.rm = TRUE),
    humidade_media = mean(humidade, na.rm = TRUE),
    vento_media = mean(velocidade_vento, na.rm = TRUE),
    visibilidade_media = mean(visibilidade, na.rm = TRUE),
    ponto_orvalho_media = mean(temperatura_ponto_orvalho, na.rm = TRUE),
    rad_solar_media = mean(radiacao_solar, na.rm = TRUE),
    precipitacao_media = mean(precipitacao, na.rm = TRUE),
    neve_media = mean(queda_neve, na.rm = TRUE),
    bicicletas_media = mean(contagem_bicicletas_alugadas, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  arrange(desc(bicicletas_media))
cat("\n--- Sazonalidade Meteorológica por Estação ---\n")
print(sazonalidade_clima)

# 10. Contagem total de bicicletas em Seul e informações da cidade
total_bicicletas <- sum(seoul_bike_sharing_df$contagem_bicicletas_alugadas, na.rm = TRUE)
informacoes_seul <- world_cities_df %>%
  filter(cidade == "Seoul") %>%
  select(cidade, pais, population, lat, lng)
seul_info_completa <- informacoes_seul %>%
  mutate(
    total_bicicletas_alugadas_no_periodo = total_bicicletas
  )
cat("\n--- Informações de Seul com o Total de Bicicletas Alugadas no Período ---\n")
print(seul_info_completa)

# 11. Encontrar todos os nomes de cidades e coordenadas com escala de bicicletas comparáveis a Seul
cat("\n--- Cidades com Sistemas de Partilha de Bicicletas Comparáveis a Seul ---\n")

# Realiza o left join para adicionar a coluna 'bicicletas' ao dataframe de sistemas de bike sharing
# O 'bike_fleet_by_city_raw' foi carregado em 04_load_data.R
# O webscraping não foi eficaz para esta tarefa, pois não existe uma coluna com a contagem de bicicletas no webscrape feito à Wiki
# A recolha foi feita manualmente para o ficheiro bike_fleet_by_cit.csv e foi criado um novo ficheiro bike_sharing_systems_raw
bike_sharing_systems_with_fleet <- bike_sharing_systems_df %>%
  left_join(bike_fleet_by_city_raw %>% rename(Pais = Country, Cidade = City),
            by = c("pais" = "Pais", "cidade" = "Cidade")) %>%
  rename(bicicletas_frota = Bikes)

# Filtra as cidades com sistemas de partilha de bicicletas entre 15.000 e 20.000 bicicletas
# E faz um join com os dados das cidades para obter coordenadas
bike_sharing_comparable <- bike_sharing_systems_with_fleet %>%
  filter(bicicletas_frota >= 15000 & bicicletas_frota <= 20000) %>%
  left_join(world_cities_df, by = c("cidade", "pais")) %>%
  select(cidade, pais, lat, lng, bicicletas_frota) %>% # CORRIGIDO: Use 'lat' e 'lng'
  distinct() # Garante entradas únicas se houver duplicação após joins

if (nrow(bike_sharing_comparable) > 0) {
  for (i in 1:nrow(bike_sharing_comparable)) {
    cat(bike_sharing_comparable$cidade[i],
        "-", bike_sharing_comparable$pais[i],
        "Lat:", bike_sharing_comparable$lat[i],   # CORRIGIDO: Use 'lat'
        "Lon:", bike_sharing_comparable$lng[i],   # CORRIGIDO: Use 'lng'
        "Bikes:", bike_sharing_comparable$bicicletas_frota[i], "\n")
  }
} else {
  cat("Nenhuma cidade encontrada com frota de bicicletas comparável a Seul no intervalo especificado.\n")
}

message("Análise Exploratória de Dados (EDA) - Análise Numérica concluída.")