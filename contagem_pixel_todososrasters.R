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
uso1985aju <- raster("pa_br_usoterra_mapbiomas7_lapig_100m_1985_albers_corrigido.tif"); uso1985aju;
uso2010aju <- raster("pa_br_usoterra_mapbiomas7_lapig_100m_2010_albers_corrigido.tif"); uso2010aju;
uso2020aju <- raster("pa_br_usoterra_mapbiomas7_lapig_100m_2020_albers_corrigido.tif"); uso2020aju;
uso2021aju <- raster("pa_br_usoterra_mapbiomas7_lapig_100m_2021_albers_corrigido.tif"); uso2021aju;

uso1985ori <- raster("pa_br_usoterra_mapbiomas7_100m_1985_albers.tif"); uso1985ori;
uso2010ori <- raster("pa_br_usoterra_mapbiomas7_100m_2010_albers.tif"); uso2010ori;
uso2020ori <- raster("pa_br_usoterra_mapbiomas7_100m_2020_albers.tif"); uso2020ori;
uso2021ori <- raster("pa_br_usoterra_mapbiomas7_100m_2021_albers.tif"); uso2021ori;

past1985ori <- raster("pa_br_pastagem_lapig_100m_1985_albers_corrigido.tif"); past1985ori;
past2010ori <- raster("pa_br_pastagem_lapig_100m_2010_albers_corrigido.tif"); past2010ori;
past2020ori <- raster("pa_br_pastagem_lapig_100m_2020_albers_corrigido.tif"); past2020ori;
past2021ori <- raster("pa_br_pastagem_lapig_100m_2021_albers_corrigido.tif"); past2021ori;

qpast2010ori <- raster("pa_br_qualpastagem_lapig_100m_2010_albers.tif"); qpast2010ori;
qpast2020ori <- raster("pa_br_qualpastagem_lapig_100m_2020_albers.tif"); qpast2020ori;


# Preparando loop das variaveis
bss <- blockSize(municipios); bss$n

y <- data.frame(municipios = NA, uso1985aju = NA, uso2010aju = NA, uso2020aju = NA,uso2021aju = NA, 
                uso1985ori = NA, uso2010ori = NA, uso2020ori = NA, uso2021ori = NA, 
                past1985ori = NA, past2010ori = NA, past2020ori = NA, past2021ori = NA, 
                qpast2010ori = NA, qpast2020ori = NA, area_ha = NA)

system.time(for (i in 1:bss$n) {
  dt <- data.table(municipios = getValues(municipios, row = bss$row[i], nrows = bss$nrows[i]),
                   uso1985aju = getValues(uso1985aju, row = bss$row[i], nrows = bss$nrows[i]),
                   uso2010aju = getValues(uso2010aju, row = bss$row[i], nrows = bss$nrows[i]),
                   uso2020aju = getValues(uso2020aju, row = bss$row[i], nrows = bss$nrows[i]),
                   uso2021aju = getValues(uso2021aju, row = bss$row[i], nrows = bss$nrows[i]),
                   uso1985ori = getValues(uso1985ori, row = bss$row[i], nrows = bss$nrows[i]),
                   uso2010ori = getValues(uso2010ori, row = bss$row[i], nrows = bss$nrows[i]),
                   uso2020ori = getValues(uso2020ori, row = bss$row[i], nrows = bss$nrows[i]),
                   uso2021ori = getValues(uso2021ori, row = bss$row[i], nrows = bss$nrows[i]),
                   past1985ori = getValues(past1985ori, row = bss$row[i], nrows = bss$nrows[i]),
                   past2010ori = getValues(past2010ori, row = bss$row[i], nrows = bss$nrows[i]),
                   past2020ori = getValues(past2020ori, row = bss$row[i], nrows = bss$nrows[i]),
                   past2021ori = getValues(past2021ori, row = bss$row[i], nrows = bss$nrows[i]),
                   qpast2010ori = getValues(qpast2010ori, row = bss$row[i], nrows = bss$nrows[i]),
                   qpast2020ori = getValues(qpast2020ori, row = bss$row[i], nrows = bss$nrows[i])   
  )
  
  x <- dt %>%
    group_by(municipios,uso1985aju,uso2010aju,uso2020aju,uso2021aju,uso1985ori,uso2010ori,uso2020ori,uso2021ori,
             past1985ori,past2010ori,past2020ori,past2021ori,qpast2010ori,qpast2020ori) %>%
    summarise(area_ha = n()*1.0) %>% as_tibble()
  
  rm(dt)
  
  y <- rbind(y,x)
  
  rm(x)
  print(i)
})


write.table(y,"contagem_pixel_todososrasters.csv",row.names = F, sep = ",")

