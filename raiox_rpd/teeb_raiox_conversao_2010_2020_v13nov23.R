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
qualpastagem_2010 <- raster("pa_br_qualpastagem_lapig_100m_2010_albers.tif"); qualpastagem_2010;
qualpastagem_2020 <- raster("pa_br_qualpastagem_lapig_100m_2020_albers.tif"); qualpastagem_2020;
uso2010 <- raster("pa_br_usoterra_mapbiomas7_lapig_100m_2010_albers_corrigido.tif"); uso2010;
uso2020 <- raster("pa_br_usoterra_mapbiomas7_lapig_100m_2020_albers_corrigido.tif"); uso2020;




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


drop_table <- "DROP TABLE IF EXISTS public.teeb_raiox_conversao_corrigido"
executeQuery(connec_local, drop_table)

createTableQuery <-  
  "CREATE TABLE public.teeb_raiox_conversao_corrigido (

id serial4 NOT NULL,
idcar_imaflora integer NULL,
municipios integer NULL,
cpd1020 float8 null,
daa1020 float8 null,
area_ha float8 NULL
);"

executeQuery(connec_local, createTableQuery)



# Criando índices
indexQueries <- c(
  "CREATE INDEX teeb_raiox_conversao_corrigido_id_idx ON public.teeb_raiox_conversao_corrigido USING btree (id)",
  "CREATE INDEX teeb_raiox_conversao_corrigido_idcar_imaflora_idx ON public.teeb_raiox_conversao_corrigido USING btree (idcar_imaflora)",
  "CREATE INDEX teeb_raiox_conversao_corrigido_municipios_idx ON public.teeb_raiox_conversao_corrigido USING btree (municipios)")


for (indexQuery in indexQueries) {
  executeQuery(connec_local, indexQuery)
}


# Finaliza a transação
dbCommit(connec_local)


bss <- blockSize(municipios); bss$n

system.time(for (i in 1:bss$n) {
  dt <- data.table(idcar_imaflora = getValues(idcar_imaflora, row = bss$row[i], nrows = bss$nrows[i]),
                   municipios = getValues(municipios, row = bss$row[i], nrows = bss$nrows[i]),
                   qualpastagem_2010 = getValues(qualpastagem_2010, row = bss$row[i], nrows = bss$nrows[i]),
                   qualpastagem_2020 = getValues(qualpastagem_2020, row = bss$row[i], nrows = bss$nrows[i]),
                   uso2010 = getValues(uso2010, row = bss$row[i], nrows = bss$nrows[i]),
                   uso2020 = getValues(uso2020, row = bss$row[i], nrows = bss$nrows[i])   
  )
  
  # se pastagem no Mapbiomas (ajustado) E é pastagem degradada em 2010, e em 2020 é agricultura
  dt$cpd1020 <- ifelse(dt$uso2010 %in% c(15) & dt$qualpastagem_2010 %in% c(1,2) & 
                         dt$uso2020 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62), 1, 0)
  dt$daa1020 <- ifelse(dt$uso2010 %in% c(9, 20, 21, 39, 40, 41, 46, 47, 48, 62) & 
                         dt$qualpastagem_2020 %in% c(1, 2) & dt$uso2020 %in% c(15), 1, 0)
#    dt$cpd1020 <- ifelse(dt$uso2010 %in% c(15) & dt$qualpastagem_2010 %in% c(1,2) & 
#                           dt$uso2020 %in% c(20, 39, 40, 41, 46, 47, 48, 62), 1, 0)
#    dt$daa1020 <- ifelse(dt$uso2010 %in% c(20, 39, 40, 41, 46, 47, 48, 62) & 
#                           dt$qualpastagem_2020 %in% c(1, 2) & dt$uso2020 %in% c(15), 1, 0)
  
  
  
  x <- dt %>%
    group_by(idcar_imaflora,municipios) %>%
    summarise(cpd1020 = sum(cpd1020, na.rm = T),
              daa1020 = sum(daa1020, na.rm = T),
              area_ha = n()*1.0) %>% as_tibble()
  rm(dt)
  
  dbWriteTable(connec_local, 'teeb_raiox_conversao_corrigido', x, row.names = F, append = T)
  
  cat('Escrito i = ', i)})



dbDisconnect(connec_local)

