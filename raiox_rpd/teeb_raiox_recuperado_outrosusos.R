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
pastagem_2010 <- raster("pa_br_qualpastagem_lapig_100m_2010_albers.tif"); pastagem_2010;
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


drop_table <- "DROP TABLE IF EXISTS public.teeb_raiox_recuperacao_outrosusos_final"
executeQuery(connec_local, drop_table)

createTableQuery <-  
  "CREATE TABLE public.teeb_raiox_recuperacao_outrosusos_final (

id serial4 NOT NULL,
idcar_imaflora integer NULL,
municipios integer NULL,
cpd1020 float8 null,
pd1020 float8 null,
area_ha float8 NULL
);"

executeQuery(connec_local, createTableQuery)



# Criando índices
indexQueries <- c(
  "CREATE INDEX teeb_raiox_recuperacao_outrosusos_final_id_idx ON public.teeb_raiox_recuperacao_outrosusos_final USING btree (id)",
  "CREATE INDEX teeb_raiox_recuperacao_outrosusos_final_idcar_imaflora_idx ON public.teeb_raiox_recuperacao_outrosusos_final USING btree (idcar_imaflora)",
  "CREATE INDEX teeb_raiox_recuperacao_outrosusos_final_municipios_idx ON public.teeb_raiox_recuperacao_outrosusos_final USING btree (municipios)")


for (indexQuery in indexQueries) {
  executeQuery(connec_local, indexQuery)
}


# Finaliza a transação
dbCommit(connec_local)


bss <- blockSize(municipios); bss$n

system.time(for (i in 1:bss$n) {
  dt <- data.table(idcar_imaflora = getValues(idcar_imaflora, row = bss$row[i], nrows = bss$nrows[i]),
                   municipios = getValues(municipios, row = bss$row[i], nrows = bss$nrows[i]),
                   pastagem_2010 = getValues(pastagem_2010, row = bss$row[i], nrows = bss$nrows[i]),
                   pastagem_2020 = getValues(pastagem_2020, row = bss$row[i], nrows = bss$nrows[i])  
  )
  
  #  dt <- subset(dt, idcar_imaflora > 0)
  
  dt$cpd1020 <- ifelse(dt$pastagem_2010 %in% c(1, 2) & is.na(dt$pastagem_2020), 1, 0)
  dt$pd1020 <- ifelse(is.na(dt$pastagem_2010) & dt$pastagem_2020 %in% c(1, 2), 1, 0)

  x <- dt %>%
    group_by(idcar_imaflora,municipios) %>%
    summarise(cpd1020 = sum(cpd1020, na.rm = T),
              pd1020 = sum(pd1020, na.rm = T),
              area_ha = n()*1.0) %>% as_tibble()
  rm(dt)
  
  dbWriteTable(connec_local, 'teeb_raiox_recuperacao_outrosusos_final', x, row.names = F, append = T)
  
  cat('Escrito i = ', i)})



dbDisconnect(connec_local)

