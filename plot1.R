setwd("C:\\Users\\Carles\\Documents\\R_data_sets")

library(httr)
# Below library is used to unzip later the file to be downloaded.
library(downloader)
# plyr library will be required for later file/data processing.
library(plyr)
fileURL <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
fileZIP <- "dataSetUCI.zip"
download.file(fileURL, destfile = paste(".\\", fileZIP, sep = ""), method = "curl")

# Once file is unzipped, it will appear in the working directory as 'Source_Classification_Code.rds' and
# 'summarySCC_PM25.rds'.
fileName <- unzip(fileZIP, list = FALSE, overwrite = TRUE, exdir = getwd())

# Object fileName will be a vector with both unzipped files:
SCC <- fileName[1]
NEI <- fileName[2]

# Downloaded files are rds, so we will read them using readsRDS function.
dataNEI <- readRDS(NEI)
# Preview the data.
head(dataNEI)
# Summary of the data.
summary(dataNEI)
# Do we have null data?
mean(is.null(dataNEI))

dataSCC <- readRDS(SCC)
head(dataSCC)
summary(dataSCC)
mean(is.null(dataSCC))

# We create a vector just the years.
dataYears <- unique(dataNEI$year)
# We create a list to store the total emissions per year.
totalEmissionYear <- tapply(dataNEI$Emissions, dataNEI$year, FUN = sum)

# We create an empty vector that will store the emissions from the previous list.
yearEmissions <- c()

# We iterate through the list to populate the vector for total emissions data.
for (i in 1:length(totalEmissionYear)) {
    
    yearEmissions[i] = totalEmissionYear[[i]]
    
}

# Setting margins for the plot.
par(mar=c(5.1,6.1,4.1,2.1))

# We create the plot => emissions are going down.
plot(dataYears, yearEmissions, pch = 19, xlab = "Year", ylab = "Total Emissions", main = "Evolution of Total Emissions", type = "b")

# Saving as PNG. It will be saved in default working directory.
dev.copy(png, "plot1.png", width = 600, height = 480)
dev.off()

