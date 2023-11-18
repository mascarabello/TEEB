#########################################################
# Extração de variaveis por propriedade - analise RPD
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


drop_table <- "DROP TABLE IF EXISTS public.teeb_raiox_recuperacao2_final"
executeQuery(connec_local, drop_table)

createTableQuery <-  
  "CREATE TABLE public.teeb_raiox_recuperacao2_final (

id serial4 NOT NULL,
idcar_imaflora integer NULL,
municipios integer NULL,
prd1011 float8 null,
prd1112 float8 null,
prd1213 float8 null,
prd1314 float8 null,
prd1415 float8 null,
prd1516 float8 null,
prd1617 float8 null,
prd1718 float8 null,
prd1819 float8 null,
prr1011 float8 null,
prr1112 float8 null,
prr1213 float8 null,
prr1314 float8 null,
prr1415 float8 null,
prr1516 float8 null,
prr1617 float8 null,
prr1718 float8 null,
prr1819 float8 null,
rpd0910 float8 null,
rpd1011 float8 null,
rpd1112 float8 null,
rpd1213 float8 null,
rpd1314 float8 null,
rpd1415 float8 null,
rpd1516 float8 null,
rpd1617 float8 null,
rpd1718 float8 null,
rpd1819 float8 null,
rpd1920 float8 null,
rpd1020 float8 null,
rpd1015 float8 null,
rpd1520 float8 null,
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
  "CREATE INDEX teeb_raiox_recuperacao2_final_id_idx ON public.teeb_raiox_recuperacao2_final USING btree (id)",
  "CREATE INDEX teeb_raiox_recuperacao2_final_idcar_imaflora_idx ON public.teeb_raiox_recuperacao2_final USING btree (idcar_imaflora)",
  "CREATE INDEX teeb_raiox_recuperacao2_final_municipios_idx ON public.teeb_raiox_recuperacao2_final USING btree (municipios)")


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
                   pastagem_2020 = getValues(pastagem_2020, row = bss$row[i], nrows = bss$nrows[i])  
  )
  
  #  dt <- subset(dt, idcar_imaflora > 0)
  
  dt$rpd0910 <- ifelse(dt$pastagem_2009 %in% c(1, 2) & dt$pastagem_2010 == 3, 1, 0)
  dt$rpd1011 <- ifelse(dt$pastagem_2010 %in% c(1, 2) & dt$pastagem_2011 == 3, 1, 0)
  dt$rpd1112 <- ifelse(dt$pastagem_2011 %in% c(1, 2) & dt$pastagem_2012 == 3, 1, 0)
  dt$rpd1213 <- ifelse(dt$pastagem_2012 %in% c(1, 2) & dt$pastagem_2013 == 3, 1, 0)
  dt$rpd1314 <- ifelse(dt$pastagem_2013 %in% c(1, 2) & dt$pastagem_2014 == 3, 1, 0)
  dt$rpd1415 <- ifelse(dt$pastagem_2014 %in% c(1, 2) & dt$pastagem_2015 == 3, 1, 0)  
  dt$rpd1516 <- ifelse(dt$pastagem_2015 %in% c(1, 2) & dt$pastagem_2016 == 3, 1, 0)
  dt$rpd1617 <- ifelse(dt$pastagem_2016 %in% c(1, 2) & dt$pastagem_2017 == 3, 1, 0)  
  dt$rpd1718 <- ifelse(dt$pastagem_2017 %in% c(1, 2) & dt$pastagem_2018 == 3, 1, 0)
  dt$rpd1819 <- ifelse(dt$pastagem_2018 %in% c(1, 2) & dt$pastagem_2019 == 3, 1, 0)  
  dt$rpd1920 <- ifelse(dt$pastagem_2019 %in% c(1, 2) & dt$pastagem_2020 == 3, 1, 0)
  dt$rpd1020 <- ifelse(dt$pastagem_2010 %in% c(1, 2) & dt$pastagem_2020 == 3, 1, 0)
  dt$rpd1015 <- ifelse(dt$pastagem_2010 %in% c(1, 2) & dt$pastagem_2015 == 3, 1, 0)
  dt$rpd1520 <- ifelse(dt$pastagem_2015 %in% c(1, 2) & dt$pastagem_2020 == 3, 1, 0)
  dt$pd0203 <- ifelse(dt$pastagem_2002 == 3 & dt$pastagem_2003 %in% c(1, 2), 1, 0)
  dt$pd0304 <- ifelse(dt$pastagem_2003 == 3 & dt$pastagem_2004 %in% c(1, 2), 1, 0)
  dt$pd0405 <- ifelse(dt$pastagem_2004 == 3 & dt$pastagem_2005 %in% c(1, 2), 1, 0)
  dt$pd0506 <- ifelse(dt$pastagem_2005 == 3 & dt$pastagem_2006 %in% c(1, 2), 1, 0)
  dt$pd0910 <- ifelse(dt$pastagem_2009 == 3 & dt$pastagem_2010 %in% c(1, 2), 1, 0)
  dt$pd1011 <- ifelse(dt$pastagem_2010 == 3 & dt$pastagem_2011 %in% c(1, 2), 1, 0)
  dt$pd1112 <- ifelse(dt$pastagem_2011 == 3 & dt$pastagem_2012 %in% c(1, 2), 1, 0)
  dt$pd1213 <- ifelse(dt$pastagem_2012 == 3 & dt$pastagem_2013 %in% c(1, 2), 1, 0)
  dt$pd1314 <- ifelse(dt$pastagem_2013 == 3 & dt$pastagem_2014 %in% c(1, 2), 1, 0)
  dt$pd1415 <- ifelse(dt$pastagem_2014 == 3 & dt$pastagem_2015 %in% c(1, 2), 1, 0)  
  dt$pd1516 <- ifelse(dt$pastagem_2015 == 3 & dt$pastagem_2016 %in% c(1, 2), 1, 0)
  dt$pd1617 <- ifelse(dt$pastagem_2016 == 3 & dt$pastagem_2017 %in% c(1, 2), 1, 0)  
  dt$pd1718 <- ifelse(dt$pastagem_2017 == 3 & dt$pastagem_2018 %in% c(1, 2), 1, 0)
  dt$pd1819 <- ifelse(dt$pastagem_2018 == 3 & dt$pastagem_2019 %in% c(1, 2), 1, 0)  
  dt$pd1920 <- ifelse(dt$pastagem_2019 == 3 & dt$pastagem_2020 %in% c(1, 2), 1, 0)
  dt$pd1020 <- ifelse(dt$pastagem_2010 == 3 & dt$pastagem_2020 %in% c(1, 2), 1, 0)
  dt$pd1015 <- ifelse(dt$pastagem_2010 == 3 & dt$pastagem_2015 %in% c(1, 2), 1, 0)
  dt$pd1520 <- ifelse(dt$pastagem_2015 == 3 & dt$pastagem_2020 %in% c(1, 2), 1, 0)
  dt$prd1011 <- ifelse(dt$pastagem_2010 %in% c(1, 2) & dt$pastagem_2011 == 3 & dt$pastagem_2020 %in% c(1, 2),1,0)
  dt$prd1112 <- ifelse(dt$pastagem_2011 %in% c(1, 2) & dt$pastagem_2012 == 3 & dt$pastagem_2020 %in% c(1, 2),1,0)
  dt$prd1213 <- ifelse(dt$pastagem_2012 %in% c(1, 2) & dt$pastagem_2013 == 3 & dt$pastagem_2020 %in% c(1, 2),1,0)
  dt$prd1314 <- ifelse(dt$pastagem_2013 %in% c(1, 2) & dt$pastagem_2014 == 3 & dt$pastagem_2020 %in% c(1, 2),1,0)
  dt$prd1415 <- ifelse(dt$pastagem_2014 %in% c(1, 2) & dt$pastagem_2015 == 3 & dt$pastagem_2020 %in% c(1, 2),1,0)
  dt$prd1516 <- ifelse(dt$pastagem_2015 %in% c(1, 2) & dt$pastagem_2016 == 3 & dt$pastagem_2020 %in% c(1, 2),1,0)
  dt$prd1617 <- ifelse(dt$pastagem_2016 %in% c(1, 2) & dt$pastagem_2017 == 3 & dt$pastagem_2020 %in% c(1, 2),1,0)
  dt$prd1718 <- ifelse(dt$pastagem_2017 %in% c(1, 2) & dt$pastagem_2018 == 3 & dt$pastagem_2020 %in% c(1, 2),1,0)
  dt$prd1819 <- ifelse(dt$pastagem_2018 %in% c(1, 2) & dt$pastagem_2019 == 3 & dt$pastagem_2020 %in% c(1, 2),1,0)
  
  dt$prr1011 <- ifelse(dt$pastagem_2010 %in% c(1, 2) & dt$pastagem_2011 == 3 & dt$pastagem_2020 == 3,1,0)
  dt$prr1112 <- ifelse(dt$pastagem_2011 %in% c(1, 2) & dt$pastagem_2012 == 3 & dt$pastagem_2020 == 3,1,0)
  dt$prr1213 <- ifelse(dt$pastagem_2012 %in% c(1, 2) & dt$pastagem_2013 == 3 & dt$pastagem_2020 == 3,1,0)
  dt$prr1314 <- ifelse(dt$pastagem_2013 %in% c(1, 2) & dt$pastagem_2014 == 3 & dt$pastagem_2020 == 3,1,0)
  dt$prr1415 <- ifelse(dt$pastagem_2014 %in% c(1, 2) & dt$pastagem_2015 == 3 & dt$pastagem_2020 == 3,1,0)
  dt$prr1516 <- ifelse(dt$pastagem_2015 %in% c(1, 2) & dt$pastagem_2016 == 3 & dt$pastagem_2020 == 3,1,0)
  dt$prr1617 <- ifelse(dt$pastagem_2016 %in% c(1, 2) & dt$pastagem_2017 == 3 & dt$pastagem_2020 == 3,1,0)
  dt$prr1718 <- ifelse(dt$pastagem_2017 %in% c(1, 2) & dt$pastagem_2018 == 3 & dt$pastagem_2020 == 3,1,0)
  dt$prr1819 <- ifelse(dt$pastagem_2018 %in% c(1, 2) & dt$pastagem_2019 == 3 & dt$pastagem_2020 == 3,1,0)
  
  
  
  
  x <- dt %>%
    group_by(idcar_imaflora,municipios) %>%
    summarise(prd1011 = sum(prd1011, na.rm = T),
              prd1112 = sum(prd1112, na.rm = T),
              prd1213 = sum(prd1213, na.rm = T),
              prd1314 = sum(prd1314, na.rm = T),
              prd1415 = sum(prd1415, na.rm = T),
              prd1516 = sum(prd1516, na.rm = T),
              prd1617 = sum(prd1617, na.rm = T),
              prd1718 = sum(prd1718, na.rm = T),
              prd1819 = sum(prd1819, na.rm = T),
              prr1011 = sum(prr1011, na.rm = T),
              prr1112 = sum(prr1112, na.rm = T),
              prr1213 = sum(prr1213, na.rm = T),
              prr1314 = sum(prr1314, na.rm = T),
              prr1415 = sum(prr1415, na.rm = T),
              prr1516 = sum(prr1516, na.rm = T),
              prr1617 = sum(prr1617, na.rm = T),
              prr1718 = sum(prr1718, na.rm = T),
              prr1819 = sum(prr1819, na.rm = T),
              rpd0910 = sum(rpd0910, na.rm = T),
              rpd1011 = sum(rpd1011, na.rm = T),
              rpd1112 = sum(rpd1112, na.rm = T),
              rpd1213 = sum(rpd1213, na.rm = T),
              rpd1314 = sum(rpd1314, na.rm = T),
              rpd1415 = sum(rpd1415, na.rm = T),
              rpd1516 = sum(rpd1516, na.rm = T),
              rpd1617 = sum(rpd1617, na.rm = T),
              rpd1718 = sum(rpd1718, na.rm = T),
              rpd1819 = sum(rpd1819, na.rm = T),
              rpd1920 = sum(rpd1920, na.rm = T),
              rpd1020 = sum(rpd1020, na.rm = T),
              rpd1015 = sum(rpd1015, na.rm = T),
              rpd1520 = sum(rpd1520, na.rm = T),
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
  
  dbWriteTable(connec_local, 'teeb_raiox_recuperacao2_final', x, row.names = F, append = T)
  
  cat('Escrito i = ', i)})



dbDisconnect(connec_local)

