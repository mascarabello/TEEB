# Library
library(networkD3)
library(dplyr)


####1985 -2021
# A connection data frame is a list of flows with intensity for each flow
links <- data.frame(
  source=c("Vegetação Nativa","Agricultura ","Pastagem", "Outros"), 
  target=c("Agricultura","Agricultura", "Agricultura", "Agricultura"), 
  value=c(13,14,19,11)
)

# From these flows we need to create a node data frame: it lists every entities involved in the flow
nodes <- data.frame(
  name=c(as.character(links$source), 
         as.character(links$target)) %>% unique()
)

# With networkD3, connection must be provided using id, not using real name like in the links dataframe.. So we need to reformat it.
links$IDsource <- match(links$source, nodes$name)-1 
links$IDtarget <- match(links$target, nodes$name)-1


my_color <- 'd3.scaleOrdinal() .domain(["Vegetação Nativa","Agricultura ","Pastagem", "Outros","Agricultura"]) .range(["#1e6d2d", "#ed8ac5" , "#f5ac00", "gray", "#ed8ac5"])'


# Make the Network
p <- sankeyNetwork(Links = links, Nodes = nodes,
                   Source = "IDsource", Target = "IDtarget",
                   Value = "value", NodeID = "name", 
                   colourScale=my_color,
                   fontSize = 20, nodeWidth = 30,
                   sinksRight=FALSE)
p


## pastagem


# Pastagem ----------------------------------------------------------------


# Limpando a area de trabalho
rm(list = ls())
# Library
library(networkD3)
library(dplyr)

# A connection data frame is a list of flows with intensity for each flow
links <- data.frame(
  source=c("Vegetação Nativa","Agricultura","Pastagem ", "Outros"), 
  target=c("Pastagem","Pastagem", "Pastagem", "Pastagem"), 
  value=c(75,1,83,19)
)

# From these flows we need to create a node data frame: it lists every entities involved in the flow
nodes <- data.frame(
  name=c(as.character(links$source), 
         as.character(links$target)) %>% unique()
)

# With networkD3, connection must be provided using id, not using real name like in the links dataframe.. So we need to reformat it.
links$IDsource <- match(links$source, nodes$name)-1 
links$IDtarget <- match(links$target, nodes$name)-1


my_color <- 'd3.scaleOrdinal() .domain(["Vegetação Nativa","Agricultura ","Pastagem ", "Outros","Pastagem"]) .range(["#1e6d2d", "#ed8ac5" , "#f5ac00", "gray", "#f5ac00"])'


# Make the Network
p <- sankeyNetwork(Links = links, Nodes = nodes,
                   Source = "IDsource", Target = "IDtarget",
                   Value = "value", NodeID = "name", 
                   colourScale=my_color,
                   fontSize = 20, nodeWidth = 30,
                   sinksRight=FALSE)
p


# 2010-2021 ---------------------------------------------------------------

rm(list = ls())

# Library
library(networkD3)
library(dplyr)

# A connection data frame is a list of flows with intensity for each flow
links <- data.frame(
  source=c("Vegetação Nativa","Agricultura ","Pastagem", "Outros"), 
  target=c("Agricultura","Agricultura", "Agricultura", "Agricultura"), 
  value=c(2,38,12,4)
)

# From these flows we need to create a node data frame: it lists every entities involved in the flow
nodes <- data.frame(
  name=c(as.character(links$source), 
         as.character(links$target)) %>% unique()
)

# With networkD3, connection must be provided using id, not using real name like in the links dataframe.. So we need to reformat it.
links$IDsource <- match(links$source, nodes$name)-1 
links$IDtarget <- match(links$target, nodes$name)-1


my_color <- 'd3.scaleOrdinal() .domain(["Vegetação Nativa","Agricultura ","Pastagem", "Outros","Agricultura"]) .range(["#1e6d2d", "#ed8ac5" , "#f5ac00", "gray", "#ed8ac5"])'


# Make the Network
p <- sankeyNetwork(Links = links, Nodes = nodes,
                   Source = "IDsource", Target = "IDtarget",
                   Value = "value", NodeID = "name", 
                   colourScale=my_color,
                   fontSize = 20, nodeWidth = 30,
                   sinksRight=FALSE)
p
#sankey4_2010_2021_agricultura

# Limpando a area de trabalho
rm(list = ls())
# Library
library(networkD3)
library(dplyr)

# A connection data frame is a list of flows with intensity for each flow
links <- data.frame(
  source=c("Vegetação Nativa","Agricultura","Pastagem ", "Outros"), 
  target=c("Pastagem","Pastagem", "Pastagem", "Pastagem"), 
  value=c(22,2,145,9)
)

# From these flows we need to create a node data frame: it lists every entities involved in the flow
nodes <- data.frame(
  name=c(as.character(links$source), 
         as.character(links$target)) %>% unique()
)

# With networkD3, connection must be provided using id, not using real name like in the links dataframe.. So we need to reformat it.
links$IDsource <- match(links$source, nodes$name)-1 
links$IDtarget <- match(links$target, nodes$name)-1


my_color <- 'd3.scaleOrdinal() .domain(["Vegetação Nativa","Agricultura ","Pastagem ", "Outros","Pastagem"]) .range(["#1e6d2d", "#ed8ac5" , "#f5ac00", "gray", "#f5ac00"])'


# Make the Network
p <- sankeyNetwork(Links = links, Nodes = nodes,
                   Source = "IDsource", Target = "IDtarget",
                   Value = "value", NodeID = "name", 
                   colourScale=my_color,
                   fontSize = 20, nodeWidth = 30,
                   sinksRight=FALSE)
p
##sankey3_2010_2021_pastagem
