library(censusapi)
library(tidyverse)
library(readxl)
library(mice)
readRenviron(".Renviron")
census_key <- Sys.getenv("CENSUS_KEY")
# Get census data for poverty rate est. and median income per household est.
saipe <- getCensus(name = "timeseries/poverty/saipe",
                   vars = c("STABREV",
                            "NAME",
                            "SAEMHI_PT",
                            "SAEPOVRTALL_PT"), 
                   region = "county", 
                   regionin = "state:47",
                   time = 2015)
names(saipe) <- c("year", "state_code", "county_code", "state", "county", 
                  "median_household_income_estimate", 
                  "all_ages_poverty_rate_estimate")
saipe$county_code <- as.numeric(saipe$county_code)
# Additional education metrics.
tvaas <- read_csv("data/tvaas.csv")
names(tvaas) <- c("district_number", "district_name","composite", "literacy", "numeracy")
# Additional education metrics.
districts <- read_csv("data/districts.csv")
# Count of population broken down by marital groups.
acs_marital_group <- getCensus(name = "acs/acs5", 
                               vintage = 2015, 
                               vars = c("NAME",
                                        "B06008_001E",
                                        "B06008_002E",
                                        "B06008_003E",
                                        "B06008_004E",
                                        "B06008_005E",
                                        "B06008_006E",
                                        "B06008_007E",
                                        "B06008_008E"), 
                               region = "county", 
                               regionin = "state:47")
names(acs_marital_group) <- c("state_code", "county_code", "county_name",
                              "est_count_total",
                              "est_count_total_never_married",
                              "est_count_total_now_married_except_separated",
                              "est_count_total_divorced",
                              "est_count_total_separated",
                              "est_count_total_widowed",
                              "est_count_total_born_in_state_of_residence",
                              "est_count_total_born_in_state_of_residence_never_married")
acs_marital_group$county_code <- as.numeric(acs_marital_group$county_code)
# Dataset for crossing district level and county level data.
crosswalk <- read_excel("data/data_district_to_county_crosswalk.xls")
names(crosswalk) <- c("county_number", "county_name", "district_number")
# Dataset for graduation rates
graduation <- read_csv("data/data_2015_District-Attendance-and-Graduation.csv")
names(graduation) <- c("school_year",
                       "district",
                       "district_name",
                       "k_8_attendance_rate_pct",
                       "k_8_promotion_rate_pct",
                       "state_goal_attendance_rate",
                       "state_goal_promotion_rate",
                       "attendance_rate_pct",
                       "cohort_dropout_pct",
                       "graduation_rate_nclb_pct",
                       "event_dropout_pct",
                       "all_grad_rate",
                       "white_grad_rate",
                       "african_american_grad_rate",
                       "hispanic_grad_rate",
                       "asian_grad_rate",
                       "native_american_grad_rate",
                       "hawaiian_pacisld_grad_rate",
                       "male_grad_rate",
                       "female_grad_rate",
                       "economically_disadvantaged_grad_rate",
                       "students_with_disabilities_grad_rate",
                       "limited_english_proficient_grad_rate")
tn_socioeconomics <- crosswalk %>%
  inner_join(tvaas, by = "district_number") %>%
  inner_join(districts, by = c("district_number" = "system")) %>%
  inner_join(saipe, by = c("county_number" = "county_code")) %>%
  inner_join(acs_marital_group, by = c("county_number" = "county_code")) %>%
  inner_join(graduation, by = c("district_number" = "district"))

tn_socioeconomics <- select_if(tn_socioeconomics, is.numeric)
tn_socioeconomics <- tn_socioeconomics[,!grepl('_grad|grad_|graduation|dropout', 
                                                               colnames(tn_socioeconomics))]
mice_results <- mice(tn_socioeconomics, m = 1, method = 'norm')
tn_socioeconomics <- complete(mice_results,1)

