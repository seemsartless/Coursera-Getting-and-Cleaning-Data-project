# Readme for my Coursera Getting and Cleaning Data project

I created this repo to store and share my files for the Coursera Getting and Cleaning Data project

### Prerequisites
- the script uses the data.table R package
- download and uncompress the files from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip including the 'UCI HAR Dataset' folder

### Running the script
1. Uncompress the zip file mentioned in the Prerequisites
2. Store the ```run_analysis.R``` script in the same folder that contains the ```UCI HAR Dataset``` folder 
3. Run the ```run_analysis.R``` script - if you are using RStudio you would follow these steps:
  1. Set the working directory to the folder in step 2. above with the ```setwd()``` function
  2. Run the script with the ```source("run_analysis.R")``` command
  3. Verify the final, tidy output in the file ```output_data.txt```

### Files in the repo
- ```run_analysis.R``` - my R program to analyse the input data files and create a tidy output data file 
- ```CodeBook.mda``` - a code book that describes the variables, the data, and the transformations the script does to clean up the data
- ```README.md``` - this file!

