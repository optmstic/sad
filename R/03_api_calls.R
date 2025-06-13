# ----------------------------------------------------
# R/03_api_calls.R
# Realiza chamadas à API OpenWeather para obter previsões meteorológicas.
# ----------------------------------------------------

# Função para obter previsão do tempo para várias cidades
previsao_tempo_por_cidades <- function(nomes_cidades) {
  cidades_clima_df <- data.frame(
    cidade = character(), tempo = character(), visibilidade = numeric(),
    temperatura = numeric(), temp_min = numeric(), temp_max = numeric(),
    pressao = numeric(), humidade = numeric(), vel_vento = numeric(),
    dir_vento = numeric(), data_previsao = character(), stringsAsFactors = FALSE
  )
  
  # Chave da API OpenWeather.
  api_key <- 'ebc5dbabe0b53e1464e3f7e37458ca51'
  
  for (nome_cidade in nomes_cidades) {
    message(paste("Obtendo previsão para:", nome_cidade))
    url_previsao <- 'https://api.openweathermap.org/data/2.5/forecast'
    consulta_previsao <- list(q = nome_cidade, appid = api_key, units='metric')
    resposta_previsao <- GET(url_previsao, query=consulta_previsao)
    lista_json <- content(resposta_previsao, as='parsed')
    
    # Verifica se a chamada da API foi bem-sucedida e se há dados na lista
    if (resposta_previsao$status_code == 200 && !is.null(lista_json$list)) {
      resultados <- lista_json$list
      
      for (resultado in resultados) {
        # Verifica se todas as variáveis necessárias existem para evitar erros
        if (!is.null(resultado$weather[[1]]$main) && !is.null(resultado$visibility) &&
            !is.null(resultado$main$temp) && !is.null(resultado$main$temp_min) &&
            !is.null(resultado$main$temp_max) && !is.null(resultado$main$pressure) &&
            !is.null(resultado$main$humidity) && !is.null(resultado$wind$speed) &&
            !is.null(resultado$wind$deg) && !is.null(resultado$dt_txt)) {
          
          cidades_clima_df <- rbind(cidades_clima_df, data.frame(
            cidade = nome_cidade,
            tempo = resultado$weather[[1]]$main,
            visibilidade = resultado$visibility,
            temperatura = resultado$main$temp,
            temp_min = resultado$main$temp_min,
            temp_max = resultado$main$temp_max,
            pressao = resultado$main$pressure,
            humidade = resultado$main$humidity,
            vel_vento = resultado$wind$speed,
            dir_vento = resultado$wind$deg,
            data_previsao = resultado$dt_txt,
            stringsAsFactors = FALSE
          ))
        }
      }
    } else {
      warning(paste("Não foi possível obter dados para", nome_cidade, ". Código de status:", resposta_previsao$status_code))
    }
  }
  
  # Renomeia as colunas do dataframe final
  names(cidades_clima_df) <- c(
    "Cidade", "Clima", "Visibilidade", "Temperatura", "Temp_min",
    "Temp_max", "Pressao", "Humidade", "Velocidade_vento", "Direcao_vento", "Data_previsao"
  )
  return(cidades_clima_df)
}

# Cidades selecionadas para a previsão (exemplos de cidades com mais de 10M de hab.)
cidades_para_previsao <- c("Seoul", "Los Angeles", "Paris", "Tokyo")

# Obtém as previsões do tempo
raw_cities_weather_forecast_df <- previsao_tempo_por_cidades(cidades_para_previsao)

# Salva os dados brutos da API
write_csv(raw_cities_weather_forecast_df, "data/raw/raw_cities_weather_forecast.csv")

message("Previsões meteorológicas obtidas e salvas em 'data/raw/raw_cities_weather_forecast.csv'.")