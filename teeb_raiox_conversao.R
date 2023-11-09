#########################################################
# Extração de variaveis por propriedade - analise cpd
# Marluce Scarabello
#########################################################

# Variaveis dinamicas
# Limpando a area de trabalho
rm(list = ls())

# Instalando pacotes e lendo os dados
library(pacman)
p_load(raster, data.table, dplyr, tidyr,RPostgreSQL)

setwd("/Users/marlucescarabello/Dropbox/Work/GPP/Teeb/P4_adicional/rasters")

idcar_imaflora <- raster("pa_br_malhafundiaria_imaflora_imovel_100m.tif"); idcar_imaflora;
municipios <- raster("municipios_albers.tif"); municipios; 
pastagem_2009 <- raster("pa_br_qualpastagem_lapig_100m_2009_albers.tif"); pastagem_2009;
pastagem_2010 <- raster("pa_br_qualpastagem_lapig_100m_2010_albers.tif"); pastagem_2010;
pastagem_2011 <- raster("pa_br_qualpastagem_lapig_100m_2011_albers.tif"); pastagem_2011;
pastagem_2012 <- raster("pa_br_qualpastagem_lapig_100m_2012_albers.tif"); pastagem_2012;
pastagem_2013 <- raster("pa_br_qualpastagem_lapig_100m_2013_albers.tif"); pastagem_2013;
pastagem_2014 <- raster("pa_br_qualpastagem_lapig_100m_2014_albers.tif"); pastagem_2014;
pastagem_2015 <- raster("pa_br_qualpastagem_lapig_100m_2015_albers.tif"); pastagem_2015;
pastagem_2016 <- raster("pa_br_qualpastagem_lapig_100m_2016_albers.tif"); pastagem_2016;
pastagem_2017 <- raster("pa_br_qualpastagem_lapig_100m_2017_albers.tif"); pastagem_2017;
pastagem_2018 <- raster("pa_br_qualpastagem_lapig_100m_2018_albers.tif"); pastagem_2018;
pastagem_2019 <- raster("pa_br_qualpastagem_lapig_100m_2019_albers.tif"); pastagem_2019;
pastagem_2020 <- raster("pa_br_qualpastagem_lapig_100m_2020_albers.tif"); pastagem_2020;
uso2009 <- raster("pa_br_usoterra_mapbiomas7_100m_2009_albers.tif"); uso2009;
uso2010 <- raster("pa_br_usoterra_mapbiomas7_100m_2010_albers.tif"); uso2010;
uso2011 <- raster("pa_br_usoterra_mapbiomas7_100m_2011_albers.tif"); uso2011;
uso2012 <- raster("pa_br_usoterra_mapbiomas7_100m_2012_albers.tif"); uso2012;
uso2013 <- raster("pa_br_usoterra_mapbiomas7_100m_2013_albers.tif"); uso2013;
uso2014 <- raster("pa_br_usoterra_mapbiomas7_100m_2014_albers.tif"); uso2014;
uso2015 <- raster("pa_br_usoterra_mapbiomas7_100m_2015_albers.tif"); uso2015;
uso2016 <- raster("pa_br_usoterra_mapbiomas7_100m_2016_albers.tif"); uso2016;
uso2017 <- raster("pa_br_usoterra_mapbiomas7_100m_2017_albers.tif"); uso2017;
uso2018 <- raster("pa_br_usoterra_mapbiomas7_100m_2018_albers.tif"); uso2018;
uso2019 <- raster("pa_br_usoterra_mapbiomas7_100m_2019_albers.tif"); uso2019;
uso2020 <- raster("pa_br_usoterra_mapbiomas7_100m_2020_albers.tif"); uso2020;



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

# Criando a tabela de saída no banco 
# Função para executar a consulta
executeQuery <- function(connec_local, query) {
  result <- tryCatch({
    dbExecute(connec_local, query)  # Usamos dbExecute ao invés de dbSendQuery
  }, error = function(e) {
    dbRollback(connec_local)  # Em caso de erro, desfaz qualquer mudança no banco
    stop(e)
  })
  return(result)
}

