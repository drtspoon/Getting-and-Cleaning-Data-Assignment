library(dplyr, tidyr, stringr)

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

### gives an observation id (sometimes the same feature of the same activity of the same subject has the same value. This creates duplicates when separating)
id <- 1:nrow(mydata)
mydata <- cbind(id, mydata)

###2. Extract only the measurements on the mean and standard deviation for each measurement

###strategy here is to look for "mean" and "std" in the features and get a vector corresponding to the indices of the appropriate columns of mydata
### features labeled with angle(...) are a mutation of other features and should not be included nor should meanFreq() 
header <- c("id", "subject", "activity", as.character(features[,2]))
meanstdcols <- c(1, 2, 3, grep("mean\\(\\)|std\\(\\)", header))

mydata <- mydata[,meanstdcols]

header <- header[meanstdcols]
### we have a problem that column headers are values, not variables names.
### there are 2 variables, acceleration, jerk,
### Variables in the headers include domain (time or frequency), type (Gravity, Body or BodyBody(Body2)), device (accelerometer or gyroscope), dimension (x, y, z or mag), measure (mean() or std())

#dimension variable is not uniformly ordered. these commands fix that
magcols <- grep("Mag", header)
header <-gsub("Mag", "", header)
header[magcols] <-paste(header[magcols], "-Mag", sep = "")

#move jerk/acceleration to end of the label
jerkcols <- grep("Jerk", header)
accelcols <- -grep("Jerk", header)
accelcols <- c(-1, -2, -3,  accelcols)

header <-gsub("Jerk", "", header )
header[jerkcols]<-paste(header[jerkcols], "-Jerk", sep = "")
header[accelcols]<-paste(header[accelcols], "-Acceleration", sep="")

### get rid of the () after mean or std
header <- sub("\\(\\)", "", header)
### better names for value of domain
header <- sub("^t", "Time", header)
header <- sub("^f", "Frequency", header)


### adds a non-alphanumeric character between values in the column names for use with separate
header<-gsub("([a-z])([A-Z])", "\\1.\\2", header)
### gives new name to BodyBody features (these features are not described in the features_info.txt file. meanwhile features described in the info file are not present in features. I think BodyBody is a typo should be Body)
header<-gsub("Body\\.Body", "Body", header)




names(mydata)<-header
tidydata <- as_tibble(mydata) %>% 
    pivot_longer(-c(1:3), names_to = "variables", values_to = "values") %>%
    separate(variables, c("domain", "type", "device", "measure", "direction", "variable")) %>%
    unite(variable, measure, col = variable, sep = "") %>%
    spread(variable, values)

### We will have NAs for fBodyGryo-XYZ tGravAcc-(any) theses features are not included


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

tidydata$activity <- sapply(tidydata$activity, uncode)

### 4. Appropriately labels the data set with descriptive variable names
#This was done when we tidied the data in step 2


###F5 rom the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

#here we should group by activity and subject


mytable <- tidydata %>% 
    group_by(activity, subject) %>% 
    summarise(
        accelerationmean=mean(Accelerationmean), 
        accelerationstd=mean(Accelerationstd), 
        jerkmean = mean(Jerkmean, na.rm = T),
        jerkstd = mean(Jerkstd, na.rm = T))
mytable 
write.table(mytable, "summary.txt", row.names = FALSE)