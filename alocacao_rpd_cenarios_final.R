
# Cleaning the environment
rm(list = ls())

# Reading data
library(raster)
library(RPostgreSQL)
library(dplyr)
library(tidyverse)
library(data.table)
library(rgdal)
library(sf)
library(terra)




# CENÁRIO 1 ---------------------------------------------------------------
cenario1 <- raster("/Users/marlucescarabello/Documents/GitHub/TEEB/dados/proj_espacial/pastagens_degradadas_S1_2030_vfinal.tif");cenario1;
restcen1 <- raster("/Users/marlucescarabello/Documents/GitHub/TEEB/resultados_alocacaorpd/results_cen1_final_geom_albers_100m_vfinal.tif"); restcen1;
out <- raster("/Users/marlucescarabello/Documents/GitHub/TEEB/dados/proj_espacial/pastagens_degradadas_S1_2030_vfinal.tif")  

# Marking pasture pixels in LAPIG as pasture in MAPBIOMAS
bss <- blockSize(cenario1)

cenario1 <- readStart(cenario1)
restcen1 <- readStart(restcen1)
out <- readStart(out)
out <- writeStart(out, filename = "/Users/marlucescarabello/Documents/GitHub/TEEB/resultados_alocacaorpd/S1_2030_restaurado_vfinal.tif",format = 'Gtiff',overwrite=TRUE,options=c("COMPRESS=DEFLATE","ZLEVEL=9","PREDICTOR=2","TFW=YES"))

bss$n
for(i in 1:bss$n) {
  x <- getValues(cenario1, row = bss$row[i], nrows = bss$nrows[i])
  y <- getValues(restcen1, row = bss$row[i], nrows = bss$nrows[i])
  y[which(is.na(y))] <- 1
  y[y[]==0] <- 1
  x[x[]==100] = y[x[]==100]*x[x[]==100]
  x[x[]==1000] = y[x[]==1000]*x[x[]==1000]
  #z <- paste(x,y, sep = "")
  z <- as.integer(x)
  out <- writeValues(out, z,  bss$row[i])
  #out <- writeRaster(out,x)
  print(i)
}

out <- writeStop(out)
readStop(cenario1)
readStop(restcen1)



# CENÁRIO 2 ---------------------------------------------------------------

cenario2 <- raster("/Users/marlucescarabello/Documents/GitHub/TEEB/dados/proj_espacial/pastagens_degradadas_S2_2030_vfinal.tif");cenario2;
restcen2 <- raster("/Users/marlucescarabello/Documents/GitHub/TEEB/resultados_alocacaorpd/results_cen2_final_geom_albers_100m_vfinal.tif"); restcen2;
out2 <- raster("/Users/marlucescarabello/Documents/GitHub/TEEB/dados/proj_espacial/pastagens_degradadas_S2_2030_vfinal.tif")  

# Marking pasture pixels in LAPIG as pasture in MAPBIOMAS
bss <- blockSize(cenario2)

cenario2 <- readStart(cenario2)
restcen2 <- readStart(restcen2)
out2 <- readStart(out2)
out2 <- writeStart(out2, filename = "/Users/marlucescarabello/Documents/GitHub/TEEB/resultados_alocacaorpd/S2_2030_restaurado_vfinal.tif",format = 'Gtiff',overwrite=TRUE,options=c("COMPRESS=DEFLATE","ZLEVEL=9","PREDICTOR=2","TFW=YES"))
bss$n
for(i in 1:bss$n) {
  x <- getValues(cenario2, row = bss$row[i], nrows = bss$nrows[i])
  y <- getValues(restcen2, row = bss$row[i], nrows = bss$nrows[i])
  y[which(is.na(y))] <- 1
  y[which(y[]==0)] <- 1
  x[x[]==100] = y[x[]==100]*x[x[]==100]
  x[x[]==1000] = y[x[]==1000]*x[x[]==1000]
  #z <- paste(x,y, sep = "")
  z <- as.integer(x)
  out2 <- writeValues(out2, z,  bss$row[i])
  #out <- writeRaster(out,x)
  print(i)
}

out2 <- writeStop(out2)
readStop(cenario2)
readStop(restcen2)

