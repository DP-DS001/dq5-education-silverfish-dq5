library(shinydashboard)
library(tidyverse)
library(DT)

t <- readRDS('data/graph.RDS')
#t <- t[3:6]  #45]
#t <- data.frame(t)
#t <- sapply( t, as.numeric )

#county <- colnames(t)
#n