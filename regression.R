library(tidyverse)
library(dplyr)
library(mice)

tn_socioeconomics <- read.csv('data/tn_socioeconomics.csv')

tn_socioeconomics_numeric <- select_if(tn_socioeconomics, is.numeric)
tn_socioeconomics_numeric <- tn_socioeconomics_numeric[,!grepl('_grad|grad_|graduation|dropout', 
                                                               colnames(tn_socioeconomics_numeric))]
mice_results <- mice(tn_socioeconomics_numeric, m = 1, method = 'norm')
tn_socioeconomics_numeric <- complete(mice_results,1)

ggplot(tn_socioeconomics_numeric, aes(x=est_count_total_widowed, y=grad)) +
  geom_point() +
  #scale_x_log10() +
  geom_smooth()

cor(x=tn_socioeconomics_numeric$bio, 
    y=tn_socioeconomics_numeric$grad, 
    method = "pearson", 
    use = "complete.obs")
