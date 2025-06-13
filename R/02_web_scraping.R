# ----------------------------------------------------
# R/02_web_scraping.R
# Realiza web scraping da Wikipedia para obter dados de sistemas de bike sharing.
# ----------------------------------------------------

# URL da página da Wikipedia
url_wiki <- "https://en.wikipedia.org/wiki/List_of_bicycle-sharing_systems"

# Lê o conteúdo HTML da URL
message("A realizar web scraping da Wikipedia...")
conteudo_html <- read_html(url_wiki)

# Extrai todas as tabelas da página
nos_tabelas <- html_nodes(conteudo_html, 'table')

# NOTA: Como uma página fa Wikipedia tem várias tabelas, é necessário identificar a correta.
# Geralmente, a tabela principal é uma das primeiras ou pode ter uma classe CSS específica.
# Inspecionar 'nos_tabelas' ajuda a encontrar o índice correto.
# Por exemplo, se a tabela desejada for a primeira (índice 1):
# tabela_html <- html_table(nos_tabelas[[1]], fill = TRUE)
  
# Sendo a primeira tabela:
tabela_html <- html_table(nos_tabelas[[1]], fill = TRUE) # Usando o primeiro node de tabela como exemplo

# Remove colunas duplicadas que podem surgir do web scraping
tabela_html <- tabela_html[, !duplicated(colnames(tabela_html))]

# Renomeia as colunas para um formato padronizado e legível
names(tabela_html) <- c(
  "Pais",
  "Cidade",
  "Nome",
  "Sistema",
  "Operador",
  "Data_Lancamento",
  "Data_Fecho"
)

# Salva os dados brutos da Wikipedia antes de qualquer limpeza pesada
# Isso garante que a fonte original está preservada
write_csv(tabela_html, "data/raw/raw_bike_sharing_systems.csv")

message("Web scraping concluído e dados salvos em 'data/raw/raw_bike_sharing_systems.csv'.")
