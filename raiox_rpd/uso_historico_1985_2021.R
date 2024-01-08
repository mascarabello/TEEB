#########################################################
# Analise historico
# Marluce Scarabello
#########################################################

# Variaveis dinamicas
# Limpando a area de trabalho
rm(list = ls())

# Instalando pacotes e lendo os dados
library(pacman)
p_load(raster, data.table, dplyr, tidyr,RPostgreSQL)

setwd("/Users/marlucescarabello/Dropbox/Work/GPP/Teeb/P4_adicional/rasters")

municipios <- raster("municipios_albers.tif"); municipios; 
uso1985 <- raster("pa_br_usoterra_mapbiomas7_lapig_100m_1985_albers_corrigido.tif"); uso1985;
uso1986 <- raster("pa_br_usoterra_mapbiomas7_lapig_100m_1986_albers_corrigido.tif"); uso1986;
uso1990 <- raster("pa_br_usoterra_mapbiomas7_lapig_100m_1990_albers_corrigido.tif"); uso1990;
uso1995 <- raster("pa_br_usoterra_mapbiomas7_lapig_100m_1995_albers_corrigido.tif"); uso1995;
uso2000 <- raster("pa_br_usoterra_mapbiomas7_lapig_100m_2000_albers_corrigido.tif"); uso2000;
uso2005 <- raster("pa_br_usoterra_mapbiomas7_lapig_100m_2005_albers_corrigido.tif"); uso2005;
uso2010 <- raster("pa_br_usoterra_mapbiomas7_lapig_100m_2010_albers_corrigido.tif"); uso2010;
uso2015 <- raster("pa_br_usoterra_mapbiomas7_lapig_100m_2015_albers_corrigido.tif"); uso2015;
uso2018 <- raster("pa_br_usoterra_mapbiomas7_lapig_100m_2018_albers_corrigido.tif"); uso2018;
uso2019 <- raster("pa_br_usoterra_mapbiomas7_lapig_100m_2019_albers_corrigido.tif"); uso2019;
uso2020 <- raster("pa_br_usoterra_mapbiomas7_lapig_100m_2020_albers_corrigido.tif"); uso2020;
uso2021 <- raster("pa_br_usoterra_mapbiomas7_lapig_100m_2021_albers_corrigido.tif"); uso2021;



# Preparando loop das variaveis
bss <- blockSize(municipios); bss$n


y <- data.frame(municipios = NA, pastagem = NA, agricultura = NA, usoanterior = NA, area_ha = NA)
system.time(for (i in 1:bss$n) {
  dt <- data.table(municipios = getValues(municipios, row = bss$row[i], nrows = bss$nrows[i]),
                   uso1985 = getValues(uso1985, row = bss$row[i], nrows = bss$nrows[i]),
                   uso1986 = getValues(uso1986, row = bss$row[i], nrows = bss$nrows[i]),
                   uso1990 = getValues(uso1990, row = bss$row[i], nrows = bss$nrows[i]),
                   uso1995 = getValues(uso1995, row = bss$row[i], nrows = bss$nrows[i]),                   
                   uso2000 = getValues(uso2000, row = bss$row[i], nrows = bss$nrows[i]),
                   uso2005 = getValues(uso2005, row = bss$row[i], nrows = bss$nrows[i]),
                   uso2010 = getValues(uso2010, row = bss$row[i], nrows = bss$nrows[i]),
                   uso2015 = getValues(uso2015, row = bss$row[i], nrows = bss$nrows[i]),
                   uso2018 = getValues(uso2018, row = bss$row[i], nrows = bss$nrows[i]),
                   uso2019 = getValues(uso2019, row = bss$row[i], nrows = bss$nrows[i]),
                   uso2020 = getValues(uso2020, row = bss$row[i], nrows = bss$nrows[i]),                   
                   uso2021 = getValues(uso2021, row = bss$row[i], nrows = bss$nrows[i])   
  )
  
  dt$pastagem <- ifelse(dt$uso2021 %in% c(15), dt$uso1985,1000)
  dt$agricultura <- ifelse(dt$uso2021 %in% c(20, 39, 40, 41, 46, 47, 48, 62), dt$uso1985,1000)
  dt$usoanterior <- ifelse(dt$uso2021 %in% c(20, 39, 40, 41, 46, 47, 48, 62) & dt$uso1985 %in% c(3, 4, 5, 11, 13, 49, 50) &
                    (dt$uso1986 == 15 | dt$uso1990 == 15 | dt$uso1995 == 15 | dt$uso2000 == 15 |  dt$uso2005 == 15 | dt$uso2010 == 15| dt$uso2015 == 15| dt$uso2018 == 15 | dt$uso2019 == 15 | dt$uso2020 == 15), 1,1000)  
  
  x <- dt %>%
    group_by(municipios,pastagem,agricultura,usoanterior) %>%
    summarise(area_ha = n()*1.0) %>% as_tibble()
 
   rm(dt)
  
  y <- rbind(y,x)
  
  rm(x)
  print(i)
})
  
