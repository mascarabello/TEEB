gdalwarp -s_srs EPSG:4674 -t_srs "+proj=aea +lat_1=-2 +lat_2=-22 +lat_0=-12 +lon_0=-54 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs" -tr 100 100 -te -2178091.5413726898841560 -2385764.0860471501946449 2610358.4586273101158440 1902825.9139528500381857 -co "COMPRESS=DEFLATE" -co "ZLEVEL=9" -co "PREDICTOR=2" -co "BIGTIFF=IF_SAFER" -co "NUM_THREADS=8" /Users/marlucescarabello/Documents/GitHub/TEEB/dados/brutos/qualidadepastagem_lapig/pasture_cvp_modis_col7_2020_Brazil_atlas_sirgas.tif /Users/marlucescarabello/Documents/GitHub/TEEB/dados/processados/pasture_cvp_modis_col7_2020_Brazil_albers_100m.tif