# ----------------------------------------------------
# SISTEMA DE APOIO À DECISÃO 2024/2025 - Projeto SAD
# Ficheiro Principal: Execução de todas as etapas.
# ----------------------------------------------------

# Cria as pastas necessárias se não existirem
if (!dir.exists("data/processed")) {
  dir.create("data/processed", recursive = TRUE)
}
if (!dir.exists("output/plots")) {
  dir.create("output/plots", recursive = TRUE)
}
if (!dir.exists("output/models")) { # Nova pasta para modelos salvos
  dir.create("output/models", recursive = TRUE)
}

# --- 1. Instalação e Carregamento de Pacotes ---
source("R/01_install_packages.R")

# --- 2. Web Scraping de Sistemas de Bike Sharing ---
source("R/02_web_scraping.R")

# --- 3. Chamadas à API OpenWeather ---
source("R/03_api_calls.R")

# --- 4. Carregamento dos Dados Brutos ---
source("R/04_load_data.R")

# --- 5. Limpeza e Padronização dos Dados ---
# Script para limpeza dos dados que guarda os resultados na pasta 'data/processed'
source("R/05_data_cleaning.R")

# --- 6. Análise Exploratória de Dados (EDA) com SQL/Tidyverse ---
source("R/06_eda_analysis.R")

# --- 7. Análise Exploratória de Dados (EDA) com Visualizações (ggplot2) ---
source("R/07_eda_visualizations.R")

# --- 8. Previsão da Procura de Partilha de Bicicletas (Modelagem) ---
  source("R/08_demand_forecasting.R")

# --- 9. Criação de um Aplicativo R Shiny Dashboard ---
# Nota: Este script vai *lançar* a aplicação Shiny.
# Deve ser mantido no final da execução para que o dashboard abra automaticamente.
# Comentar se for executado manualmente.
source("R/09_shiny_dashboard.R")

message("Projeto de SAD concluido!")

