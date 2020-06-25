# Getting-and-Cleaning-Data-Assignment
Files for the Coursera Getting and Cleaning Data Assignment

This repo contains the following files:
- 'README.md':This document
- 'Codebook.txt': Gives a brief explanation of the variables in the output of 'run_analysis.R'
- 'run_analysis.R'

The output of the file ‘run_analysis.R’ is a further analysis of Human Activity Recognition Using Smartphones Data Set found in the UCI Machine Learning Repository. Information regarding the dataset may be found at
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
The original data set can be downloaded at 
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

If this .zip file is extracted into your working directory, the script will run. 
This script can be considered to be in 6 different sections to read the data into R and then complete the 5 tasks listed in the assignment and has been commented as such. 

1. Reading the data
2. Merge the training and test data sets
3. Extract only the measurements on the mean and standard deviation for each measurement
4. Use descriptive activity names instead of categorical codes
5. Appropriately label the dataset with descriptive variable names
6. Output a table that give the mean of each variable by activity and subject number

## Reading the data
The script will run so long as the zipped data are extracted to a folder named "UCI HAR Dataset" located in the working directory. 

## Merge the training and test data sets
Despite the name of the instruction, there's no need to use the merge() command. The two data sets have identical variables. The two data sets are both absent two important variables, "activity" and "subject". These are first added to the test and train data sets respectively using cbind. The resulting sets are then combined using rbind(). 
This dataset now has one observation per row. We assign each row an id. This is necessary for later tidying steps. 

## Extract only the measurements on the mean and standard deviation for each measurement. 
In the actual data set, the variables are not named, but their labels are contained in "features.txt" which was read into R during the first portion of the script. A vector "header" is created using "id" "subject", "activity", and the names from the "features.txt" data file. The grep() command then matches the indices of header that contain "mean()" or "std()" and stores the result to "meanstdcols". (the values 1, 2, are the first two elements of this vector. From the previous step you may noted that header[4] == features[1,2]) Meanstdcols can then be used to subset the data. 
There are other features that contain the word "mean" in their name. One set of these are mutations of mean data using angle(). The other is features that obtain a mean frequency of other data. These did not seem to me to means or standard deviations of measurements so they are not extracted. 

A lot of data tidying is done at this point. The data are untidy because they suffer from multiple variables per column. After much thought, I decided that there should be four variables with numerical value: 
- accelearation mean 
- accelration std 
- jerk mean 
- jerk std 

This leaves several categorical variables:
- domain (time or frequency)
- type (body or gravity)
- device (accelerometer or gyroscope)
- dimension (x, y, z, or magnitude) (projection may be a better name)

The strategy for tidying the data was to first manipulate the labels in the header vector so that they were formatted to facilitate gathering and separating using tidyr grammar. For example, features with dimension = magnitude have "Mag" appearing before "mean()" or "std()". This substring is removed and "-Mag" is concatenated to the end of the label to match the format for features with dimension = X, Y, or Z. Similar procedures identify which features measure Jerk and which measure Acceleration. 

Now a tidy data frame can be constructed by gathering all the feature columns, into one column named "variables" with their values in a column named "values". These are then separated using the non-alphanumeric characters introduced earlier in this step. With the use of unite() we are left with one variable column that contains values (accelerationmean, accelerationstd, jerkmean, jerkstd). The data can then be spread on this column taking values from the value column. This final step introduces some NA that reflect features for which jerk was not measured. 

## Use descriptive activity names instead of categorical codes
A new function, uncode(), is defined. This takes a number from 1 to 6 and substitutes the corresponding activity name. sapply() is then used on the activity variable to achieve the desired result. 

## Appropriately label the dataset with descriptive variable names
This work was completed when we tidied the data as we had to assign column labels in those steps. 

## Output a table that gives the mean of each variable by activity and subject number
Finally we use dplyr grammar to group the data by activity and subject and summarize the four numerical variables with the mean command. The output file uses write.csv and outputs "summary.csv"
