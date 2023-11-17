rm(list=ls())
options(scipen = 999)
options(stringsAsFactors = F)
# installing packages
library(pacman)
#p_load( raster, rgdal, prop,   dplyr, ggplot2,RPostgres, tidyr, ggrepel, tidyverse, forcats,tidyr)
p_load( raster, rgdal,   dplyr, ggplot2,RPostgres, tidyr, ggrepel, tidyverse, forcats,tidyr,PostgreSQL)
install.packages('BiocManager')
library(RPostgres)

tryCatch({
  drv <- RPostgres::Postgres()
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

dt <- dbGetQuery(connec_local , "WITH FOO as (select 
substring(municipios::text, 1, 2)::int as cd_uf,
sum(rpd1020) as acum_rpd,
sum(pd1020) as acum_pd,
CASE 
	WHEN idcar_imaflora > 0 THEN 'dentro de imóvel rural'
    else 'fora de imóvel rural'
END dentrofora_imovel
from public.teeb_raiox_recuperacao2_final
WHERE idcar_imaflora IS NOT NULL AND municipios IS NOT NULL
group by cd_uf,dentrofora_imovel)
select 
sum(acum_rpd)/1000000 as RPD,
sum(acum_pd)/1000000 as PD,
dentrofora_imovel
from FOO
group by dentrofora_imovel")

dt

dados_processados <- dt %>%
  gather(categoria, area_mha, -dentrofora_imovel) %>%
  mutate(
    categoria = factor(categoria, levels = c("rpd", "pd")),
    categoria_label = ifelse(categoria == "rpd", "RPD", "PD")
  )

colnames(dt)

options(OutDec=",")
## RPD
p1 <- ggplot(data = dados_processados , aes(x=categoria_label,y = area_mha,fill=dentrofora_imovel) )+
  geom_bar(position="stack", stat="identity") +
  scale_fill_manual(values = c('dentro de imóvel rural' = "#122e89", 'fora de imóvel rural' = "#ea9247")) +
  geom_text(aes(label = round(area_mha, 1)),position = position_stack(vjust = 0.5), size=12) +
  labs(x = "", y = "Área (Mha)", fill = "", size = 30) +
  #scale_x_discrete(labels = dados_processados$categoria_label) + 
  theme_bw(base_size = 30) + theme(legend.position="top",
                                   legend.text = element_text(size = 20));p1


ggsave(filename = '/Users/marlucescarabello/Dropbox/Work/GPP/Teeb/P4_adicional/recuperado_degradado_dentrofora.png', plot = p1, units = 'in', dpi = 300, scale = 1.5)

