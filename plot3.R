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

# Filter data for fips => 24510.
dataNEI <- subset(dataNEI, dataNEI$fips == "24510")

library(ggplot2)

# We need to have the data in aggregated format (sum emissions by year and type), so we use aggregate().
aggNEIData <- aggregate(dataNEI$Emissions, by=list(dataNEI$year, dataNEI$type), FUN=sum, na.rm=TRUE)

# To provide more descriptive names to aggNEIData:
# First, we create a vector with the names we want.
aggNEIDataNames <- c("Year", "Type", "TotalEmissions")
# Second, we pass the column names to aggNEIData.
names(aggNEIData) <- aggNEIDataNames

par(mar=c(5.1,6.1,4.1,2.1))

# We create the plot.
qplot(Year, TotalEmissions, data=aggNEIData, xlab="Year", ylab="Total Emissions", main = "Evolution of Total Emissions (per Type) - Baltimore City", facets = . ~ Type, geom = "line")

# If we want a plot without facets:
# qplot(Year, TotalEmissions, data=aggNEIData, xlab="Year", ylab="Total Emissions", main = "Evolution of Total Emissions (per Type) - Baltimore City", geom = "line", group = Type, color = Type) 

# Saving as PNG. It will be saved in default working directory.
dev.copy(png, "plot3.png", width = 600, height = 480)
dev.off()
