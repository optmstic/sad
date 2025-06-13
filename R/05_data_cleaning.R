# ----------------------------------------------------
# R/05_data_cleaning.R
# Realiza a limpeza e padronização dos datasets brutos.
# Os dataframes processados são guardados em 'data/processed/'.
# ----------------------------------------------------

message("Iniciando a limpeza e padronização dos dados...")

# Limpeza e padronização dos sistemas de partilha de bicicletas
bike_sharing_systems_df <- bike_sharing_systems_raw %>%
  clean_names() %>% # Renomeia colunas para minúsculas com underscores
  mutate(across(where(is.character), ~str_replace_all(., "\\[.*?\\]", ""))) %>%
  mutate(across(where(is.character), ~str_trim(.)))

# Guarda o dataframe processado
write_csv(bike_sharing_systems_df, "data/processed/bike_sharing_systems_cleaned.csv")
message("bike_sharing_systems_cleaned.csv salvo.")

# Limpeza e padronização das previsões meteorológicas
cities_weather_forecast_df <- cities_weather_forecast_raw %>%
  clean_names() %>%
  mutate(across(where(is.character), ~str_replace_all(., "\\[.*?\\]", ""))) %>%
  mutate(across(where(is.character), ~str_trim(.))) %>%
  # Converte a coluna 'data_previsao' para formato POSIXct (data e hora)
  mutate(data_previsao = as.POSIXct(data_previsao, format = "%Y-%m-%d %H:%M:%S", tz = "UTC"))

# Guarda o dataframe processado
write_csv(cities_weather_forecast_df, "data/processed/cities_weather_forecast_cleaned.csv")
message("cities_weather_forecast_cleaned.csv salvo.")

# Limpeza e padronização das cidades mundiais
world_cities_df <- world_cities_raw %>%
  clean_names() %>% # Limpa nomes de colunas
  rename(cidade = city, pais = country) %>% # Renomeia colunas-chave
  mutate(across(where(is.character), str_trim)) %>% # Remove espaços em branco
  # Remove colunas não essenciais para a análise
  select(-city_ascii, -iso2, -iso3, -admin_name, -capital, -id)

# Guarda o dataframe processado
write_csv(world_cities_df, "data/processed/world_cities_cleaned.csv")
message("world_cities_cleaned.csv salvo.")

# Limpeza e padronização dos dados de bike sharing de Seul
seoul_bike_sharing_df <- seoul_bike_sharing_raw %>%
  clean_names() %>%
  rename(
    data = date,
    contagem_bicicletas_alugadas = rented_bike_count,
    hora = hour,
    temperatura = temperature_c,
    humidade = humidity_percent,
    velocidade_vento = wind_speed_m_s,
    visibilidade = visibility_10m,
    temperatura_ponto_orvalho = dew_point_temperature_c,
    radiacao_solar = solar_radiation_mj_m2,
    precipitacao = rainfall_mm,
    queda_neve = snowfall_cm,
    estacoes = seasons,
    feriado = holiday,
    dia_funcional = functioning_day
  ) %>%
  mutate(
    data = as.Date(data, format = "%d/%m/%Y"),
    hora = as.numeric(hora),
    estacoes = recode(estacoes,
                      "Winter" = "Inverno",
                      "Spring" = "Primavera",
                      "Summer" = "Verão",
                      "Autumn" = "Outono"),
    estacoes = factor(estacoes, levels = c("Inverno", "Primavera", "Verão", "Outono")),
    feriado = factor(feriado),
    dia_funcional = factor(dia_funcional))

# Guarda o dataframe processado
write_csv(seoul_bike_sharing_df, "data/processed/seoul_bike_sharing_cleaned.csv")
message("seoul_bike_sharing_cleaned.csv salvo.")

# Limpeza e padronização da frota de bicicletas por cidade
bike_fleet_by_city_df <- bike_fleet_by_city_raw %>%
  clean_names() %>% # Converte nomes como "Country", "City", "Bikes" para "country", "city", "bikes"
  mutate(bikes = as.numeric(gsub("[^0-9.]", "", bikes))) %>%
  mutate(across(where(is.character), ~str_replace_all(., "\\[.*?\\]", ""))) %>%
  mutate(across(where(is.character), ~str_trim(.)))

# Salva o dataframe processado
write_csv(bike_fleet_by_city_df, "data/processed/bike_fleet_by_city_cleaned.csv")
message("bike_fleet_by_city_cleaned.csv salvo.")

message("Limpeza e padronização de dados concluídas. Dados processados salvos em 'data/processed/'.")