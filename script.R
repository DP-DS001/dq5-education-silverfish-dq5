library(censusapi)
readRenviron(".Renviron")
census_key <- Sys.getenv("CENSUS_KEY")

apis <- listCensusApis()
View(apis)

saipe_vars <- listCensusMetadata(name = "timeseries/poverty/saipe/schdist", 
                                 type = "variables")
View(saipe_vars)

saipe_geo <- listCensusMetadata(name = "timeseries/poverty/saipe/schdist", 
                                 type = "geography")
View(saipe_geo)

saipe <- getCensus(name = "timeseries/poverty/saipe",
                    vars = c("COUNTY",
                             "GEOID",
                             "NAME",
                             "SAEMHI_LB90",
                             "SAEMHI_MOE",
                             "SAEMHI_PT",
                             "SAEMHI_UB90",
                             "SAEPOV0_17_LB90",
                             "SAEPOV0_17_MOE",
                             "SAEPOV0_17_PT",
                             "SAEPOV0_17_UB90",
                             "SAEPOV0_4_LB90",
                             "SAEPOV0_4_MOE",
                             "SAEPOV0_4_PT",
                             "SAEPOV0_4_UB90",
                             "SAEPOV5_17R_LB90",
                             "SAEPOV5_17R_MOE",
                             "SAEPOV5_17R_PT",
                             "SAEPOV5_17R_UB90",
                             "SAEPOVALL_LB90",
                             "SAEPOVALL_MOE",
                             "SAEPOVALL_PT",
                             "SAEPOVALL_UB90",
                             "SAEPOVRT0_17_LB90",
                             "SAEPOVRT0_17_MOE",
                             "SAEPOVRT0_17_PT",
                             "SAEPOVRT0_17_UB90",
                             "SAEPOVRT0_4_LB90",
                             "SAEPOVRT0_4_MOE",
                             "SAEPOVRT0_4_PT",
                             "SAEPOVRT0_4_UB90",
                             "SAEPOVRT5_17R_LB90",
                             "SAEPOVRT5_17R_MOE",
                             "SAEPOVRT5_17R_PT",
                             "SAEPOVRT5_17R_UB90",
                             "SAEPOVRTALL_LB90",
                             "SAEPOVRTALL_MOE",
                             "SAEPOVRTALL_PT",
                             "SAEPOVRTALL_UB90",
                             "SAEPOVU_0_17",
                             "SAEPOVU_0_4",
                             "SAEPOVU_5_17R",
                             "SAEPOVU_ALL",
                             "STABREV",
                             "STATE",
                             "SUMLEV",
                             "YEAR"), 
                    region = "county", 
                    regionin = "state:47",
                    time = 2014)
View(saipe)
