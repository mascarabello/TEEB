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
            
DROP TABLE IF EXISTS public.teeb_cpixels_cenarios_rpdalocada_vfinal; 
CREATE TABLE public.teeb_cpixels_cenarios_rpdalocada_vfinal (

id serial4 NOT NULL,
idcar_imaflora integer NULL,
mesoregiao integer NULL, 
cenario1 integer NULL,
cenario2 integer NULL,
area_ha float8 NULL
);


CREATE INDEX teeb_cpixels_cenarios_rpdalocada_vfinal_id_idx ON public.teeb_cpixels_cenarios_rpdalocada_vfinal USING btree (id);
CREATE INDEX teeb_cpixels_cenarios_rpdalocada_vfinal_idcar_imaflora_idx ON public.teeb_cpixels_cenarios_rpdalocada_vfinal USING btree (idcar_imaflora);
CREATE INDEX teeb_cpixels_cenarios_rpdalocada_vfinal_mesoregiao_idx ON public.teeb_cpixels_cenarios_rpdalocada_vfinal USING btree (mesoregiao);
            ")



idcar_imaflora <- raster("/Users/marlucescarabello/Documents/GitHub/TEEB/dados/processados/landtenure_v202105_albers_imovel_100m_final.tif"); idcar_imaflora;
mesoregiao <- raster("/Users/marlucescarabello/Documents/GitHub/TEEB/dados/processados/mesorregioes_BR_albers_100m.tif"); mesoregiao;
cenario1 <- raster("/Users/marlucescarabello/Documents/GitHub/TEEB/resultados_alocacaorpd/S1_2030_restaurado_vfinal.tif"); cenario1;
cenario2 <- raster("/Users/marlucescarabello/Documents/GitHub/TEEB/resultados_alocacaorpd/S2_2030_restaurado_vfinal.tif"); cenario2;


bss <- blockSize(mesoregiao); bss$n

for (i in 1:bss$n) {
  x <- data.frame(idcar_imaflora = getValues(idcar_imaflora, row = bss$row[i], nrows = bss$nrows[i]),
                  mesoregiao = getValues(mesoregiao, row = bss$row[i], nrows = bss$nrows[i]),                  
                  cenario1 = getValues(cenario1, row = bss$row[i], nrows = bss$nrows[i]),
                  cenario2 = getValues(cenario2, row = bss$row[i], nrows = bss$nrows[i]))
  
  
  x <- x %>%
    group_by(mesoregiao,idcar_imaflora, cenario1,cenario2) %>%
    summarise(area_ha = n()*1.0) %>% as_tibble()  ## 100 x 100
  
  dbWriteTable(connec_local, 'teeb_cpixels_cenarios_rpdalocada_vfinal', x, row.names = F, append = T)
  
  cat('Escrito i = ', i)
  
  
}



dbDisconnect(connec_local)

## check - cenário 1
check_results_cen1 <- dbGetQuery(connec_local , "SELECT * FROM teeb_projections.check_resultados_rpdalocada_cen1")

pdrecuperada <- check_results_cen1[which(check_results_cen1$cenario1 == '300' | check_results_cen1$cenario1 == '3000'),]
sum(pdrecuperada$area_cen1)/1000000

pdrecuperada <- check_results_cen1[which(check_results_cen1$cenario1 == '100' | check_results_cen1$cenario1 == '1000'),]
sum(pdrecuperada$area_cen1)/1000000


pdrecuperada <- check_results_cen1[which(check_results_cen1$cenario1 == '3' | check_results_cen1$cenario1 == '11' | check_results_cen1$cenario1 == '13'),]
sum(pdrecuperada$area_cen1)/1000000

pdrecuperada <- check_results_cen1[which(check_results_cen1$cenario1 == '3' | check_results_cen1$cenario1 == '11' | check_results_cen1$cenario1 == '13'),]
sum(pdrecuperada$area_cen1)/1000000



pdrecuperada <- check_results_cen1[which(check_results_cen1$cenario1 == '100' | check_results_cen1$cenario1 == '1000' |
                                           check_results_cen1$cenario1 == '300' | check_results_cen1$cenario1 == '3000'),]
sum(pdrecuperada$area_cen1)/1000000

## check - cenário 2
check_results_cen2 <- dbGetQuery(connec_local , "SELECT * FROM teeb_projections.check_resultados_rpdalocada_cen2")

pdrecuperada <- check_results_cen2[which(check_results_cen2$cenario2 == '300' | check_results_cen2$cenario2 == '3000'),]
sum(pdrecuperada$area_cen2)/1000000

pdrecuperada <- check_results_cen2[which(check_results_cen2$cenario2 == '200' | check_results_cen2$cenario2 == '2000'),]
sum(pdrecuperada$area_cen2)/1000000

pdrecuperada <- check_results_cen2[which(check_results_cen2$cenario2 == '100' | check_results_cen2$cenario2 == '1000'),]
sum(pdrecuperada$area_cen2)/1000000

pdrecuperada <- check_results_cen2[which(check_results_cen2$cenario2 == '200' | check_results_cen2$cenario2 == '2000' |
                                           check_results_cen2$cenario2 == '300' | check_results_cen2$cenario2 == '3000'),]
sum(pdrecuperada$area_cen2)/1000000

pdrecuperada <- check_results_cen2[which(check_results_cen2$cenario2 == '100' | check_results_cen2$cenario2 == '1000' |
                                           check_results_cen2$cenario2 == '300' | check_results_cen2$cenario2 == '3000'|
                                           check_results_cen2$cenario2 == '200' | check_results_cen2$cenario2 == '2000'),]
sum(pdrecuperada$area_cen2)/1000000
