library(tidyverse)
library(dplyr)
library(caret)
library(glmnet)
library(coefplot)
library(mice)

tn_socioeconomics <- read.csv('data/tn_socioeconomics.csv')

tn_socioeconomics_numeric <- select_if(tn_socioeconomics, is.numeric)
tn_socioeconomics_numeric <- tn_socioeconomics_numeric[,!grepl('_grad|grad_|graduation|dropout', 
                                                               colnames(tn_socioeconomics_numeric))]
mice_results <- mice(tn_socioeconomics_numeric, m = 1, method = 'norm')
tn_socioeconomics_numeric <- complete(mice_results,1)

predictors <- colnames(tn_socioeconomics_numeric)

set.seed(321)
index = createDataPartition(tn_socioeconomics_numeric$grad, p = 0.75, list = FALSE)

trainSet <- tn_socioeconomics_numeric[index,]
testSet <- tn_socioeconomics_numeric[-index,]

# Predictor variables
x_train <- trainSet %>% 
  select(-grad) %>% 
  data.matrix()
x_test <- testSet %>% 
  select(-grad) %>% 
  data.matrix()
# Outcome variable
y_train <- trainSet$grad
y_test <- testSet$grad

preProcValues <- preProcess(x_train, method = c("center", "scale"))

x_trainTransformed <- predict(preProcValues, x_train)
x_testTransformed <- predict(preProcValues, x_test)

cv <- cv.glmnet(x_trainTransformed, y_train, alpha = 1)

cv$lambda.min

lasso_model <- glmnet(x_trainTransformed, y_train, alpha = 1, lambda = cv$lambda.min)

coef(lasso_model)
coefplot(lasso_model, sort='magnitude')

train_pred <- predict(lasso_model, newx = x_trainTransformed)
MAE(pred = train_pred, obs = y_train)

test_pred <- predict(lasso_model, newx = x_testTransformed)
MAE(pred = test_pred, obs = y_test)

# Ridge regression.
cv <- cv.glmnet(x_trainTransformed, y_train, alpha = 0)
ridge_model <- glmnet(x_trainTransformed, y_train, alpha = 0, lambda = cv$lambda.min)
coef(ridge_model)
coefplot(ridge_model, sort='magnitude')

train_pred <- predict(ridge_model, newx = x_trainTransformed)
MAE(pred = train_pred, obs = y_train)

test_pred <- predict(ridge_model, newx = x_testTransformed)
MAE(pred = test_pred, obs = y_test)
