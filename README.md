# Getting-and-Cleaning-Data-Assignment
Files for the Coursera Getting and Cleaning Data Assignment

This repo contains the following files:
-'README.md':This document
-'Codebook.txt': Gives a brief explanation of the variables in the output of 'run_analysis.R'
-'run_analysis.R'

This script can be considered to be in 6 different sections to read the data into R and then complete the 5 tasks listed in the assignment and has been commented as such. 

1. Reading the data
2. Merge the training and test data sets
3. Extract only the measurements on the mean and standard deviation for each measurement
4. Use descriptive activity names instead of categorical codes
5. Appropriately label the dataset with descriptive variable names
6. Output a table that give the mean of each variable by activity and subject number

## Reading the data
The script will run so long as the zipped data are extracted to a folder named "UCI HAR Dataset" located in the working director. Each of these is read into R with the read.table() command. 

## Merge the training and test data sets
Despite the name of the instruction, there's no need to use the merge() command. The two data sets have identical variables. The two data sets are both absent two important variables, "activity" and "subject". These are first added to the test and train data sets respectively using cbind. The resulting sets are then combined using rbind(). 

## Extract only the measurements on the mean and standard deviation for each measurement. 
In the actual data set, the variables are not named, but their labels are contained in "features.txt" which was read into R during the first portion of the script. A vector "header" is created using "subject", "activity", and the names from the "features.txt" data file. The grep() command then matches the indices of header that contain "mean()" or "std()" and stores the result to "meanstdcols". (the values 1, 2, are the first two elements of this vector. From the previous step you may noted that header[3] == features[1,2]) Meanstdcols can then be used to subset the data. This same vector can be used to subset "header" so names for the dataset are also assigned at this point. 
There are other features that contain the word "mean" in their name. One set of these are mutations of mean data using angle(). The other is features that obtain a mean frequency of other data. These did not seem to me to means or standard deviations of measurements so they are not extracted. 

## Use descriptive activity names instead of categorical codes
A new function, uncode(), is defined. This takes a number from 1 to 6 and substitutes the corresponding activity name. sapply() is then used on the activity variable to achieve the desired result. 

## Appropriately label the dataset with descriptive variable names
Nothing clever here. Labels are rewritten with a series of sub() commands. 
The following principles were kept in mind. 
1. Only lowercase text in variables names without any '-' or whitespace
2. Shorthands are replaced with long-form words, i.e., t->timedomain, Acc->accelerometer

## Output a table that gives the mean of each variable by activity and subject number
Finally we use dplyr grammar to group the data by activity and subject and summarize the variables with the mean command. The output file uses write.csv and outputs "summary.csv"