y_uso1985aju <- y %>% 
  filter(!is.na(municipios))%>% 
  mutate(classe = ifelse(uso1985aju %in% c(15), 'Pastagem',
                         ifelse(uso1985aju %in% c(20, 39, 40, 41, 46, 47, 48, 62), 'Agricultura',
                                ifelse(uso1985aju %in% c(9), 'Silvicultura',
                                       ifelse(uso1985aju %in% c(21), 'Mosaico',
                                              ifelse(uso1985aju  %in% c(3, 4, 5, 11, 13, 49, 50), 'Vegetacao Nativa',
                                                     ifelse(uso1985aju  %in% c(0, 12, 23, 24, 25, 29, 30, 31, 32, 33), 'Outros','ERRO'))))))) %>%
  
  group_by(classe) %>% 
  summarise(area_final = sum(area_ha/1000,na.rm = TRUE))

y_uso1985aju

y_uso2010aju <- y %>% 
  filter(!is.na(municipios))%>% 
  mutate(classe = ifelse(uso2010aju %in% c(15), 'Pastagem',
                         ifelse(uso2010aju %in% c(20, 39, 40, 41, 46, 47, 48, 62), 'Agricultura',
                                ifelse(uso2010aju %in% c(9), 'Silvicultura',
                                       ifelse(uso2010aju %in% c(21), 'Mosaico',
                                              ifelse(uso2010aju  %in% c(3, 4, 5, 11, 13, 49, 50), 'Vegetacao Nativa',
                                                     ifelse(uso2010aju  %in% c(0, 12, 23, 24, 25, 29, 30, 31, 32, 33), 'Outros','ERRO'))))))) %>%
  
  group_by(classe) %>% 
  summarise(area_final = sum(area_ha/1000,na.rm = TRUE))

y_uso2010aju

y_uso2020aju <- y %>% 
  filter(!is.na(municipios))%>% 
  mutate(classe = ifelse(uso2020aju %in% c(15), 'Pastagem',
                         ifelse(uso2020aju %in% c(20, 39, 40, 41, 46, 47, 48, 62), 'Agricultura',
                                ifelse(uso2020aju %in% c(9), 'Silvicultura',
                                       ifelse(uso2020aju %in% c(21), 'Mosaico',
                                              ifelse(uso2020aju  %in% c(3, 4, 5, 11, 13, 49, 50), 'Vegetacao Nativa',
                                                     ifelse(uso2020aju  %in% c(0, 12, 23, 24, 25, 29, 30, 31, 32, 33), 'Outros','ERRO'))))))) %>%
  
  group_by(classe) %>% 
  summarise(area_final = sum(area_ha/1000,na.rm = TRUE))

y_uso2020aju

y_uso2021aju <- y %>% 
  filter(!is.na(municipios))%>% 
  mutate(classe = ifelse(uso2021aju %in% c(15), 'Pastagem',
                         ifelse(uso2021aju %in% c(20, 39, 40, 41, 46, 47, 48, 62), 'Agricultura',
                                ifelse(uso2021aju %in% c(9), 'Silvicultura',
                                       ifelse(uso2021aju %in% c(21), 'Mosaico',
                                              ifelse(uso2021aju  %in% c(3, 4, 5, 11, 13, 49, 50), 'Vegetacao Nativa',
                                                     ifelse(uso2021aju  %in% c(0, 12, 23, 24, 25, 29, 30, 31, 32, 33), 'Outros','ERRO'))))))) %>%
  
  group_by(classe) %>% 
  summarise(area_final = sum(area_ha/1000,na.rm = TRUE))

y_uso2021aju

y_uso1985ori <- y %>% 
  filter(!is.na(municipios))%>% 
  mutate(classe = ifelse(uso1985ori %in% c(15), 'Pastagem',
                         ifelse(uso1985ori %in% c(20, 39, 40, 41, 46, 47, 48, 62), 'Agricultura',
                                ifelse(uso1985ori %in% c(9), 'Silvicultura',
                                       ifelse(uso1985ori %in% c(21), 'Mosaico',
                                              ifelse(uso1985ori  %in% c(3, 4, 5, 11, 13, 49, 50), 'Vegetacao Nativa',
                                                     ifelse(uso1985ori  %in% c(0, 12, 23, 24, 25, 29, 30, 31, 32, 33), 'Outros','ERRO'))))))) %>%
  
  group_by(classe) %>% 
  summarise(area_final = sum(area_ha/1000,na.rm = TRUE))

y_uso1985ori

