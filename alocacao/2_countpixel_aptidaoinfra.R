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
            
DROP TABLE IF EXISTS public.teeb_aptinfra_imovel_100m_final; 
CREATE TABLE public.teeb_aptinfra_imovel_100m_final (

id serial4 NOT NULL,
idcar_imaflora integer NULL,
mesoregiao integer NULL,
aptidao float8 null,
infra float8 NULL,
area_ha float8 NULL
);


CREATE INDEX teeb_aptinfra_imovel_100m_final_id_idx ON public.teeb_aptinfra_imovel_100m_final USING btree (id);
CREATE INDEX teeb_aptinfra_imovel_100m_final_idcar_imaflora_idx ON public.teeb_aptinfra_imovel_100m_final USING btree (idcar_imaflora);
CREATE INDEX teeb_aptinfra_imovel_100m_final_mesoregiao_idx ON public.teeb_aptinfra_imovel_100m_final USING btree (mesoregiao);
            ")

idcar_imaflora <- raster("/Users/marlucescarabello/Documents/GitHub/TEEB/dados/processados/pa_br_malhafundiaria_imaflora_imovel_100m.tif"); idcar_imaflora;
mesoregiao <- raster("/Users/marlucescarabello/Documents/GitHub/TEEB/dados/processados/mesorregioes_BR_albers_100m.tif"); mesoregiao;
aptidao <- raster("/Users/marlucescarabello/Documents/GitHub/TEEB/dados/processados/pa_br_aptidao_100m.tif"); aptidao;
infra <- raster("/Users/marlucescarabello/Documents/GitHub/TEEB/dados/processados/pa_br_indicador_infra_100m_albers.tif"); infra; 


bss <- blockSize(mesoregiao); bss$n

for (i in 1:bss$n) {
  x <- data.frame(mesoregiao = getValues(mesoregiao, row = bss$row[i], nrows = bss$nrows[i]),
                  idcar_imaflora = getValues(idcar_imaflora, row = bss$row[i], nrows = bss$nrows[i]),
                  aptidao = getValues(aptidao, row = bss$row[i], nrows = bss$nrows[i]),
                  infra = getValues(infra, row = bss$row[i], nrows = bss$nrows[i])
  )
  
  
  x <- x %>%
    group_by(mesoregiao,idcar_imaflora,aptidao,infra) %>%
    summarise(area_ha = n()*1.0) %>% as_tibble() 
  
  dbWriteTable(connec_local, 'teeb_aptinfra_imovel_100m_final', x, row.names = F, append = T)
  
  cat('Escrito i = ', i)
  
  
}


dbDisconnect(connec_local)






