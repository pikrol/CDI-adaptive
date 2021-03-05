library(mirtCAT)
library(shinythemes)
library(tidyverse) #add_row method
library(lubridate) #dates
options(stringsAsFactors = FALSE)

#Specify paths
dataPath <- paste0(getwd(),"/www")
functionsPath <- paste0(dataPath,"/functions")
initPath <- getwd()

#Load functions
source(paste0(functionsPath,"/readFromURL.R"))
source(paste0(functionsPath,"/renderDemographicPage.R"))
source(paste0(functionsPath,"/startTest.R"))
source(paste0(functionsPath,"/checkStop.R"))
source(paste0(functionsPath,"/createProgressBar.R"))

#Prepare folder with designs
if (!dir.exists(file.path(initPath, "designs"))) dir.create(file.path(initPath, "designs"))

#Prepare subjects table
subjectsFile <- "subjects.csv"
if (!file.exists(subjectsFile)){
  subjects <<- data.frame(id = "test", birth = NA, gender = NA, test = NA, prevTheta = NA)
  write.csv(subjects, subjectsFile, row.names = F)
} else {
  subjects <<- read.csv(subjectsFile, encoding = "UTF-8")
}