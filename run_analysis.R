#.......................Download file.......................#
if(!file.exists("data")){dir.create("data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="data\\Dataset.zip")


#.....................Unzip the file...................#
unzip(zipfile="./data/Dataset.zip",exdir="./data")

#.....................Get the list of the files..........#
path<- file.path("./data" , "UCI HAR Dataset")
files<-list.files(path, recursive=TRUE)
files

#.............read all related files.......................# 
ActivityTest  <- read.table(file.path(path, "test" , "Y_test.txt" ),header = FALSE)
ActivityTrain <- read.table(file.path(path, "train", "Y_train.txt"),header = FALSE)

SubjectTest  <- read.table(file.path(path, "test" , "subject_test.txt"),header = FALSE)
SubjectTrain <- read.table(file.path(path, "train", "subject_train.txt"),header = FALSE)

FeaturesTest  <- read.table(file.path(path, "test" , "X_test.txt" ),header = FALSE)
FeaturesTrain <- read.table(file.path(path, "train", "X_train.txt"),header = FALSE)

FeaturesNames <- read.table(file.path(path, "features.txt"  ),header = FALSE)
ActivityLabels <- read.table(file.path(path, "activity_labels.txt"  ),header = FALSE) 

#.............adding col names................#
colnames(ActivityTest) <- 'Activity'
colnames(ActivityTrain) <- 'Activity'

colnames(SubjectTest) <- 'Subject'
colnames(SubjectTrain ) <- 'Subject'

colnames(FeaturesTest ) <-  FeaturesNames$V2
colnames(FeaturesTrain) <- FeaturesNames$V2

colnames(ActivityLabels ) <-c('Activity','ActivityDescription')

#.............Merges the training and the test sets to create one data set...........#
Train<-cbind(SubjectTrain,ActivityTrain,FeaturesTrain)
Test<-cbind(SubjectTest,ActivityTest,FeaturesTest )
data<-rbind(Train, Test)

#................Extracts only the measurements on the mean and standard deviation for each measurement...........#
data<-data[,c(1,2,grep("mean\\(\\)|std\\(\\)",names(data)))]

#..............Uses descriptive activity names to name the activities in the data set............#
data<-merge(data,ActivityLabels,'Activity')

#................. Sorting...............#
data<-data[,-1]
#..................reorder columns ...............#
data <- data[c(1,68,2:67)]
#..........order by subject, ActivityDescription.............#
data<-data[order(data$Subject,data$ActivityDescription),]

#..........Appropriately labels the data set with descriptive variable names..........#
names(data) <- gsub("\\(\\)", "", names(data)) 
names(data) <- gsub("mean", "Mean",  names(data)) 
names(data) <- gsub("std", "Std", names(data)) 
names(data) <- gsub("-", "",  names(data))

#................ Write cleaned file ...............# 
write.table(data, "cleandata.txt") 

#............From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject...............#
data2<-aggregate(. ~data$Subject+data$ActivityDescription, data[, 3:68], mean)
write.table(data2, file = "tidydata.txt",row.name=FALSE)
