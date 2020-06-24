library(dplyr, tidyr)

### Read all relevant datafiles as separate dataframes 
#The unzipped data folder should be in the working directory
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")
features <- read.table("./UCI HAR Dataset/features.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
x_test <- read.table("./UCI HAR Dataset/test/x_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
x_train <- read.table("./UCI HAR Dataset/train/x_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")


###1. Merge the training and test sets to create one data set
#subject test/train contain a single column containing the subject variable. should be column bound to 
#y train/test contains the activity labels coded in activity_labels. the number or rows is the same as the corresponding x train/test that contains the data for each featured variable
#we will column bind these
test<-cbind(subject_test, y_test, x_test)
train <-cbind(subject_train, y_train, x_train)

mydata <- rbind(test, train)

###2. Extract only the measurements on the mean and standard deviation for each measurement

###strategy here is to look for "mean" and "std" in the features and get a vector corresponding to the indices of the appropriate columns of mydata
### features labeled with angle(...) are a mutation of other features and should not be included nor shoul meanFreq() 
header <- c("subject", "activity", as.character(features[,2]))
meanstdcols <- c(1, 2, grep("mean\\(\\)|std\\(\\)", header))

mydata <- mydata[,meanstdcols]
names(mydata) <- header[meanstdcols]
### 3. Uses descriptive activity names to name the activity in the data set

### activity labels are coded in activity labels
#1 - walking
#2 - walkingupstairs
#3 - walkingdownstairs
#4 - sitting
#5 - standing
#6 - laying

uncode <- function(x){
    descriptives <- c("walking", "walkingupstairs", "walkingdownstairs", "sitting", "standing", "laying")
    sub(x, descriptives[x], x)
} 

mydata$activity <- sapply(mydata$activity, uncode)

### 4. Appropriately labels the data set with descriptive variable names

#lowercase
#t - timedomain
#f - frequencydomain
#Acc - accelerometer
#Gyro - gyroscope
#Mag - magnitude
#Freq - frequency
##() - deleted
##- - deleted

names(mydata) <- sub("^t", "timedomain", names(mydata))
names(mydata) <- sub("^f", "frequencydomain", names(mydata))
names(mydata) <- sub("Acc", "accelerometer", names(mydata))
names(mydata) <- sub("Gyro", "gyroscope", names(mydata))
names(mydata) <- sub("Mag", "magnitude", names(mydata))
names(mydata) <- sub("\\(\\)", "", names(mydata))
names(mydata) <- gsub("-", "", names(mydata))
names(mydata) <- tolower(names(mydata))

###From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

#here we should group by activity and subject
mytable <- mydata %>% group_by(activity, subject) %>% summarise(across(everything(), mean))
mytable 
write.csv(mytable, "summary.csv", row.names = FALSE)