# Inicia uma transação
dbBegin(connec_local)


drop_table <- "DROP TABLE IF EXISTS public.teeb_raiox_conversao_final"
executeQuery(connec_local, drop_table)

createTableQuery <-  
  "CREATE TABLE public.teeb_raiox_conversao_final (

id serial4 NOT NULL,
idcar_imaflora integer NULL,
municipios integer NULL,
pcd1011 float8 null,
pcd1112 float8 null,
pcd1213 float8 null,
pcd1314 float8 null,
pcd1415 float8 null,
pcd1516 float8 null,
pcd1617 float8 null,
pcd1718 float8 null,
pcd1819 float8 null,
pcc1011 float8 null,
pcc1112 float8 null,
pcc1213 float8 null,
pcc1314 float8 null,
pcc1415 float8 null,
pcc1516 float8 null,
pcc1617 float8 null,
pcc1718 float8 null,
pcc1819 float8 null,
cpd0910 float8 null,
cpd1011 float8 null,
cpd1112 float8 null,
cpd1213 float8 null,
cpd1314 float8 null,
cpd1415 float8 null,
cpd1516 float8 null,
cpd1617 float8 null,
cpd1718 float8 null,
cpd1819 float8 null,
cpd1920 float8 null,
cpd1020 float8 null,
cpd1015 float8 null,
cpd1520 float8 null,
pd0910 float8 null,
pd1011 float8 null,
pd1112 float8 null,
pd1213 float8 null,
pd1314 float8 null,
pd1415 float8 null,
pd1516 float8 null,
pd1617 float8 null,
pd1718 float8 null,
pd1819 float8 null,
pd1920 float8 null,
pd1020 float8 null,
pd1015 float8 null,
pd1520 float8 null,
area_ha float8 NULL
);"

executeQuery(connec_local, createTableQuery)



# Criando índices
indexQueries <- c(
  "CREATE INDEX teeb_raiox_conversao_final_id_idx ON public.teeb_raiox_conversao_final USING btree (id)",
  "CREATE INDEX teeb_raiox_conversao_final_idcar_imaflora_idx ON public.teeb_raiox_conversao_final USING btree (idcar_imaflora)",
  "CREATE INDEX teeb_raiox_conversao_final_municipios_idx ON public.teeb_raiox_conversao_final USING btree (municipios)")


for (indexQuery in indexQueries) {
  executeQuery(connec_local, indexQuery)
}


# Finaliza a transação
dbCommit(connec_local)


bss <- blockSize(municipios); bss$n

