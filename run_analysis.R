#
# run_analysis.R by David Sky ( david.s.toronto@gmail.com ) October 2015 - v1.00
#

require("data.table") # RUn install.packages("data.table") if it isn't already installed
require("dplyr") # Run install.packages("dplyr") if it isn't already installed

saveTempFilesDebug <- F # Set this to T to save intermediate files along the way for debugging...

# Steps:
#   1. Load the metadata we need for processing (activity labels, feature names, etc...)
#   2. Load and process the test data set with the function readAndMerge() 
#        This includes loading the three files from disk, and cleaning them up
#        to onliy include the columns we want to work with, etc...
#   3. Repeat the above for the training data set with the function readAndMerge()
#   4. Merge the test and training data sets into one using rbind()
#   5. Summarize all the data we have down into a set of rows average value for each unique combination of 
#        subject together with activity together with features
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

### Step 1. Load metadata

# Load the activity lables from the text file, but we only want the second column
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")[,2]

# Load the data column names to use later on, but we only want the second column
featureNames <- read.table("UCI HAR Dataset/features.txt")[,2]

# Only need a subset of features for each measurement - mean and standard deviation
# So generate a list of TRUE and FALSE for each column name in the features list, using grep
featuresToExtract <- grepl("mean|std", featureNames)


### Step 2. Load test data
testingSetInp  <- readAndMerge("test", featureNames, featuresToExtract, activityLabels)
if(saveTempFilesDebug) write.table(testingSetInp, file="test-testingSetInp.txt") # for debugging purposes

###. Step 3. Load training data
trainingSetInp <- readAndMerge("train", featureNames, featuresToExtract, activityLabels)
if(saveTempFilesDebug) write.table(trainingSetInp, file="test-trainingSetInp.txt") # for debugging purposes

### Step 4. Merge test and training data
allData <- rbind(testingSetInp, trainingSetInp)
if(saveTempFilesDebug) write.table(allData, file="test-allData.txt") # for debugging purposes


### Step 5.
# Now we have a cleaner, complete input dataset, time to do the calculations
# to produce 'a text file that contains the average value for each unique combination of 
# subject together with activity together with features.'

# Will use the dplyr library: https://cran.rstudio.com/web/packages/dplyr/vignettes/introduction.html
tidyData <- allData %>%
    group_by(subject, Activity_Label) %>%
    summarise_each(funs(mean)) %>%
    arrange(subject, Activity_ID)

# And write the final result
write.table(tidyData, file="output_data.txt", sep="\t")

# Done!