#tn_socioeconomics[is.na(tn_socioeconomics)] <- 0
##############################Train/Test Split########################################
##############################Train/Test Split########################################
##############################Train/Test Split########################################
library(tidyverse)
tn_socioeconomics["never_married_per_capita"] <- tn_socioeconomics["est_count_total_never_married"]/tn_socioeconomics["est_count_total"]
tn_socioeconomics["married_not_sep_per_capita"] <- tn_socioeconomics["est_count_total_now_married_except_separated"]/tn_socioeconomics["est_count_total"]
tn_socioeconomics["divorced_per_capita"] <- tn_socioeconomics["est_count_total_divorced"]/tn_socioeconomics["est_count_total"]
tn_socioeconomics["separated_per_capita"] <- tn_socioeconomics["est_count_total_separated"]/tn_socioeconomics["est_count_total"]
tn_socioeconomics["widowed_per_capita"] <- tn_socioeconomics["est_count_total_widowed"]/tn_socioeconomics["est_count_total"]
tn_socioeconomics["born_in_state_of_residence_per_capita"] <- tn_socioeconomics["est_count_total_born_in_state_of_residence"]/tn_socioeconomics["est_count_total"]
tn_socioeconomics["born_in_state_of_residence_never_married_per_capita"] <- tn_socioeconomics["est_count_total_born_in_state_of_residence_never_married"]/tn_socioeconomics["est_count_total"]
#graduates <- read_csv("data/kc_house_data.csv")
tn_socioeconomics_numeric <- select_if(tn_socioeconomics, is.numeric)
predictors <- colnames(tn_socioeconomics_numeric)
#the usual predictors
#predictors <- c("composite",	"literacy",	"numeracy",	"alg_1",	"alg_2",	"bio",	"chem",	"ela",	"eng_1",	"eng_2",	"eng_3",	"math",	"science",	"enrollment",	"black",	"hispanic",	"native",	"el",	"swd",	"ed",	"expenditures",	"act_composite",	"chronic_abs",	"suspended",	"expelled",	"median_household_income_estimate",	"all_ages_poverty_rate_estimate","never_married_per_capita","married_not_sep_per_capita","divorced_per_capita","separated_per_capita","widowed_per_capita","born_in_state_of_residence_per_capita","born_in_state_of_residence_never_married_per_capita")

# Possible Dpendent variables: "grad",	"dropout",
#slice down to only the predictor and response variables
tn_socioeconomics <- tn_socioeconomics %>%
  select(c(predictors, "grad"))

library(caret)
tn_socioeconomics <- select_if(tn_socioeconomics, is.numeric)
set.seed(321)
index = createDataPartition(tn_socioeconomics$grad, p = 0.75, list = FALSE)

trainSet <- tn_socioeconomics[index,]
testSet <- tn_socioeconomics[-index,]

library(glmnet)

x_train <- trainSet %>% 
  select(-grad) %>% 
  data.matrix()
x_test <- testSet %>% 
  select(-grad) %>% 
  data.matrix()
# Outcome variable
y_train <- trainSet$grad
y_test <- testSet$grad

######################LASSO Regression########################################
######################LASSO Regression########################################
######################LASSO Regression########################################
preProcValues <- preProcess(x_train, method = c("center", "scale"))

x_trainTransformed <- predict(preProcValues, x_train)
x_testTransformed <- predict(preProcValues, x_test)
cv <- cv.glmnet(x_trainTransformed, y_train, alpha = 1)

cv$lambda.min
lasso_model <- glmnet(x_trainTransformed, y_train, alpha = 1, lambda = cv$lambda.min)
coef(lasso_model)
library(coefplot)
coefplot(lasso_model, sort='magnitude')
train_pred <- predict(lasso_model, newx = x_trainTransformed)

MAE(pred = train_pred, obs = y_train)
test_pred <- predict(lasso_model, newx = x_testTransformed)
MAE(pred = test_pred, obs = y_test)


###############################################################################
###############################################################################
###############################################################################
fitControl <- trainControl(
  method = "cv",
  number = 3)

rf_fit <- train(grad ~., data = trainSet, method = "ranger",
                trControl=fitControl, importance = 'impurity')
rf_fit
train_pred <- predict(rf_fit, newdata = trainSet)
MAE(pred = train_pred, obs = trainSet$grad)

test_pred <- predict(rf_fit, newdata = testSet)
MAE(pred = test_pred, obs = testSet$grad)

rfImp <- varImp(rf_fit)

plot(rfImp)
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
# boxplots of results
bwplot(results)
# dot plots of results
dotplot(results)
