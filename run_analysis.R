
# LOad reshape2 package for melt Data
library(reshape2)

filename = "getdata_dataset.zip"

if(!file.exists(filename)) {
    fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileUrl, destfile = filename , method="curl")
}

if(!file.exists("UCI HAR Dataset")) {
  unzip(filename)
}

# Load features 
features <- read.table("UCI HAR Dataset/features.txt")

# Load Activity labels
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")

# Extract only the data on mean & standard deviation
featuresTarget <- grep(".*mean.*|.*std.*", features$V2)

# set features target names
featuresTarget.names <- features[featuresTarget,2]

# Make features target names more clear
featuresTarget.names <- gsub('-mean', 'Mean', featuresTarget.names)
featuresTarget.names <- gsub('-std', 'Std', featuresTarget.names)
featuresTarget.names <- gsub('[-()]', '', featuresTarget.names)

# Load the train dataset
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresTarget]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

# Load the test dataset
test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresTarget]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", featuresTarget.names)

# turn activities & subjects into factors 
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- factor(allData$subject)

# melt data with melt() function from reshape2 package
allData.melted <- melt(allData, id=c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

# A second, independent tidy data set with the average of each variable for each activity and each subject
write.table(allData.mean, "tidy.txt", row.names=F, quote = F)



