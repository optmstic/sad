# ----------------------------------------------------
# R/04_load_data.R
# Carrega todos os datasets brutos necessários para o projeto.
# ----------------------------------------------------

message("Carregando dados brutos...")

# Carrega os dados do web scraping
# 'raw_bike_sharing_systems.csv' que foi salvo pelo 02_web_scraping.R
bike_sharing_systems_raw <- read_csv("data/raw/raw_bike_sharing_systems.csv", show_col_types = FALSE)

# Carrega os dados da API OpenWeather
cities_weather_forecast_raw <- read_csv("data/raw/raw_cities_weather_forecast.csv", show_col_types = FALSE)

# Carrega os dados das cidades mundiais
world_cities_raw <- read_csv("data/raw/raw_worldcities.csv", show_col_types = FALSE)

# Carrega os dados de bike sharing de Seul
seoul_bike_sharing_raw <- read_csv("data/raw/raw_seoul_bike_sharing.csv", locale = locale(encoding = "ISO-8859-1"), show_col_types = FALSE)

# Carrega o ficheiro com a frota de bicicletas por cidade (adicionado para o Ponto 9, item 11)
bike_fleet_by_city_raw <- read_csv("data/raw/raw_bike_fleet_by_city.csv", show_col_types = FALSE)

message("Dados brutos carregados com sucesso.")