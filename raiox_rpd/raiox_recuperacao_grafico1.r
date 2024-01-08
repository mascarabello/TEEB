rm(list=ls())
options(scipen = 999)
options(stringsAsFactors = F)
# installing packages
library(pacman)
#p_load( raster, rgdal, prop,   dplyr, ggplot2,RPostgres, tidyr, ggrepel, tidyverse, forcats,tidyr)
p_load( raster, rgdal,   dplyr, ggplot2,RPostgres, tidyr, ggrepel, tidyverse, forcats,tidyr)
install.packages('BiocManager')

tryCatch({
  drv <- dbDriver("PostgreSQL")
  print("Connecting to Database…")
  connec_local <- dbConnect(drv, 
                            dbname = 'postgres',
                            host = 'localhost', 
                            port = '5432',
                            user = 'postgres', 
                            password = 'postgres')
  print("Database Connected!")
},
error=function(cond) {
  print("Unable to connect to Database.")
})


start <- Sys.time()

dt <- dbGetQuery(connec_local , "select
'Brazil' as region,
sum(rpd1011)/1000 as rp2011,
sum(rpd1112)/1000 as rp2012,
sum(rpd1213)/1000 as rp2013,
sum(rpd1314)/1000 as rp2014,
sum(rpd1415)/1000 as rp2015,
sum(rpd1516)/1000 as rp2016,
sum(rpd1617)/1000 as rp2017,
sum(rpd1718)/1000 as rp2018,
sum(rpd1819)/1000 as rp2019,
sum(rpd1920)/1000 as rp2020,
sum(pd1011)/1000 as pd2011,
sum(pd1112)/1000 as pd2012,
sum(pd1213)/1000 as pd2013,
sum(pd1314)/1000 as pd2014,
sum(pd1415)/1000 as pd2015,
sum(pd1516)/1000 as pd2016,
sum(pd1617)/1000 as pd2017,
sum(pd1718)/1000 as pd2018,
sum(pd1819)/1000 as pd2019,
sum(pd1920)/1000 as pd2020
from  teeb_raiox_recuperacao2_final 
WHERE idcar_imaflora IS NOT NULL AND municipios IS NOT NULL")


dt <- dt %>%
  pivot_longer(cols = -region, names_to = "nome_coluna") %>%
  mutate(
    ano = sub(".*(?=\\d{4}$)", "", nome_coluna, perl = TRUE),
    variavel = sub("\\d{4}$", "", nome_coluna)
  ) %>%
  select(-nome_coluna) %>%
  pivot_wider(names_from = variavel, values_from = value)

avg(dt$rp)
sum(dt$pd)


options(OutDec=",")
p1 <- ggplot(data = dt , aes(x=ano)) +
  geom_line(aes(y = rp, color = "Recuperação de Pastagem Degradada (RPD)", group = 1), size = 1.5) +
  geom_line(aes(y = pd, color = "Degradação de Pastagem (DP)", group =1 ), size = 1.5) +
  labs(x = "Ano", y = "Área de pastagem (mil hectares)", color = "", size = 30) +
  scale_color_manual(values = c("Recuperação de Pastagem Degradada (RPD)" = "#2f901b", "Degradação de Pastagem (DP)" = "#fd230a"))+
  theme_bw(base_size = 30) + theme(legend.position="top",
                     legend.text = element_text(size = 20));p1

ggsave(filename = '/Users/marlucescarabello/Dropbox/Work/GPP/Teeb/P4_adicional/recuperado_degradado.png', plot = p1, units = 'in', dpi = 300, scale = 1.5)

