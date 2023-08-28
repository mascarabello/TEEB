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
  print("Database Connected!")
},
error=function(cond) {
  print("Unable to connect to Database.")
})

dbSendQuery(connec_local, "
            
DROP TABLE IF EXISTS public.teeb_cpixels_cenarios; 
CREATE TABLE public.teeb_cpixels_cenarios (

id serial4 NOT NULL,
idcar_imaflora integer NULL,
mesoregiao integer NULL, 
cenario1 integer NULL,
cenario2 integer NULL,
area_ha float8 NULL
);


CREATE INDEX teeb_cpixels_cenarios_id_idx ON public.teeb_cpixels_cenarios USING btree (id);
CREATE INDEX teeb_cpixels_cenarios_idcar_imaflora_idx ON public.teeb_cpixels_cenarios USING btree (idcar_imaflora);
CREATE INDEX teeb_cpixels_cenarios_mesoregiao_idx ON public.teeb_cpixels_cenarios USING btree (mesoregiao);
            ")



idcar_imaflora <- raster("/Users/marlucescarabello/Documents/GitHub/TEEB/dados/processados/landtenure_v202105_albers_imovel_100m.tif"); idcar_imaflora;
mesoregiao <- raster("/Users/marlucescarabello/Documents/GitHub/TEEB/dados/processados/mesorregioes_BR_albers_100m.tif"); mesoregiao;
cenario1 <- raster("/Users/marlucescarabello/Documents/GitHub/TEEB/dados/proj_espacial/pastagens_degradadas_S1_2030.tif");  cenario1;
cenario2 <- raster("/Users/marlucescarabello/Documents/GitHub/TEEB/dados/proj_espacial/pastagens_degradadas_S2_2030.tif") ; cenario2;


bss <- blockSize(mesoregiao); bss$n

for (i in 1:bss$n) {
  x <- data.frame(mesoregiao = getValues(mesoregiao, row = bss$row[i], nrows = bss$nrows[i]),
                  idcar_imaflora = getValues(idcar_imaflora, row = bss$row[i], nrows = bss$nrows[i]),
                  cenario1 = getValues(cenario1, row = bss$row[i], nrows = bss$nrows[i]),
                  cenario2 = getValues(cenario2, row = bss$row[i], nrows = bss$nrows[i]))
  
  
  x <- x %>%
    group_by(mesoregiao,idcar_imaflora, cenario1,cenario2) %>%
    summarise(area_ha = n()*1.0) %>% as_tibble()  ## 100 x 100
  
  dbWriteTable(connec_local, 'teeb_cpixels_cenarios', x, row.names = F, append = T)
  
  cat('Escrito i = ', i)
  
  
}



dbDisconnect(connec_local)
