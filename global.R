#Load libraries
library(mirtCAT)
library(shinythemes)

#Needed for correct functioning
options(stringsAsFactors = FALSE)

#Specify paths
dataPath <- paste0(getwd(),"/www")
functionsPath <- paste0(dataPath,"/functions")
initPath <- getwd()

#Load functions
source(paste0(functionsPath,"/readFromURL.R"))
source(paste0(functionsPath,"/createProgressBar.R"))
source(paste0(functionsPath,"/renderFirstSessionItem.R"))

#Create folder with designs if it doesn't exist
ifelse(!dir.exists(file.path(initPath, "designs")), dir.create(file.path(initPath, "designs")), FALSE)
