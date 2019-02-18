# For project of Getting and Cleaning Data - Johns Hopkins
library(dplyr)


# this downloads data
sourcefile <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(sourcefile, "UCI HAR Dataset.zip", mode = "wb")
dataworkspace <- "UCI HAR Dataset"
unzip(zipFile)


#this reads data in train and test
train_subjs <- read.table(file.path(dataworkspace, "train", "subject_train.txt"))
train_values <- read.table(file.path(dataworkspace, "train", "X_train.txt"))
train_methods <- read.table(file.path(dataworkspace, "train", "y_train.txt"))
test_subjs <- read.table(file.path(dataworkspace, "test", "subject_test.txt"))
test_values <- read.table(file.path(dataworkspace, "test", "X_test.txt"))
test_methods <- read.table(file.path(dataworkspace, "test", "y_test.txt"))

#this reads features
features <- read.table(file.path(dataworkspace, "features.txt"), as.is = TRUE)

#this reads activities
activities <- read.table(file.path(dataworkspace, "activity_labels.txt"))
colnames(activities) <- c("activity_ID", "activity_label")


#this merges datasets
human_methods <- rbind(
  cbind(train_subjs, train_values, train_methods),
  cbind(test_subjs, test_values, test_methods)
)

# assign column names
colnames(human_methods) <- c("subject", features[, 2], "activity")


#this extracts mean and std dev
human_methods <- human_methods[, grepl("subject|activity|mean|std", colnames(human_methods))]
human_methods$activity <- factor(human_methods$activity, 
                                 levels = activities[, 1], labels = activities[, 2])


#this changes variable names
human_methodsCols <- colnames(human_methods)
human_methodsCols <- gsub("[\\(\\)-]", "", human_methodsCols)
human_methodsCols <- gsub("^f", "frequencyDomain", human_methodsCols)
human_methodsCols <- gsub("^t", "timeDomain", human_methodsCols)
human_methodsCols <- gsub("Acc", "Accelerometer_Data", human_methodsCols)
human_methodsCols <- gsub("Gyro", "Gyroscope_Data", human_methodsCols)
human_methodsCols <- gsub("Mag", "Magnitude_Data", human_methodsCols)
human_methodsCols <- gsub("Freq", "Frequency_Data", human_methodsCols)
human_methodsCols <- gsub("mean", "Mean", human_methodsCols)
human_methodsCols <- gsub("std", "Standard_Deviation", human_methodsCols)
colnames(human_methods) <- human_methodsCols


#this creates tidy dataset
FinalMeans <- human_methods %>% 
  group_by(subject, activity) %>%
  summarise_each(funs(mean))

# last output
write.table(FinalMeans, "tidy_data.txt", row.names = FALSE, quote = FALSE)