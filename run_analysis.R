

require("data.table") # RUn install.packages("data.table") if it isn't already installed
require("dplyr") # Run install.packages("dplyr") if it isn't already installed


# run_analysis.R by David Sky ( david.s.toronto@gmail.com ) October 2015 - v1.00
#

saveTempFilesDebug <- T

# Steps:
#   1. Merge training and test sets to create one data set
#        1.1 load and merge all the details for the training set
#        1.2 load and merge all the details for the test set
#        1.3 merge the merged sets from 1.1. and 1.2.
#   2. Extract mean and standard deviation for each measurement
#

# Functions

readAndMerge <- function(folderName, featureNames, featuresToExtract, activityLabels) {
    # folderName parameter is either 'Input is either 'test' or 'train'
    
    # To-do: For some reason I can't build the string... sigh
    # xFilename <- cat('"', "UCI HAR Dataset/", folderName, "/X_", folderName, ".txt", '"', sep="")
    # results in an error in the read.table call
    # xFileName <- file.path("UCI HAR Dataset", folderName, "X_test.txt") is a start...
    
    # Plan B - hard code this
    if (folderName == "test") {
        xFileName <- "UCI HAR Dataset/test/X_test.txt"
        yFileName <- "UCI HAR Dataset/test/y_test.txt"
        sFileName <- "UCI HAR Dataset/test/subject_test.txt"
    } else {
        xFileName <- "UCI HAR Dataset/train/X_train.txt"
        yFileName <- "UCI HAR Dataset/train/y_train.txt"
        sFileName <- "UCI HAR Dataset/train/subject_train.txt"        
    }
    
    # Read our three txt files
    xTD <- read.table(xFileName)
    yTD <- read.table(yFileName)
    sTD <- read.table(sFileName)
    
    # And do the merge - cbin the activities and subjects (???)
    
    # First, update all the column names in xTD
    names(xTD) <- featureNames
    if(saveTempFilesDebug) write.table(xTD, file="test-10-updated-names-xTD.txt") # For debugging purposes
    
    
    # We only want mean and standard deviation
    if(saveTempFilesDebug) write.table(xTD, file="test-12-xTD-prenames.txt") # For debugging purposes
    # featuresToExtract is a list of TRUE and FALSE values corresponding to the feature names that include either std or mean
    xTD <- xTD[,featuresToExtract]
    if(saveTempFilesDebug) write.table(xTD, file="test-13-xTD-postnames.txt") # For debugging purposes
    
    # Now add in the activity lables
    yTD[,2] = activityLabels[yTD[,1]]
    names(yTD) <- c("Activity_ID", "Activity_Label")
    names(sTD) <- "subject"
    
    # Finaly, we can use cbind to merge this all together
    finalData <- cbind(as.data.table(sTD), yTD, xTD)
    
    
    return(finalData) # Return this one data set
}

# Main script

# Load the activity lables from the text file, but we only want the second column
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")[,2]

# Load the data column names to use later on, but we only want the second column
featureNames <- read.table("UCI HAR Dataset/features.txt")[,2]

# Only need a subset of features for each measurement - mean and standard deviation
# So generate a list of TRUE and FALSE for each column name in the features list, using grep
featuresToExtract <- grepl("mean|std", featureNames)

# Repeat the same process twice, once for the test data, once for the train data
testingSetInp  <- readAndMerge("test", featureNames, featuresToExtract, activityLabels)
# if(saveTempFilesDebug) write.table(testingSetInp, file="test-testingSetInp.txt") # for debugging purposes

trainingSetInp <- readAndMerge("train", featureNames, featuresToExtract, activityLabels)
if(saveTempFilesDebug) write.table(trainingSetInp, file="test-trainingSetInp.txt") # for debugging purposes

# And now merge these two sets together
allData <- rbind(testingSetInp, trainingSetInp)
if(saveTempFilesDebug) write.table(allData, file="test-allData.txt") # for debugging purposes

# Now we have a cleaner, complete input dataset, time to do the calculations
# to produce 'a text file that contains the average value for each unique combination of 
# subject together with activity together with features.'
# Subject Activity measurement1mean measurement2mean.... measurementXstd...

# Will use dplyr: https://cran.rstudio.com/web/packages/dplyr/vignettes/introduction.html
# dplyr arrange() to get the data together?
# dplyr group_by() the two required columns subject and activity
# dplyr sumarise_each()

tidyData <- allData %>%
    group_by(subject, Activity_Label)

# And write the final result
write.table(tidyData, file="output_data.txt", sep="\t")