## aqui confere
y1<- y
rm(y)

y1$cd_uf <- substr(y1$municipios,1,2)

y1 <- y1 %>%    
  group_by(cd_uf,pastagem,agricultura,usoanterior) %>%
  summarise(area_ha_es = sum(area_ha,rm=FALSE)) %>% as_tibble()

write.table(y1, "/Users/marlucescarabello/Dropbox/Work/GPP/Teeb/P4_adicional/tabelas/output/uso_hist_1985_2021_contagemano.csv",row.names = F, sep = ";")

sum(y1$usoanterior,na.rm = true)

y_final_usoanterior <- y1 %>% filter(!is.na(cd_uf))%>%  
  mutate(classe = ifelse(usoanterior %in% c(1), 'Pastagem','NAO')) %>%
  group_by(classe) %>%  summarise(area_final = sum(area_ha_es,na.rm = TRUE))

y_final_usoanterior

y_final_usoanterior2018 <- y1 %>% 
  filter(!is.na(cd_uf))%>% 
  mutate(classe = ifelse(usoanterior2018 %in% c(15), 'Pastagem',
                           ifelse(usoanterior2018 %in% c(20, 39, 40, 41, 46, 47, 48, 62), 'Agricultura',
                                  ifelse(usoanterior2018 %in% c(9), 'Silvicultura',
                                         ifelse(usoanterior2018 %in% c(21), 'Mosaico',
                                                ifelse(usoanterior2018  %in% c(3, 4, 5, 11, 13, 49, 50), 'Vegetacao Nativa',
                                                      ifelse(usoanterior2018  %in% c(0, 12, 23, 24, 25, 29, 30, 31, 32, 33),'Outros',
                                                             ifelse(usoanterior2018  %in% c(1000), 'NAO','ERRO')))))))) %>%
  
  group_by(classe) %>% 
  summarise(area_final = sum(area_ha_es,na.rm = TRUE))
y_final_usoanterior2018



y_final_pastagem <- y1 %>% 
  filter(!is.na(cd_uf))%>% 
  mutate(classe = ifelse(pastagem %in% c(15), 'Pastagem',
                           ifelse(pastagem %in% c(20, 39, 40, 41, 46, 47, 48, 62), 'Agricultura',
                                  ifelse(pastagem %in% c(9), 'Silvicultura',
                                         ifelse(pastagem %in% c(21), 'Mosaico',
                                                ifelse(pastagem  %in% c(3, 4, 5, 11, 13, 49, 50), 'Vegetacao Nativa',
                                                      ifelse(pastagem  %in% c(0, 12, 23, 24, 25, 29, 30, 31, 32, 33),'Outros',
                                                             ifelse(pastagem  %in% c(1000), 'NAO','ERRO')))))))) %>%
  
  group_by(classe) %>% 
  summarise(area_final = sum(area_ha_es,na.rm = TRUE))
y_final_pastagem

y_final_pastagem1 <- y_final_pastagem %>%  filter(classe != 'NAO')
  
write.table(y_final_pastagem1, "/Users/marlucescarabello/Dropbox/Work/GPP/Teeb/P4_adicional/tabelas/output/uso_hist_1985_2021_pastagem_clean.csv",row.names = F, sep = ";")
  

y_final_agricultura <- y1 %>% 
  filter(!is.na(cd_uf))%>% 
  mutate(classe = ifelse(agricultura %in% c(15), 'Pastagem',
                         ifelse(agricultura %in% c(20, 39, 40, 41, 46, 47, 48, 62), 'Agricultura',
                                ifelse(agricultura %in% c(9), 'Silvicultura',
                                       ifelse(agricultura %in% c(21), 'Mosaico',
                                              ifelse(agricultura  %in% c(3, 4, 5, 11, 13, 49, 50), 'Vegetacao Nativa',
                                                     ifelse(agricultura  %in% c(0, 12, 23, 24, 25, 29, 30, 31, 32, 33), 'Outros',
                                                         ifelse(agricultura  %in% c(1000), 'NAO','ERRO')))))))) %>%
  
  group_by(classe) %>% 
  summarise(area_final = sum(area_ha_es,na.rm = TRUE))