system.time(for (i in 1:bss$n) {
  dt <- data.table(idcar_imaflora = getValues(idcar_imaflora, row = bss$row[i], nrows = bss$nrows[i]),
                   municipios = getValues(municipios, row = bss$row[i], nrows = bss$nrows[i]),
                   pastagem_2009 = getValues(pastagem_2009, row = bss$row[i], nrows = bss$nrows[i]),
                   pastagem_2010 = getValues(pastagem_2010, row = bss$row[i], nrows = bss$nrows[i]),
                   pastagem_2011 = getValues(pastagem_2011, row = bss$row[i], nrows = bss$nrows[i]),
                   pastagem_2012 = getValues(pastagem_2012, row = bss$row[i], nrows = bss$nrows[i]),
                   pastagem_2013 = getValues(pastagem_2013, row = bss$row[i], nrows = bss$nrows[i]),
                   pastagem_2014 = getValues(pastagem_2014, row = bss$row[i], nrows = bss$nrows[i]),
                   pastagem_2015 = getValues(pastagem_2015, row = bss$row[i], nrows = bss$nrows[i]),
                   pastagem_2016 = getValues(pastagem_2016, row = bss$row[i], nrows = bss$nrows[i]),
                   pastagem_2017 = getValues(pastagem_2017, row = bss$row[i], nrows = bss$nrows[i]),
                   pastagem_2018 = getValues(pastagem_2018, row = bss$row[i], nrows = bss$nrows[i]),
                   pastagem_2019 = getValues(pastagem_2019, row = bss$row[i], nrows = bss$nrows[i]),
                   pastagem_2020 = getValues(pastagem_2020, row = bss$row[i], nrows = bss$nrows[i]),
                   uso2009 = getValues(uso2009, row = bss$row[i], nrows = bss$nrows[i]),
                   uso2010 = getValues(uso2010, row = bss$row[i], nrows = bss$nrows[i]),
                   uso2011 = getValues(uso2011, row = bss$row[i], nrows = bss$nrows[i]),
                   uso2012 = getValues(uso2012, row = bss$row[i], nrows = bss$nrows[i]),
                   uso2013 = getValues(uso2013, row = bss$row[i], nrows = bss$nrows[i]),
                   uso2014 = getValues(uso2014, row = bss$row[i], nrows = bss$nrows[i]),
                   uso2015 = getValues(uso2015, row = bss$row[i], nrows = bss$nrows[i]),
                   uso2016 = getValues(uso2016, row = bss$row[i], nrows = bss$nrows[i]),
                   uso2017 = getValues(uso2017, row = bss$row[i], nrows = bss$nrows[i]),
                   uso2018 = getValues(uso2018, row = bss$row[i], nrows = bss$nrows[i]),
                   uso2019 = getValues(uso2019, row = bss$row[i], nrows = bss$nrows[i]),
                   uso2020 = getValues(uso2020, row = bss$row[i], nrows = bss$nrows[i])   
  )
  
  #  dt <- subset(dt, idcar_imaflora > 0)
  
  dt$cpd0910 <- ifelse(dt$pastagem_2009 %in% c(1, 2) & dt$uso2010 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62), 1, 0)
  dt$cpd1011 <- ifelse(dt$pastagem_2010 %in% c(1, 2) & dt$uso2011 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62), 1, 0)
  dt$cpd1112 <- ifelse(dt$pastagem_2011 %in% c(1, 2) & dt$uso2012 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62), 1, 0)
  dt$cpd1213 <- ifelse(dt$pastagem_2012 %in% c(1, 2) & dt$uso2013 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62), 1, 0)
  dt$cpd1314 <- ifelse(dt$pastagem_2013 %in% c(1, 2) & dt$uso2014 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62), 1, 0)
  dt$cpd1415 <- ifelse(dt$pastagem_2014 %in% c(1, 2) & dt$uso2015 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62), 1, 0)  
  dt$cpd1516 <- ifelse(dt$pastagem_2015 %in% c(1, 2) & dt$uso2016 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62), 1, 0)
  dt$cpd1617 <- ifelse(dt$pastagem_2016 %in% c(1, 2) & dt$uso2017 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62), 1, 0)  
  dt$cpd1718 <- ifelse(dt$pastagem_2017 %in% c(1, 2) & dt$uso2018 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62), 1, 0)
  dt$cpd1819 <- ifelse(dt$pastagem_2018 %in% c(1, 2) & dt$uso2019 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62), 1, 0)  
  dt$cpd1920 <- ifelse(dt$pastagem_2019 %in% c(1, 2) & dt$uso2020 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62), 1, 0)
  dt$cpd1020 <- ifelse(dt$pastagem_2010 %in% c(1, 2) & dt$uso2020 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62), 1, 0)
  dt$cpd1015 <- ifelse(dt$pastagem_2010 %in% c(1, 2) & dt$uso2015 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62), 1, 0)
  dt$cpd1520 <- ifelse(dt$pastagem_2015 %in% c(1, 2) & dt$uso2020 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62), 1, 0)
  dt$pd0910 <- ifelse(dt$uso2009 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62) & dt$pastagem_2010 %in% c(1, 2), 1, 0)
  dt$pd1011 <- ifelse(dt$uso2010 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62) & dt$pastagem_2011 %in% c(1, 2), 1, 0)
  dt$pd1112 <- ifelse(dt$uso2011 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62) & dt$pastagem_2012 %in% c(1, 2), 1, 0)
  dt$pd1213 <- ifelse(dt$uso2012 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62) & dt$pastagem_2013 %in% c(1, 2), 1, 0)
  dt$pd1314 <- ifelse(dt$uso2013 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62) & dt$pastagem_2014 %in% c(1, 2), 1, 0)
  dt$pd1415 <- ifelse(dt$uso2014 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62) & dt$pastagem_2015 %in% c(1, 2), 1, 0)  
  dt$pd1516 <- ifelse(dt$uso2015 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62) & dt$pastagem_2016 %in% c(1, 2), 1, 0)
  dt$pd1617 <- ifelse(dt$uso2016 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62) & dt$pastagem_2017 %in% c(1, 2), 1, 0)  
  dt$pd1718 <- ifelse(dt$uso2017 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62) & dt$pastagem_2018 %in% c(1, 2), 1, 0)
  dt$pd1819 <- ifelse(dt$uso2018 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62) & dt$pastagem_2019 %in% c(1, 2), 1, 0)  
  dt$pd1920 <- ifelse(dt$uso2019 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62) & dt$pastagem_2020 %in% c(1, 2), 1, 0)
  dt$pd1020 <- ifelse(dt$uso2010 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62) & dt$pastagem_2020 %in% c(1, 2), 1, 0)
  dt$pd1015 <- ifelse(dt$uso2010 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62) & dt$pastagem_2015 %in% c(1, 2), 1, 0)
  dt$pd1520 <- ifelse(dt$uso2015 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62) & dt$pastagem_2020 %in% c(1, 2), 1, 0)

  dt$pcd1011 <- ifelse(dt$pastagem_2010 %in% c(1, 2) & dt$uso2011 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62)  & dt$pastagem_2020 %in% c(1, 2),1,0)
  dt$pcd1112 <- ifelse(dt$pastagem_2011 %in% c(1, 2) & dt$uso2012 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62)  & dt$pastagem_2020 %in% c(1, 2),1,0)
  dt$pcd1213 <- ifelse(dt$pastagem_2012 %in% c(1, 2) & dt$uso2013 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62)  & dt$pastagem_2020 %in% c(1, 2),1,0)
  dt$pcd1314 <- ifelse(dt$pastagem_2013 %in% c(1, 2) & dt$uso2014 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62)  & dt$pastagem_2020 %in% c(1, 2),1,0)
  dt$pcd1415 <- ifelse(dt$pastagem_2014 %in% c(1, 2) & dt$uso2015 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62)  & dt$pastagem_2020 %in% c(1, 2),1,0)
  dt$pcd1516 <- ifelse(dt$pastagem_2015 %in% c(1, 2) & dt$uso2016 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62)  & dt$pastagem_2020 %in% c(1, 2),1,0)
  dt$pcd1617 <- ifelse(dt$pastagem_2016 %in% c(1, 2) & dt$uso2017 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62)  & dt$pastagem_2020 %in% c(1, 2),1,0)
  dt$pcd1718 <- ifelse(dt$pastagem_2017 %in% c(1, 2) & dt$uso2018 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62)  & dt$pastagem_2020 %in% c(1, 2),1,0)
  dt$pcd1819 <- ifelse(dt$pastagem_2018 %in% c(1, 2) & dt$uso2019 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62)  & dt$pastagem_2020 %in% c(1, 2),1,0)
  
  dt$pcc1011 <- ifelse(dt$pastagem_2010 %in% c(1, 2) & dt$uso2011 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62)  & dt$uso2020 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62) ,1,0)
  dt$pcc1112 <- ifelse(dt$pastagem_2011 %in% c(1, 2) & dt$uso2012 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62)  & dt$uso2020 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62) ,1,0)
  dt$pcc1213 <- ifelse(dt$pastagem_2012 %in% c(1, 2) & dt$uso2013 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62)  & dt$uso2020 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62) ,1,0)
  dt$pcc1314 <- ifelse(dt$pastagem_2013 %in% c(1, 2) & dt$uso2014 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62)  & dt$uso2020 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62) ,1,0)
  dt$pcc1415 <- ifelse(dt$pastagem_2014 %in% c(1, 2) & dt$uso2015 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62)  & dt$uso2020 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62) ,1,0)
  dt$pcc1516 <- ifelse(dt$pastagem_2015 %in% c(1, 2) & dt$uso2016 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62)  & dt$uso2020 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62) ,1,0)
  dt$pcc1617 <- ifelse(dt$pastagem_2016 %in% c(1, 2) & dt$uso2017 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62)  & dt$uso2020 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62) ,1,0)
  dt$pcc1718 <- ifelse(dt$pastagem_2017 %in% c(1, 2) & dt$uso2018 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62)  & dt$uso2020 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62) ,1,0)
  dt$pcc1819 <- ifelse(dt$pastagem_2018 %in% c(1, 2) & dt$uso2019 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62)  & dt$uso2020 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62) ,1,0)
  
  
  
  
  x <- dt %>%
    group_by(idcar_imaflora,municipios) %>%
    summarise(pcd1011 = sum(pcd1011, na.rm = T),
              pcd1112 = sum(pcd1112, na.rm = T),
              pcd1213 = sum(pcd1213, na.rm = T),
              pcd1314 = sum(pcd1314, na.rm = T),
              pcd1415 = sum(pcd1415, na.rm = T),
              pcd1516 = sum(pcd1516, na.rm = T),
              pcd1617 = sum(pcd1617, na.rm = T),
              pcd1718 = sum(pcd1718, na.rm = T),
              pcd1819 = sum(pcd1819, na.rm = T),
              pcc1011 = sum(pcc1011, na.rm = T),
              pcc1112 = sum(pcc1112, na.rm = T),
              pcc1213 = sum(pcc1213, na.rm = T),
              pcc1314 = sum(pcc1314, na.rm = T),
              pcc1415 = sum(pcc1415, na.rm = T),
              pcc1516 = sum(pcc1516, na.rm = T),
              pcc1617 = sum(pcc1617, na.rm = T),
              pcc1718 = sum(pcc1718, na.rm = T),
              pcc1819 = sum(pcc1819, na.rm = T),
              cpd0910 = sum(cpd0910, na.rm = T),
              cpd1011 = sum(cpd1011, na.rm = T),
              cpd1112 = sum(cpd1112, na.rm = T),
              cpd1213 = sum(cpd1213, na.rm = T),
              cpd1314 = sum(cpd1314, na.rm = T),
              cpd1415 = sum(cpd1415, na.rm = T),
              cpd1516 = sum(cpd1516, na.rm = T),
              cpd1617 = sum(cpd1617, na.rm = T),
              cpd1718 = sum(cpd1718, na.rm = T),
              cpd1819 = sum(cpd1819, na.rm = T),
              cpd1920 = sum(cpd1920, na.rm = T),
              cpd1020 = sum(cpd1020, na.rm = T),
              cpd1015 = sum(cpd1015, na.rm = T),
              cpd1520 = sum(cpd1520, na.rm = T),
              pd0910 = sum(pd0910, na.rm = T),
              pd1011 = sum(pd1011, na.rm = T),
              pd1112 = sum(pd1112, na.rm = T),
              pd1213 = sum(pd1213, na.rm = T),
              pd1314 = sum(pd1314, na.rm = T),
              pd1415 = sum(pd1415, na.rm = T),
              pd1516 = sum(pd1516, na.rm = T),
              pd1617 = sum(pd1617, na.rm = T),
              pd1718 = sum(pd1718, na.rm = T),
              pd1819 = sum(pd1819, na.rm = T),
              pd1920 = sum(pd1920, na.rm = T),
              pd1020 = sum(pd1020, na.rm = T),
              pd1015 = sum(pd1015, na.rm = T),
              pd1520 = sum(pd1520, na.rm = T),
              area_ha = n()*1.0) %>% as_tibble()
  rm(dt)
  
  dbWriteTable(connec_local, 'teeb_raiox_conversao_final', x, row.names = F, append = T)
  
  cat('Escrito i = ', i)})



dbDisconnect(connec_local)

