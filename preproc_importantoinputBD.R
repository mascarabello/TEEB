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



## indicador de credito rural

dbSendQuery(connec_local, "
            
DROP TABLE IF EXISTS public.etapa3_creditorural_micro; 
CREATE TABLE public.etapa3_creditorural_micro (

id serial4 NOT NULL,
gid integer NULL,
cd_mun integer NULL,
cd_uf text NULL,
ctamprop text NULL,
tamanho text NULL,
regioes_term text NULL,
indicador float8 NULL
);


CREATE INDEX etapa3_creditorural_micro_id_idx ON public.etapa3_creditorural_micro USING btree (id);
CREATE INDEX etapa3_creditorural_micro_gid_idx ON public.etapa3_creditorural_micro USING btree (gid);
CREATE INDEX etapa3_creditorural_micro_cd_mun_idx ON public.etapa3_creditorural_micro USING btree (cd_mun);
            ")
ind_etapa3 <- read.csv("output/etapa3_creditorural_microregiao.csv",header =TRUE)
colnames(ind_etapa3)
colnames(ind_etapa3) <- c("gid","cd_mun","cd_uf","ctamprop","tamanho","regioes_term","indicador")

dbWriteTable(connec_local, 'etapa3_creditorural_micro', ind_etapa3, row.names = F, append = TRUE)


dbDisconnect(connec_local)