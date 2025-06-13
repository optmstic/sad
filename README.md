Fluxo de Execução e Comandos Detalhados

O script main.R orquestra a execução dos seguintes scripts R na ordem listada:

1. R/01_install_packages.R

* Comando Executado: source("R/01_install_packages.R")
* Função: Verifica se os pacotes listados em pacotes_necessarios estão instalados. Se não estiverem, instala-os (install.packages()) e, em seguida, carrega-os (library()) na sessão R.
* Pacotes Principais: rvest, dplyr, readr, janitor, stringr, tidyr, httr, jsonlite, ggplot2, shiny, glmnet, leaflet, lubridate, tidymodels, vip.
* Saída: Mensagens na consola sobre a instalação e o carregamento dos pacotes.

2. R/02_web_scraping.R

* Comando Executado: source("R/02_web_scraping.R")
* Função: Realiza web scraping da página da Wikipedia "List of bicycle-sharing systems".
    * Utiliza read_html() para carregar o conteúdo da página.
    * Usa html_nodes() para extrair tabelas.
    * Converte a tabela HTML relevante para um dataframe R com html_table().
    * Renomeia as colunas para um formato padronizado.
* Pacotes Principais: rvest, dplyr.
* Saída: O dataframe tabela_html é criado e salvo como data/raw/raw_bike_sharing_systems.csv. Mensagens de progresso na consola.

3. R/03_api_calls.R

* Comando Executado: source("R/03_api_calls.R")
* Função: Obtém previsões meteorológicas de várias cidades (Seoul, Los Angeles, Paris, Tokyo) usando a API OpenWeather.
    * Define uma função previsao_tempo_por_cidades() que faz chamadas GET() à API.
    * Processa a resposta JSON (content(), jsonlite) para extrair os dados relevantes.
* Pacotes Principais: httr, jsonlite.
* Saída: O dataframe raw_cities_weather_forecast_df é criado e salvo como data/raw/raw_cities_weather_forecast.csv. Mensagens de progresso na consola.

4. R/04_load_data.R

* Comando Executado: source("R/04_load_data.R")
* Função: Carrega todos os datasets brutos necessários para as etapas de limpeza e análise.
    * Utiliza read_csv() para carregar ficheiros CSV de data/raw/.
* Pacotes Principais: readr.
* Saída: _raw dataframes carregados no ambiente R.

5. R/05_data_cleaning.R

* Comando Executado: source("R/05_data_cleaning.R")
* Função: Realiza a limpeza e padronização detalhada de todos os datasets brutos.
    * Utiliza clean_names() para padronizar nomes de colunas.
    * mutate() e funções de stringr (str_replace_all, str_trim) para limpar e transformar dados.
    * Converte tipos de dados para o formato correto (ex: as.Date(), as.numeric(), factor() com níveis explícitos para estacoes, feriado, dia_funcional).
    * Corrige a coluna de bicicletas da frota (bikes) para garantir que é numérica, removendo caracteres não-dígitos.
* Pacotes Principais: dplyr, janitor, stringr, lubridate, readr.
* Saída: Dataframes limpos e padronizados são salvos na pasta data/processed/.

6. R/06_eda_analysis.R

* Comando Executado: source("R/06_eda_analysis.R")
* Função: Conduz a Análise Exploratória de Dados (EDA) aprofundada utilizando operações do tidyverse (principalmente dplyr).
    * Calcula contagens de registos, horários de funcionamento, previsões meteorológicas futuras para Seul, estações presentes, intervalos de datas.
    * Identifica o máximo histórico de alugueres.
    * Analisa popularidade horária, sazonalidade do aluguer e condições meteorológicas por estação.
    * Combina informações da cidade de Seul com o total de bicicletas alugadas.
    * Identifica cidades com frotas de bicicletas comparáveis a Seul.
* Pacotes Principais: dplyr, lubridate.
* Saída: Resultados textuais das análises impressos na consola.

7. R/07_eda_visualizations.R

* Comando Executado: source("R/07_eda_visualizations.R")
* Função: Gera diversas visualizações gráficas para a EDA usando ggplot2.
    * Gráficos de dispersão da contagem de bicicletas ao longo do tempo e por hora.
    * Histograma com curva de densidade da contagem de bicicletas.
    * Gráfico de dispersão da correlação entre contagem, temperatura e hora por estação.
    * Boxplots da contagem de bicicletas vs. hora por estação.
    * Sumários de precipitação e queda de neve.
* Pacotes Principais: ggplot2, dplyr.
* Saída: Ficheiros de imagem (.png) dos gráficos são guardados na pasta output/plots/.

8. R/08_demand_forecasting.R

* Comando Executado: source("R/08_demand_forecasting.R")
* Função: Prepara os dados e treina um modelo de regressão para prever a procura de bicicletas.
    * Realiza Feature Engineering (criação de dia_da_semana, mes, ano, hora_numerica, temp_x_hora).
    * Divide o dataset de Seul em conjuntos de treino e teste baseados no tempo (data_corte).
    * Treina um modelo de regressão com glmnet (cv.glmnet).
    * Avalia o modelo usando RMSE e R-quadrado.
    * Gera um gráfico de comparação entre previsões e valores reais.
    * Calcula e visualiza a importância das variáveis (vip).
* Pacotes Principais: dplyr, lubridate, glmnet, vip.
* Saída:
    * RMSE e R-quadrado impressos na consola.
    * model_predictions_vs_actual.png e variable_importance.png guardados em output/plots/.
    * O modelo treinado é salvo como output/models/modelo_glmnet_demanda_bicicletas.rds.

9. R/09_shiny_dashboard.R

* Comando Executado: source("R/09_shiny_dashboard.R") (ou pode ser executado manualmente para lançar a app).
* Função: Constrói e lança um aplicativo web interativo em R Shiny.
    * Define a Interface do Utilizador (ui) com filtros (selectInput, sliderInput) e painéis para gráficos e texto.
    * Define a Lógica do Servidor (server) para filtrar os dados de forma reativa e renderizar os gráficos de tendência diária e procura horária por estação.
* Pacotes Principais: shiny, dplyr, ggplot2.
* Saída: O aplicativo Shiny será aberto (no painel Viewer do RStudio ou numa janela de navegador externa, dependendo das suas configurações). A consola R indicará o URL onde a aplicação está a correr (Listening on http://127.0.0.1:XXXX).

Outputs e Resultados Finais

Após a execução bem-sucedida do main.R, os seguintes outputs principais estarão disponíveis no seu projeto:

* data/processed/:
    * bike_sharing_systems_cleaned.csv
    * cities_weather_forecast_cleaned.csv
    * world_cities_cleaned.csv
    * seoul_bike_sharing_cleaned.csv
    * bike_fleet_by_city_cleaned.csv
* output/plots/:
    * scatter_bike_count_over_time.png
    * scatter_bike_count_by_hour.png
    * histogram_bike_count_density.png
    * scatter_bike_temp_season_hour.png
    * boxplot_bike_count_hour_season.png
    * model_predictions_vs_actual.png
    * variable_importance.png
* output/models/:
    * modelo_glmnet_demanda_bicicletas.rds (o modelo de previsão treinado)
* Consola R: Mensagens de progresso, resumos de dados e métricas de avaliação do modelo.
* Aplicativo Shiny: Uma interface interativa para explorar os dados visualmente, acessível via navegador web.