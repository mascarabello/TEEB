#############################################
# Merging LAPIG and MAPBIOMAS rasters
############################################

# Cleaning the environment
rm(list = ls())

# Reading data
library(pacman)
p_load(raster, data.table, rgdal, sf, terra)

setwd("/Users/marlucescarabello/Dropbox/Work/GPP/Teeb/P4_adicional/rasters")

## 2010 
lap <- raster("pa_br_pastagem_lapig_100m_2020_albers.tif")
map <- raster("pa_br_usoterra_mapbiomas7_100m_2020_albers.tif")
out <- raster("pa_br_usoterra_mapbiomas7_100m_2020_albers.tif")

# Marking pasture pixels in LAPIG as pasture in MAPBIOMAS
bss <- blockSize(map)
bss
lap <- readStart(lap)
map <- readStart(map)
out <- readStart(out)
#out <- writeStart(out, filename = "pa_br_usoterra_mapbiomas7_lapig_100m_2010_albers.tif",format = 'Gtiff',overwrite=TRUE)
out <- writeStart(out, filename = "pa_br_usoterra_mapbiomas7_lapig_100m_2020_albersv2.tif",format = 'Gtiff',overwrite=TRUE,options=c("COMPRESS=DEFLATE","ZLEVEL=9","PREDICTOR=2","TFW=YES"))


for(i in 1:bss$n) {
  x <- getValues(lap, row = bss$row[i], nrows = bss$nrows[i])
  y <- getValues(map, row = bss$row[i], nrows = bss$nrows[i])
  y[x[] == 1] = 15
  out <- writeValues(out, y,  bss$row[i])
  print(i)
}

lap <- readStop(lap)
map <- readStop(map)
out <- writeStop(out)



# 1985 --------------------------------------------------------------------
rm(list = ls())

# Reading data
library(pacman)
p_load(raster, data.table, rgdal, sf, terra)

setwd("/Users/marlucescarabello/Dropbox/Work/GPP/Teeb/P4_adicional/rasters")

## 1985
lap <- raster("pa_br_pastagem_lapig_100m_1985_albers.tif")
map <- raster("pa_br_usoterra_mapbiomas7_100m_1985_albers.tif")
out <- raster("pa_br_usoterra_mapbiomas7_100m_1985_albers.tif")

# Marking pasture pixels in LAPIG as pasture in MAPBIOMAS
bss <- blockSize(map)
bss
lap <- readStart(lap)
map <- readStart(map)
out <- readStart(out)
#out <- writeStart(out, filename = "pa_br_usoterra_mapbiomas7_lapig_100m_2010_albers.tif",format = 'Gtiff',overwrite=TRUE)
out <- writeStart(out, filename = "pa_br_usoterra_mapbiomas7_100m_1985_albers_comp.tif",format = 'Gtiff',overwrite=TRUE,options=c("COMPRESS=DEFLATE","ZLEVEL=9","PREDICTOR=2","TFW=YES"))


for(i in 1:bss$n) {
  x <- getValues(lap, row = bss$row[i], nrows = bss$nrows[i])
  y <- getValues(map, row = bss$row[i], nrows = bss$nrows[i])
  y[x[] == 1] = 15
  out <- writeValues(out, y,  bss$row[i])
  print(i)
}

lap <- readStop(lap)
map <- readStop(map)
out <- writeStop(out)


# 2021 --------------------------------------------------------------------
rm(list = ls())

# Reading data
library(pacman)
p_load(raster, data.table, rgdal, sf, terra)

setwd("/Users/marlucescarabello/Dropbox/Work/GPP/Teeb/P4_adicional/rasters")

## 1985
lap <- raster("pa_br_pastagem_lapig_100m_2021_albers.tif")
map <- raster("pa_br_usoterra_mapbiomas7_100m_2021_albers.tif")
out <- raster("pa_br_usoterra_mapbiomas7_100m_2021_albers.tif")

# Marking pasture pixels in LAPIG as pasture in MAPBIOMAS
bss <- blockSize(map)
bss
lap <- readStart(lap)
map <- readStart(map)
out <- readStart(out)
#out <- writeStart(out, filename = "pa_br_usoterra_mapbiomas7_lapig_100m_2010_albers.tif",format = 'Gtiff',overwrite=TRUE)
out <- writeStart(out, filename = "pa_br_usoterra_mapbiomas7_100m_2021_albers_comp.tif",format = 'Gtiff',overwrite=TRUE,options=c("COMPRESS=DEFLATE","ZLEVEL=9","PREDICTOR=2","TFW=YES"))


for(i in 1:bss$n) {
  x <- getValues(lap, row = bss$row[i], nrows = bss$nrows[i])
  y <- getValues(map, row = bss$row[i], nrows = bss$nrows[i])
  y[x[] == 1] = 15
  out <- writeValues(out, y,  bss$row[i])
  print(i)
}

lap <- readStop(lap)
map <- readStop(map)
out <- writeStop(out)




