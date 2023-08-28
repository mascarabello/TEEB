
## Dados de crédito para utilizar na alocação espacial
## Marluce Scarabello
## 5 de Julho de 2023

rm(list=ls())

library(dplyr)
library(tidyverse)
library(tidyverse)
library(raster)
library(RPostgreSQL)

## Source: https://www.bcb.gov.br/estabilidadefinanceira/micrrural. 
# Matriz 3.5 Arquivo csv de Quantidade e Valor dos Contratos por Município (260 MB)
df <- read.csv("/Users/marlucescarabello/Documents/GitHub/TEEB/dados/brutos/CusteioInvestimentoComercialIndustrialSemFiltros.csv",header = TRUE,sep = ",")
colnames(df)


# Dados de crédito rural --------------------------------------------------
## Seleção dos anos de interesse, programas que serão vindulados com o tamanho de produtor, atividade do produtor e 
## valores de interesse (custeio e investimento)
df2 <- df %>% 
  filter(codMunicIbge != 'null' ) %>%
  filter(AnoEmissao >= 2015 & AnoEmissao <= 2020 ) %>%
  filter(cdPrograma == 999 | cdPrograma == 1 | cdPrograma == 156 | cdPrograma == 50 ) %>%
  filter(Atividade == 2 ) %>%
  select(cdEstado, nomeUF, cdMunicipio, codMunicIbge, MesEmissao, AnoEmissao, cdPrograma, Atividade, VlCusteio, VlInvestimento) %>%
  pivot_longer(cols = c("VlCusteio","VlInvestimento"),
               names_to = "Modalidade",
               values_to =  "Valor") 

## Redefinindo 'Valor' como variável numérica
class(df2$Valor)
df2$Valor <- as.numeric(df2$Valor,na.rm=TRUE)
colnames(df2)

df_clean <- df2[c(4,5,6,7,9,10)]
colnames(df_clean) <- c("cd_mun","mes","ano","cdprograma",'modalidade','valor')
class(df_clean$cdprograma)

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

DROP TABLE IF EXISTS public.teeb_creditorural_custeioinvestimento; 
CREATE TABLE public.teeb_creditorural_custeioinvestimento (

id serial4 NOT NULL,
cd_mun integer NULL,
mes integer NULL,
ano integer NULL,
cdprograma integer NULL,
modalidade text NULL,
valor float8 NULL
);


CREATE INDEX teeb_creditorural_custeioinvestimento_id_idx ON public.teeb_creditorural_custeioinvestimento USING btree (id);
CREATE INDEX teeb_creditorural_custeioinvestimento_cd_mun_idx ON public.teeb_creditorural_custeioinvestimento USING btree (cd_mun);
CREATE INDEX teeb_creditorural_custeioinvestimento_mes_idx ON public.teeb_creditorural_custeioinvestimento USING btree (mes);
CREATE INDEX teeb_creditorural_custeioinvestimento_ano_idx ON public.teeb_creditorural_custeioinvestimento USING btree (ano);
CREATE INDEX teeb_creditorural_custeioinvestimento_cdPrograma_idx ON public.teeb_creditorural_custeioinvestimento USING btree (cdPrograma)
            ")

dbWriteTable(connec_local, 'teeb_creditorural_custeioinvestimento', df_clean, row.names = F, append = TRUE)

dbDisconnect(connec_local)