y_final_agricultura

write.table(y_final_agricultura, "/Users/marlucescarabello/Dropbox/Work/GPP/Teeb/P4_adicional/tabelas/output/uso_hist_1985_2021_agricultura.csv",row.names = F, sep = ";")

y_final_agricultura1 <- y_final_agricultura %>%  filter(classe != 'NAO')

write.table(y_final_agricultura1, "/Users/marlucescarabello/Dropbox/Work/GPP/Teeb/P4_adicional/tabelas/output/uso_hist_1985_2021_agricultura_clean.csv",row.names = F, sep = ";")


# Gerar mapa pixel para avaliar -------------------------------------------

#Que era pastagem
rm(list = ls())

# Reading data
library(pacman)
p_load(raster, data.table, rgdal, sf, terra)

setwd("/Users/marlucescarabello/Dropbox/Work/GPP/Teeb/P4_adicional/rasters")

## 1985
uso1985 <- raster("pa_br_usoterra_mapbiomas7_lapig_100m_1985_albers_corrigido.tif"); uso1985;
uso2021 <- raster("pa_br_usoterra_mapbiomas7_lapig_100m_2021_albers_corrigido.tif"); uso2021;
out <- raster("pa_br_usoterra_mapbiomas7_lapig_100m_1985_albers_corrigido.tif")

# Marking pasture pixels in LAPIG as pasture in MAPBIOMAS
bss <- blockSize(uso1985)
bss
lap <- readStart(uso2021)
uso1985 <- readStart(uso1985)
out <- readStart(out)
#out <- writeStart(out, filename = "pa_br_usoterra_mapbiomas7_lapig_100m_2010_albers.tif",format = 'Gtiff',overwrite=TRUE)
out <- writeStart(out, filename = "reclassificacao_agri/pa_br_usoterra_mapbiomas7_lapig_100m_1985_albers_corrigido_pastatual.tif",format = 'Gtiff',overwrite=TRUE,options=c("COMPRESS=DEFLATE","ZLEVEL=9","PREDICTOR=2","TFW=YES"))


for(i in 1:bss$n) {
  x <- getValues(uso2021, row = bss$row[i], nrows = bss$nrows[i])
  y <- getValues(uso1985, row = bss$row[i], nrows = bss$nrows[i])
  y[x[] != 15] = 1000
  out <- writeValues(out, y,  bss$row[i])
  print(i)
}

uso2021 <- readStop(uso2021)
uso1985 <- readStop(uso1985)
out <- writeStop(out)


#Que era agricultura
rm(list = ls())

# Reading data
library(pacman)
p_load(raster, data.table, rgdal, sf, terra)

setwd("/Users/marlucescarabello/Dropbox/Work/GPP/Teeb/P4_adicional/rasters")

## 1985
uso1985 <- raster("pa_br_usoterra_mapbiomas7_lapig_100m_1985_albers_corrigido.tif"); uso1985;
uso2021 <- raster("pa_br_usoterra_mapbiomas7_lapig_100m_2021_albers_corrigido.tif"); uso2021;
out <- raster("pa_br_usoterra_mapbiomas7_lapig_100m_1985_albers_corrigido.tif")

# Marking pasture pixels in LAPIG as pasture in MAPBIOMAS
bss <- blockSize(uso1985)
bss
lap <- readStart(uso2021)
uso1985 <- readStart(uso1985)
out <- readStart(out)
#out <- writeStart(out, filename = "pa_br_usoterra_mapbiomas7_lapig_100m_2010_albers.tif",format = 'Gtiff',overwrite=TRUE)
out <- writeStart(out, filename = "reclassificacao_agri/pa_br_usoterra_mapbiomas7_lapig_100m_1985_albers_corrigido_agriatual.tif",format = 'Gtiff',overwrite=TRUE,options=c("COMPRESS=DEFLATE","ZLEVEL=9","PREDICTOR=2","TFW=YES"))


for(i in 1:bss$n) {
  x <- getValues(uso2021, row = bss$row[i], nrows = bss$nrows[i])
  y <- getValues(uso1985, row = bss$row[i], nrows = bss$nrows[i])
  y[x[] %in% c(15, 3, 4, 5, 11, 13, 49, 50,0, 12, 23, 24, 25, 29, 30, 31, 32, 33,21,9)] = 1000
  out <- writeValues(out, y,  bss$row[i])
  print(i)
}

uso2021 <- readStop(uso2021)
uso1985 <- readStop(uso1985)
out <- writeStop(out)
