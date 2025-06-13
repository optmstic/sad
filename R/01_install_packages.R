# ----------------------------------------------------
# R/01_install_packages.R
# Instala e carrega os pacotes R necessários para o projeto.
# ----------------------------------------------------

# Lista de pacotes necessários
pacotes_necessarios <- c(
  "rvest", "httr", "jsonlite",
  "dplyr", "readr", "janitor", "stringr", "tidyr", "lubridate",
  "ggplot2", "shiny", "leaflet",
  "glmnet", "tidymodels", "vip"
)

# Verifica quais pacotes já estão instalados
instalados <- rownames(installed.packages())
pacotes_falta <- pacotes_necessarios[!(pacotes_necessarios %in% instalados)]

# Instala os pacotes em falta, se houver
if (length(pacotes_falta)) {
  message("Instalando os seguintes pacotes R: ", paste(pacotes_falta, collapse = ", "))
  install.packages(pacotes_falta, dependencies = TRUE)
} else {
  message("Todos os pacotes necessários já estão instalados.")
}

# Carrega todos os pacotes necessários
message("Carregando pacotes...")
lapply(pacotes_necessarios, library, character.only = TRUE)
message("Pacotes carregados com sucesso.")