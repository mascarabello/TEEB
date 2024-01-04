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


## dados de entrada do term-br
dbSendQuery(connec_local, "
            
DROP TABLE IF EXISTS public.input_termbr_rpd_cen1_cen2; 
CREATE TABLE public.input_termbr_rpd_cen1_cen2 (

id serial4 NOT NULL,
regioes_term text NULL,
area_rpd_cen1 float8 NULL,
area_rpdilp_cen2 float8 NULL,
area_rpdrest_cen2 float8 NULL
);

CREATE INDEX input_termbr_rpd_cen1_cen2_id_idx ON public.input_termbr_rpd_cen1_cen2 USING btree (id); ")

input_termbr_rpd_cen1_cen2 <- read.csv("/Users/marlucescarabello/Documents/GitHub/TEEB/dados/processados/termbr_rpd_cen1_cen2.csv",header = TRUE)
colnames(input_termbr_rpd_cen1_cen2) <- c("regioes_term","area_rpd_cen1","area_rpdilp_cen2","area_rpdrest_cen2")
dbWriteTable(connec_local, 'input_termbr_rpd_cen1_cen2', input_termbr_rpd_cen1_cen2, row.names = F, append = TRUE)


