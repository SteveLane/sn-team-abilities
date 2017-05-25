library(rvest)
library(dplyr)
url <- "https://supernetball.com.au/fixture/"
net <- read_html(url)
netN <- net %>% html_nodes("table")
