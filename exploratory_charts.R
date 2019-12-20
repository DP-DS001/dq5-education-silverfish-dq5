library(tidyverse)
library(dplyr)

tn_socioeconomics <- read.csv('data/tn_socioeconomics.csv')

grad_by_county_top <- tn_socioeconomics %>% 
  group_by(county_name.x) %>% 
  summarize(mean_grad= mean(grad)) %>%
  top_n(5, mean_grad) %>%
  ungroup()

ggplot(grad_by_county_top, aes(reorder(county_name.x, mean_grad), mean_grad)) +
  geom_col() +
  coord_flip() +
  ylab("Graduation Rate") +
  xlab("") +
  theme(axis.text.x = element_text(size=12),
        axis.text.y = element_text(size=20))


grad_by_county_btm <- tn_socioeconomics %>% 
  group_by(county_name.x) %>% 
  summarize(mean_grad= mean(grad)) %>%
  top_n(5, -mean_grad) %>%
  ungroup()

ggplot(grad_by_county_btm, aes(reorder(county_name.x, -mean_grad), mean_grad)) +
  geom_col() +
  coord_flip() +
  ylab("Graduation Rate") +
  xlab("") +
  theme(axis.text.x = element_text(size=12),
        axis.text.y = element_text(size=20))




grad_by_district <- tn_socioeconomics %>% 
  filter(county_name.x == "Anderson County") %>%
  group_by(district_name.x) %>% 
  summarize(mean_grad= mean(grad)) %>%
  top_n(5, -mean_grad) %>%
  ungroup()

ggplot(grad_by_district, aes(reorder(district_name.x, -mean_grad), mean_grad)) +
  geom_col() +
  coord_flip() +
  ylab("Graduation Rate") +
  xlab("") +
  theme(axis.text.x = element_text(size=12),
        axis.text.y = element_text(size=20))
