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
sum(cpd1011)/1000 as rp2011,
sum(cpd1112)/1000 as rp2012,
sum(cpd1213)/1000 as rp2013,
sum(cpd1314)/1000 as rp2014,
sum(cpd1415)/1000 as rp2015,
sum(cpd1516)/1000 as rp2016,
sum(cpd1617)/1000 as rp2017,
sum(cpd1718)/1000 as rp2018,
sum(cpd1819)/1000 as rp2019,
sum(cpd1920)/1000 as rp2020,
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
from teeb_raiox_conversao_final
WHERE idcar_imaflora IS NOT NULL AND municipios IS NOT NULL")

dt <- dt %>%
  pivot_longer(cols = -region, names_to = "nome_coluna") %>%
  mutate(
    ano = sub(".*(?=\\d{4}$)", "", nome_coluna, perl = TRUE),
    variavel = sub("\\d{4}$", "", nome_coluna)
  ) %>%
  select(-nome_coluna) %>%
  pivot_wider(names_from = variavel, values_from = value)
colnames(dt)
sum(dt$rp)/1000
sum(dt$pd)/1000
options(OutDec=",")
p1 <- ggplot(data = dt , aes(x=ano)) +
  geom_line(aes(y = rp, color = "Conversão de Pastagem Degradada (CPD)", group = 1), linewidth = 1.5) +
  geom_line(aes(y = pd, color = "Degradação de Áreas de Agricultura (DAA)", group =1 ), linewidth = 1.5) +
  labs(x = "Ano", y = "Área de pastagem (mil hectares)", color = "", size = 30) +
  scale_color_manual(values = c("Conversão de Pastagem Degradada (CPD)" = "#2f901b", "Degradação de Áreas de Agricultura (DAA)" = "#fd230a"))+
  theme_bw(base_size = 30) + theme(legend.position="top",
                     legend.text = element_text(size = 18));p1

ggsave(filename = '/Users/marlucescarabello/Dropbox/Work/GPP/Teeb/P4_adicional/conversao_degradado.png', plot = p1, units = 'in', dpi = 300, scale = 1.5)

