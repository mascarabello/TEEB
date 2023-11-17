rm(list=ls())
options(scipen = 999)
options(stringsAsFactors = F)
# installing packages 
library(pacman)
#p_load( raster, rgdal, prop,   dplyr, ggplot2,RPostgres, tidyr, ggrepel, tidyverse, forcats,tidyr)
p_load( raster, rgdal,   dplyr, ggplot2,RPostgres, tidyr, ggrepel, tidyverse, forcats,tidyr)
install.packages('BiocManager')

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


start <- Sys.time()

dt1 <- dbGetQuery(connec_local , "WITH foo as (
SELECT 
a.idcar_imaflora,
b.cd_uf,	
b.tamanho,
sum(a.daa1020) as acum_daa
FROM public.teeb_raiox_conversao_final_2010_2020 as a
	left join teeb.imoveis_regioesterm as b 
	on a.municipios IS NOT NULL and a.idcar_imaflora != 0 AND b.gid != 0  AND a.idcar_imaflora = b.gid and b.cd_uf is not null 
GROUP BY a.idcar_imaflora, b.cd_uf, b.tamanho)
select 
tamanho,
count(distinct idcar_imaflora)/1000 as num_imoveis,
sum(acum_daa)/1000000 as area_daa_ha
FROM foo
where acum_daa > 0 AND tamanho IS NOT NULL
group by tamanho")



dt
dt1
dt$tamanho <- factor(dt$tamanho, levels = c("0-50","50-100","100-500","500-1000",">1000 "))


#my_order <-c("0-50","50-100","100-500","500-1000",">1000 ")
#dt = within(dt, 
#            tamanho <- factor(tamanho, 
#                              levels=my_order))


categorias_pallete <- c(
  '0-50'='#a969e2',  
  '50-100'= '#f5749d',
  '100-500'='#ea9247',
  '500-1000'='#f44013',
  ">1000 "='#6bbef9'
)


dt1 <- dt[c(1,2)]
dt1$perc <- dt$num_imoveis/sum(dt$num_imoveis)

sum(dt1$num_imoveis)
dt1_label <- 
  dt1 %>% 
  mutate(perc = num_imoveis/ sum(num_imoveis)) %>% 
  mutate(labels = scales::percent(perc)) %>% 
  arrange(desc(tamanho)) %>% ## arrange in the order of the legend
  mutate(text_y = cumsum(num_imoveis) - num_imoveis/2) ### calculate where to place the text labels

options(OutDec=",")
p1 <- dt1_label %>%
  ggplot(aes(x = "", y = num_imoveis, fill = tamanho)) +
  geom_bar(stat = "identity",width=1, color="white") +
  ggtitle("Número de imóveis (mil) - DAA") +
  coord_polar("y", start = 0) +
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5, size = 20),
        legend.text = element_text(size = 16),  # Ajuste o tamanho da fonte
        legend.title = element_text(size = 20))+
  #geom_text(aes(y= text_y, label = paste0(round(Area, 1),' (', round(Perc1,1), '%)')), color = "white", size=6) +
  #geom_text(aes(label = paste0(round(Area, 1),' (', round(Perc1,1), '%)')),size = 12,position = position_fill(vjust = 0.5), show.legend = F) +
  geom_label_repel(aes(label = paste0(round(num_imoveis, 1),' (', round(perc*100,1), '%)'),y = text_y), 
                   #nudge_x = 0.6, nudge_y = 0.6,
                   #position = position_fill(vjust = 0.5), 
                   size = 6, show.legend = F) +
  scale_fill_manual('Tamanho do imóvel', values = categorias_pallete); p1


## ÁREA
dt2 <- dt[c(1,3)]
dt2$perc <- dt$area_daa_ha/sum(dt$area_daa_ha)


dt2_label <- 
  dt2 %>% 
  mutate(perc = area_daa_ha/ sum(area_daa_ha)) %>% 
  mutate(labels = scales::percent(perc)) %>% 
  arrange(desc(tamanho)) %>% ## arrange in the order of the legend
  mutate(text_y = cumsum(area_daa_ha) - area_daa_ha/2) ### calculate where to place the text labels

options(OutDec=",")
p2 <- dt2_label %>%
  ggplot(aes(x = "", y = area_daa_ha, fill = tamanho)) +
  geom_bar(stat = "identity",width=1, color="white",show.legend = FALSE) +
  ggtitle("Área de DAA (Mha)") +
  coord_polar("y", start = 0) +
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5, size = 20),
        legend.text = element_text(size = 16),  # Ajuste o tamanho da fonte
        legend.title = element_text(size = 20))+
  #geom_text(aes(y= text_y, label = paste0(round(Area, 1),' (', round(Perc1,1), '%)')), color = "white", size=6) +
  #geom_text(aes(label = paste0(round(Area, 1),' (', round(Perc1,1), '%)')),size = 12,position = position_fill(vjust = 0.5), show.legend = F) +
  geom_label_repel(aes(label = paste0(round(area_daa_ha, 1),' Mha (', round(perc*100,1), '%)'),y = text_y), 
                   #nudge_x = 0.6, nudge_y = 0.6,
                   #position = position_fill(vjust = 0.5), 
                   size = 5, show.legend = F) +
  scale_fill_manual('Tamanho do imóvel', values = categorias_pallete); p2


library(cowplot)
t <- ggdraw() +
  draw_plot(p2, 0,0.5,0.5,0.5,0.85) +
  draw_plot(p1, 0.5,0.5,.5,.5) 
  #draw_plot_label(c("a)", "b)"), c(0.25, 0.75), c(0.5, 0.5), size = 20)
ggsave(filename = '/Users/marlucescarabello/Dropbox/Work/GPP/Teeb/P4_adicional/conversao_daa_periodo_tamanhoimovel_16nov23.png', plot = t,units = 'in', dpi = 300, scale = 1.5)
#ggsave(filename = '/Users/marlucescarabello/Dropbox/Work/GPP/Teeb/P4_adicional/recuperacao_pd_tamanhoimovel2.png', plot = t,width = 10, height=12,units = 'in', dpi = 300, scale = 1.5)
t 
