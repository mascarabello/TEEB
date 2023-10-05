
rm(list=ls())
library(raster)
library(RPostgreSQL)
library(dplyr)

tryCatch({
  drv <- dbDriver("PostgreSQL")
  print("Connecting to Database…")
  connec_local <- dbConnect(drv,
                            dbname = 'postgres',
                            host = 'localhost',
                            port = '5432',
                            user = 'postgres',
                            password = 'postgres')
  print("Database Connected!")},
  error=function(cond) {
    print("Unable to connect to Database.")})


dbSendQuery(connec_local, "
            
DROP TABLE IF EXISTS public.teeb_projbau; 
CREATE TABLE public.teeb_projbau (

id serial4 NOT NULL,
idcar_imaflora integer NULL,
mesoregiao integer NULL,
bau float8 null,
area_ha float8 NULL
);


CREATE INDEX teeb_projbau_id_idx ON public.teeb_projbau USING btree (id);
CREATE INDEX teeb_projbau_idcar_imaflora_idx ON public.teeb_projbau USING btree (idcar_imaflora);
CREATE INDEX teeb_projbau_mesoregiao_idx ON public.teeb_projbau USING btree (mesoregiao);
            ")

idcar_imaflora <- raster("/Users/marlucescarabello/Documents/GitHub/TEEB/dados/processados/landtenure_v202105_albers_imovel_100m_final.tif"); idcar_imaflora;
mesoregiao <- raster("/Users/marlucescarabello/Documents/GitHub/TEEB/dados/processados/mesorregioes_BR_albers_100m.tif"); mesoregiao;
bau <- raster("/Users/marlucescarabello/Documents/GitHub/TEEB/dados/proj_espacial/pastagens_degradadas_BAU_2030.tif"); bau;


bss <- blockSize(mesoregiao); bss$n

for (i in 1:bss$n) {
  x <- data.frame(mesoregiao = getValues(mesoregiao, row = bss$row[i], nrows = bss$nrows[i]),
                  idcar_imaflora = getValues(idcar_imaflora, row = bss$row[i], nrows = bss$nrows[i]),
                  bau = getValues(bau, row = bss$row[i], nrows = bss$nrows[i])
  )
  
  
  x <- x %>%
    group_by(mesoregiao,idcar_imaflora,bau) %>%
    summarise(area_ha = n()*1.0) %>% as_tibble() 
  
  dbWriteTable(connec_local, 'teeb_projbau', x, row.names = F, append = T)
  
  cat('Escrito i = ', i)
  
  
}


dbDisconnect(connec_local)






