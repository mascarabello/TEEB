rm(list=ls())
options(scipen = 999)
options(stringsAsFactors = F)
# installing packages
library(pacman)
#p_load( raster, rgdal, prop,   dplyr, ggplot2,RPostgres, tidyr, ggrepel, tidyverse, forcats,tidyr)
p_load( raster, rgdal,   dplyr, ggplot2,RPostgres, tidyr, ggrepel, tidyverse, forcats,tidyr)
#install.packages('BiocManager')
 
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

dt <- dbGetQuery(connec_local , "WITH FOO as (select 
substring(municipios::text, 1, 2)::int as cd_uf,
sum(acum_cpd) as area_cpd_acc,
sum(acum_pd) as area_pd_acc,
CASE 
	WHEN idcar_imaflora > 0 THEN 'dentro de imóvel rural'
    else 'fora de imóvel rural'
END dentrofora_imovel
from teeb.raiox_conversao_acumulada
WHERE idcar_imaflora IS NOT NULL AND municipios IS NOT NULL
group by cd_uf,dentrofora_imovel)
SELECT 
CASE 
    WHEN cd_uf = 11  THEN 'Norte'
    WHEN cd_uf = 12  THEN 'Norte'
    WHEN cd_uf = 13  THEN 'Norte'
	WHEN cd_uf = 14  THEN 'Norte'
	WHEN cd_uf = 15  THEN 'Norte'
	WHEN cd_uf = 16  THEN 'Norte'
	WHEN cd_uf = 17  THEN 'Norte'
	WHEN cd_uf = 21  THEN 'Nordeste'	
	WHEN cd_uf = 22  THEN 'Nordeste'
	WHEN cd_uf = 23  THEN 'Nordeste'
	WHEN cd_uf = 24  THEN 'Nordeste'
	WHEN cd_uf = 25  THEN 'Nordeste'
	WHEN cd_uf = 26  THEN 'Nordeste'
	WHEN cd_uf = 27  THEN 'Nordeste'
	WHEN cd_uf = 28  THEN 'Nordeste'
	WHEN cd_uf = 29  THEN 'Nordeste'
	WHEN cd_uf = 31  THEN 'Sudeste'	
	WHEN cd_uf = 32  THEN 'Sudeste'	
	WHEN cd_uf = 33  THEN 'Sudeste'	
	WHEN cd_uf = 35  THEN 'Sudeste'		
	WHEN cd_uf = 41  THEN 'Sul'					
	WHEN cd_uf = 42  THEN 'Sul'					
	WHEN cd_uf = 43  THEN 'Sul'					
	WHEN cd_uf = 50  THEN 'Centro-Oeste'
	WHEN cd_uf = 51  THEN 'Centro-Oeste'
	WHEN cd_uf = 52  THEN 'Centro-Oeste'
	WHEN cd_uf = 53  THEN 'Centro-Oeste'
END regiao,
dentrofora_imovel,
sum(area_cpd_acc)/1000000 as area_cpd_mha,
sum(area_pd_acc)/1000000 as area_pd_mha
from foo
group by dentrofora_imovel, regiao")


class(dt$regiao)
my_order <-c('Norte','Nordeste','Centro-Oeste','Sudeste','Sul')


dt = within(dt, 
            regiao <- factor(regiao, 
                                       levels=my_order))

sum(dt$area_cpd_mha)
sum(dt$area_pd_mha)
options(OutDec=",")
## RPD
p1 <- ggplot(data = dt , aes(x=regiao,fill=dentrofora_imovel,y =area_cpd_mha ) )+
               geom_bar(position="stack", stat="identity") +
  scale_fill_manual(values = c("dentro de imóvel rural" = "#122e89", "fora de imóvel rural" = "#ea9247"))+
  geom_text(aes(label = round(area_cpd_mha, 1)),position = position_stack(vjust = 0.5), size=12) +
  labs(x = "Grande Região", y = "Área de CPD (Mha)", fill = "", size = 30) +
  theme_bw(base_size = 26) + theme(legend.position="top",
                                   legend.text = element_text(size = 20));p1
               
  

ggsave(filename = '/Users/marlucescarabello/Dropbox/Work/GPP/Teeb/P4_adicional/convertido_CPD_dentro_foraimovel.png', plot = p1, units = 'in', dpi = 300, scale = 1.5)

class(dt$area_pd_mha)
## PD
p2 <- ggplot(data = dt , aes(x=regiao,fill=dentrofora_imovel,y =area_pd_mha ) )+
  geom_bar(position="stack", stat="identity") +
  scale_fill_manual(values = c("dentro de imóvel rural" = "#122e89", "fora de imóvel rural" = "#ea9247"))+
  geom_text(aes(label = round(area_pd_mha, 1)),position = position_stack(vjust = 0.5), size=12) +
  labs(x = "Grande Região", y = "Área de DAA (Mha)", fill = "", size = 30) +
  theme_bw(base_size = 26) + theme(legend.position="top",
                                   legend.text = element_text(size = 20));p2


colnames(dt)
ggsave(filename = '/Users/marlucescarabello/Dropbox/Work/GPP/Teeb/P4_adicional/convertido_DAA_dentro_foraimovel.png', plot = p2, units = 'in', dpi = 300, scale = 1.5)