y_uso2010ori <- y %>% 
  filter(!is.na(municipios))%>% 
  mutate(classe = ifelse(uso2010ori %in% c(15), 'Pastagem',
                         ifelse(uso2010ori %in% c(20, 39, 40, 41, 46, 47, 48, 62), 'Agricultura',
                                ifelse(uso2010ori %in% c(9), 'Silvicultura',
                                       ifelse(uso2010ori %in% c(21), 'Mosaico',
                                              ifelse(uso2010ori  %in% c(3, 4, 5, 11, 13, 49, 50), 'Vegetacao Nativa',
                                                     ifelse(uso2010ori  %in% c(0, 12, 23, 24, 25, 29, 30, 31, 32, 33), 'Outros','ERRO'))))))) %>%
  
  group_by(classe) %>% 
  summarise(area_final = sum(area_ha/1000,na.rm = TRUE))

y_uso2010ori

y_uso2020ori <- y %>% 
  filter(!is.na(municipios))%>% 
  mutate(classe = ifelse(uso2020ori %in% c(15), 'Pastagem',
                         ifelse(uso2020ori %in% c(20, 39, 40, 41, 46, 47, 48, 62), 'Agricultura',
                                ifelse(uso2020ori %in% c(9), 'Silvicultura',
                                       ifelse(uso2020ori %in% c(21), 'Mosaico',
                                              ifelse(uso2020ori  %in% c(3, 4, 5, 11, 13, 49, 50), 'Vegetacao Nativa',
                                                     ifelse(uso2020ori  %in% c(0, 12, 23, 24, 25, 29, 30, 31, 32, 33), 'Outros','ERRO'))))))) %>%
  
  group_by(classe) %>% 
  summarise(area_final = sum(area_ha/1000,na.rm = TRUE))

y_uso2020ori

y_uso2021ori <- y %>% 
  filter(!is.na(municipios))%>% 
  mutate(classe = ifelse(uso2021ori %in% c(15), 'Pastagem',
                         ifelse(uso2021ori %in% c(20, 39, 40, 41, 46, 47, 48, 62), 'Agricultura',
                                ifelse(uso2021ori %in% c(9), 'Silvicultura',
                                       ifelse(uso2021ori %in% c(21), 'Mosaico',
                                              ifelse(uso2021ori  %in% c(3, 4, 5, 11, 13, 49, 50), 'Vegetacao Nativa',
                                                     ifelse(uso2021ori  %in% c(0, 12, 23, 24, 25, 29, 30, 31, 32, 33), 'Outros','ERRO'))))))) %>%
  
  group_by(classe) %>% 
  summarise(area_final = sum(area_ha/1000,na.rm = TRUE))

y_uso2021ori

y_past1985ori <- y %>% 
  filter(!is.na(municipios))%>% 
  mutate(classe = ifelse(past1985ori %in% c(1), 'Pastagem',0)) %>%
  group_by(classe) %>% 
  summarise(area_final = sum(area_ha/1000,na.rm = TRUE))

y_past1985ori

y_past2010ori <- y %>% 
  filter(!is.na(municipios))%>% 
  mutate(classe = ifelse(past2010ori %in% c(1), 'Pastagem',0)) %>%
  group_by(classe) %>% 
  summarise(area_final = sum(area_ha/1000,na.rm = TRUE))

y_past2010ori

y_past2020ori <- y %>% 
  filter(!is.na(municipios))%>% 
  mutate(classe = ifelse(past2020ori %in% c(1), 'Pastagem',0)) %>%
  group_by(classe) %>% 
  summarise(area_final = sum(area_ha/1000,na.rm = TRUE))

y_past2020ori

y_past2021ori <- y %>% 
  filter(!is.na(municipios))%>% 
  mutate(classe = ifelse(past2021ori %in% c(1), 'Pastagem',0)) %>%
  group_by(classe) %>% 
  summarise(area_final = sum(area_ha/1000,na.rm = TRUE))

y_past2021ori

y_qpast2010ori <- y %>% 
  filter(!is.na(municipios))%>% 
  mutate(classe = ifelse(qpast2010ori %in% c(1), 'Severa',
                         ifelse(qpast2010ori %in% c(2), 'Inter',
                                ifelse(qpast2010ori %in% c(3), 'Ausente','ERRO')))) %>%
  
  group_by(classe) %>% 
  summarise(area_final = sum(area_ha/1000,na.rm = TRUE))

y_qpast2010ori

y_qpast2020ori <- y %>% 
  filter(!is.na(municipios))%>% 
  mutate(classe = ifelse(qpast2020ori %in% c(1), 'Severa',
                         ifelse(qpast2020ori %in% c(2), 'Inter',
                                ifelse(qpast2020ori %in% c(3), 'Ausente','ERRO')))) %>%
  
  group_by(classe) %>% 
  summarise(area_final = sum(area_ha/1000,na.rm = TRUE))

y_qpast2020ori

