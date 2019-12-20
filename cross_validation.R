library(tidyverse)
library(dplyr)
library(mice)
library(caret)
library(mlbench)

tn_socioeconomics <- read.csv('data/tn_socioeconomics.csv')

tn_socioeconomics_numeric <- select_if(tn_socioeconomics, is.numeric)
tn_socioeconomics_numeric <- tn_socioeconomics_numeric[,!grepl('_grad|grad_|graduation|dropout', 
                                                               colnames(tn_socioeconomics_numeric))]
mice_results <- mice(tn_socioeconomics_numeric, m = 1, method = 'norm')
tn_socioeconomics_numeric <- complete(mice_results,1)


# load the dataset
#data(PimaIndiansDiabetes)

# prepare training scheme
control <- trainControl(method="repeatedcv", number=10, repeats=3)

# train the GLM model
set.seed(7)
model_glm <- train(grad~., data=tn_socioeconomics_numeric, method="glm", trControl=control)

# train the RF model
set.seed(7)
model_rf <- train(grad~., data=tn_socioeconomics_numeric, method="rf", trControl=control, verbose=FALSE)

# train the SVM model
set.seed(7)
model_svm <- train(grad~., data=tn_socioeconomics_numeric, method="svmRadial", trControl=control)

# train the LM model
set.seed(7)
model_lm <- train(grad~., data=tn_socioeconomics_numeric, method="lm", trControl=control)

# collect resamples
results <- resamples(list(GLM=model_glm, RF=model_rf, SVM=model_svm, LM=model_lm))

# summarize the distributions
summary(results)

# dot plots of results
dotplot(results)

# boxplots of results
bwplot(results)
