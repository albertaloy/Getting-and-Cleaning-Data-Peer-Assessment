
# Getting files
url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url,destfile="getdata_projectfiles_UCI HAR Dataset.zip")
unzip("getdata_projectfiles_UCI HAR Dataset.zip")

# Getting data
features = read.csv("UCI HAR Dataset/features.txt", sep="", header=FALSE)

activityLabels = read.csv("UCI HAR Dataset/activity_labels.txt", sep="", header=FALSE)

testing <- read.csv("UCI HAR Dataset/test/X_test.txt", sep="", header=FALSE)
testing[,562] <- read.csv("UCI HAR Dataset/test/Y_test.txt", sep="", header=FALSE)
testing[,563] <- read.csv("UCI HAR Dataset/test/subject_test.txt", sep="", header=FALSE)

training <- read.table("UCI HAR Dataset/train/X_train.txt")
training[,562] <- read.csv("UCI HAR Dataset/train/Y_train.txt", sep="", header=FALSE)
training[,563] <- read.csv("UCI HAR Dataset/train/subject_train.txt", sep="", header=FALSE)

# Adapt features to R doing substitutions
features[,2] = gsub('-mean', 'Mean', features[,2])
features[,2] = gsub('-std', 'Std', features[,2])
features[,2] = gsub('[-()]', '', features[,2])

# Merge training and test sets together
allData = rbind(training, testing)

# Get only the data on mean and std. dev.
cols <- grep(".*Mean.*|.*Std.*", features[,2])
features <- features[cols,]
# Add the last two columns (subject and activity) and remove the unwanted columns from allData
cols <- c(cols, 562, 563)
allData <- allData[,cols]

# Add the column names (features) to allData
colnames(allData) <- c(features$V2, "Activity", "Subject")
colnames(allData) <- tolower(colnames(allData))

currentActivity = 1
for (currentActivityLabel in activityLabels$V2) {
  allData$activity <- gsub(currentActivity, currentActivityLabel, allData$activity)
  currentActivity <- currentActivity + 1
}

allData$activity <- as.factor(allData$activity)
allData$subject <- as.factor(allData$subject)

tidy = aggregate(allData, by=list(activity = allData$activity, subject=allData$subject), mean)

# Remove the subject and activity column, since a mean of those has no use
tidy[,90] = NULL
tidy[,89] = NULL
write.table(tidy, "tidy.txt", sep="\t")