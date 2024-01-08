### Gráfico - slides Escolas

library(pacman)
p_load( raster, rgdal,   dplyr, ggplot2, tidyr, ggrepel, tidyverse, forcats,tidyr)

categorias_pallete <- c(
  '0-50'='#a969e2',  
  '50-100'= '#f5749d',
  '100-500'='#ea9247',
  '500-1000'='#f44013',
  '>1000'='#6bbef9'
)



library(ggplot2)
library(ggrepel)
library(dplyr)
dt1 <- data.frame(
  "Categoria" = factor(c("0-50","50-100","100-500","500-1000",">1000")),
  "Area" = c( 1.3,0.8,2.0,0.9,2.0),
  'Perc1' = c(19,11,29,13,29)
)

dt1$Categoria <- factor(dt1$Categoria, levels = c("0-50","50-100","100-500","500-1000",">1000"))

levels(dt1$Categoria)
dt11_label <- 
  dt1 %>% 
  mutate(perc = Area/ sum(Area)) %>% 
  mutate(labels = scales::percent(perc)) %>% 
  arrange(desc(Categoria)) %>% ## arrange in the order of the legend
  mutate(text_y = cumsum(Area) - Area/2) ### calculate where to place the text labels

options(OutDec=".")
p1 <- dt11_label %>%
  ggplot(aes(x = "", y = Area, fill = Categoria)) +
  geom_bar(stat = "identity",width=1, color="white",show.legend = FALSE) +
  coord_polar("y", start = 0) +
  theme_void() +
  theme(legend.text = element_text(size = 16),  # Ajuste o tamanho da fonte
        legend.title = element_text(size = 20))+
  #geom_text(aes(y= text_y, label = paste0(round(Area, 1),' (', round(Perc1,1), '%)')), color = "white", size=6) +
  #geom_text(aes(label = paste0(round(Area, 1),' (', round(Perc1,1), '%)')),size = 12,position = position_fill(vjust = 0.5), show.legend = F) +
  geom_label_repel(aes(label = paste0(round(Area, 1),'Mha (', round(Perc1,1), '%)'),y = text_y), 
                   #nudge_x = 0.6, nudge_y = 0.6,
                   #position = position_fill(vjust = 0.5), 
                   size = 10, show.legend = F) +
  scale_fill_manual('Property Size', values = categorias_pallete); p1

ggsave(filename = '/Users/marlucescarabello/Dropbox/Work/GPP/Teeb/P4_adicional/pizza_area_selec.png', plot = p1, units = 'in', dpi = 300, scale = 1.5)


p1 <- dt11_label %>%
  ggplot(aes(x = "", y = Area, fill = Categoria)) +
  geom_bar(stat = "identity",width=1, color="white") +
  coord_polar("y", start = 0) +
  theme_void() +
  theme(legend.text = element_text(size = 28),  # Ajuste o tamanho da fonte
        legend.title = element_text(size = 30))+
  #geom_text(aes(y= text_y, label = paste0(round(Area, 1),' (', round(Perc1,1), '%)')), color = "white", size=6) +
  #geom_text(aes(label = paste0(round(Area, 1),' (', round(Perc1,1), '%)')),size = 12,position = position_fill(vjust = 0.5), show.legend = F) +
  geom_label_repel(aes(label = paste0(round(Area, 1),'Mha (', round(Perc1,1), '%)'),y = text_y), 
                   #nudge_x = 0.6, nudge_y = 0.6,
                   #position = position_fill(vjust = 0.5), 
                   size = 10, show.legend = F) +
  scale_fill_manual('Property Size (ha)', values = categorias_pallete); p1
ggsave(filename = '/Users/marlucescarabello/Dropbox/Work/GPP/Teeb/P4_adicional/legenda.png', plot = p1, units = 'in', dpi = 300, scale = 1.5)


## numero
dt2 <- data.frame(
  "Categoria" = factor(c("0-50","50-100","100-500","500-1000",">1000")),
  "Area" = c(344,89,121,23,20),
  'Perc1' = c(57,15,20,4,3)
)

dt2$Categoria <- factor(dt1$Categoria, levels = c("0-50","50-100","100-500","500-1000",">1000"))

levels(dt1$Categoria)
dt22_label <- 
  dt2 %>% 
  mutate(perc = Area/ sum(Area)) %>% 
  mutate(labels = scales::percent(perc)) %>% 
  arrange(desc(Categoria)) %>% ## arrange in the order of the legend
  mutate(text_y = cumsum(Area) - Area/2) ### calculate where to place the text labels

options(OutDec=".")
p2 <- dt22_label %>%
  ggplot(aes(x = "", y = Area, fill = Categoria)) +
  geom_bar(stat = "identity",width=1, color="white",show.legend = FALSE) +
  coord_polar("y", start = 0) +
  theme_void() +
  theme(legend.text = element_text(size = 16),  # Ajuste o tamanho da fonte
        legend.title = element_text(size = 20))+
  #geom_text(aes(y= text_y, label = paste0(round(Area, 1),' (', round(Perc1,1), '%)')), color = "white", size=6) +
  #geom_text(aes(label = paste0(round(Area, 1),' (', round(Perc1,1), '%)')),size = 12,position = position_fill(vjust = 0.5), show.legend = F) +
  geom_label_repel(aes(label = paste0(round(Area, 1),' (', round(Perc1,1), '%)'),y = text_y), 
                   #nudge_x = 0.6, nudge_y = 0.6,
                   #position = position_fill(vjust = 0.5), 
                   size = 10, show.legend = F) +
  scale_fill_manual('Property Size', values = categorias_pallete); p2

ggsave(filename = '/Users/marlucescarabello/Dropbox/Work/GPP/Teeb/P4_adicional/pizza_numero2_selec.png', plot = p2, units = 'in', dpi = 300, scale = 1.5)
