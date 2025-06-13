# ----------------------------------------------------
# R/09_shiny_dashboard.R
# Cria um aplicativo R Shiny Dashboard para visualização de dados
# de partilha de bicicletas em Seul.
# ----------------------------------------------------

message("Iniciando a criação e lançamento do R Shiny Dashboard...")

# Carregar o dataset limpo de Seul
# Crucial se o script for executado isoladamente
# Se `seoul_bike_sharing_df` já estiver no ambiente, esta linha não é necessária,
# mas garante que a aplicação funciona independentemente.
if (!exists("seoul_bike_sharing_df")) {
  seoul_bike_sharing_df <- read_csv("data/processed/seoul_bike_sharing_cleaned.csv", show_col_types = FALSE)
  # Removidas as linhas de mutate para 'hora' e 'estacoes' daqui,
  # pois já foram processadas em 05_data_cleaning.R e salvas no CSV.
  # Apenas mantemos o as.Date para 'data' se necessário, caso read_csv não a detete automaticamente
  seoul_bike_sharing_df <- seoul_bike_sharing_df %>%
    mutate(data = as.Date(data)) # Garante que 'data' é um tipo Date
  message("Dados de Seul carregados para o Shiny App.")
}

# --- Definição da Interface do Utilizador (UI) ---
ui <- fluidPage(
  titlePanel("Dashboard de Partilha de Bicicletas em Seul"),
  
  sidebarLayout(
    sidebarPanel(
      h3("Filtros de Visualização"),
      selectInput("estacao_filtro",
                  "Selecione a Estação:",
                  choices = c("Todas", levels(seoul_bike_sharing_df$estacoes)),
                  selected = "Todas"),
      sliderInput("hora_filtro",
                  "Selecione a Hora:",
                  min = 0,
                  max = 23,
                  value = c(0, 23),
                  step = 1,
                  animate = TRUE)
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Visão Geral Diária",
                 plotOutput("plot_demanda_diaria"),
                 h4("Média Diária de Bicicletas Alugadas:"),
                 textOutput("media_diaria_text")),
        tabPanel("Procura Horária por Estação", # ALTERADO: Demanda -> Procura
                 plotOutput("plot_demanda_horaria"))
      )
    )
  )
)

# --- Definição da Lógica do Servidor (Server) ---
server <- function(input, output, session) {
  
  # Filtra os dados com base nos inputs do utilizador
  dados_filtrados <- reactive({
    df <- seoul_bike_sharing_df
    
    if (input$estacao_filtro != "Todas") {
      df <- filter(df, estacoes == input$estacao_filtro)
    }
    
    df <- filter(df, as.numeric(as.character(hora)) >= input$hora_filtro[1] &
                   as.numeric(as.character(hora)) <= input$hora_filtro[2])
    df
  })
  
  # Renderização do gráfico de tendência diária
  output$plot_demanda_diaria <- renderPlot({
    dados_filtrados() %>%
      group_by(data) %>%
      summarise(contagem_media = mean(contagem_bicicletas_alugadas, na.rm = TRUE), .groups = 'drop') %>%
      ggplot(aes(x = data, y = contagem_media)) +
      geom_line(color = "steelblue") +
      geom_smooth(method = "loess", se = FALSE, color = "darkred") +
      labs(
        title = "Tendência Diária de Bicicletas Alugadas",
        x = "Data",
        y = "Média de Bicicletas Alugadas"
      ) +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5))
  })
  
  # Calcula e exibe a média diária de bicicletas alugadas
  output$media_diaria_text <- renderText({
    media <- dados_filtrados() %>%
      group_by(data) %>%
      summarise(contagem_media = mean(contagem_bicicletas_alugadas, na.rm = TRUE), .groups = 'drop') %>%
      pull(contagem_media) %>%
      mean(na.rm = TRUE)
    paste("A média diária de bicicletas alugadas para os filtros selecionados é:", round(media, 2))
  })
  
  # Renderização do gráfico de procura horária por estação
  output$plot_demanda_horaria <- renderPlot({ # O nome do output ID não precisa mudar
    dados_filtrados() %>%
      group_by(hora, estacoes) %>%
      summarise(media_alugueres = mean(contagem_bicicletas_alugadas, na.rm = TRUE), .groups = 'drop') %>%
      ggplot(aes(x = hora, y = media_alugueres, fill = estacoes)) +
      geom_bar(stat = "identity", position = "dodge") +
      labs(
        title = "Média de Bicicletas Alugadas por Hora e Estação", # ALTERADO: Demanda -> Procura
        x = "Hora do Dia",
        y = "Média de Bicicletas Alugadas",
        fill = "Estação"
      ) +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5),
            axis.text.x = element_text(angle = 45, hjust = 1))
  })
}

# --- Lança o Aplicativo Shiny ---
message("A lançar o aplicativo Shiny... Isso pode demorar alguns segundos.")
message("Se o aplicativo não abrir automaticamente, verifique a consola para o URL.")
shinyApp(ui = ui, server = server)

message("Aplicativo R Shiny lançado. Pressione Esc ou feche a janela para parar.")