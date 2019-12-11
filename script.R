library(censusapi)
library(tidyverse)
library(readxl)

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
tvaas <- read_csv('data/tvaas.csv')
names(tvaas) <- c("district_number", "district_name","composite", "literacy", "numeracy")

# Additional education metrics.
districts <- read_csv('data/districts.csv')

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
crosswalk <- read_excel('data/data_district_to_county_crosswalk.xls')
names(crosswalk) <- c("county_number", "county_name", "district_number")

tn_socioeconomics <- crosswalk %>%
                        inner_join(tvaas, by = "district_number") %>%
                        inner_join(districts, by = c("district_number" = "system")) %>%
                        inner_join(saipe, by = c("county_number" = "county_code")) %>%
                        inner_join(acs_marital_group, by = c("county_number" = "county_code"))
