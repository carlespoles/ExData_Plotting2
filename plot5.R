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

# Filter data for dataSCC in EI.Sector that has Vehicle and Mobile in order to get the SCC codes.
# First, we filter for "Mobile".
# Then by "Vehicle".
dataSCCVehicle <- subset(dataSCC, grepl("mobile", dataSCC$EI.Sector, ignore.case = TRUE))
dataSCCVehicle <- subset(dataSCCVehicle, grepl("vehicles", dataSCCVehicle$EI.Sector, ignore.case = TRUE))

# We select the records that belong to Baltimore City.
dataNEIBaltimore <- subset(dataNEI, dataNEI$fips == "24510")

# Now, we select records that have the SCC codes we need using the previous filtered data.
dataNEIFinal <- subset(dataNEIBaltimore, dataNEIBaltimore$SCC %in% dataSCCVehicle$SCC)

library(ggplot2)

# We need to have the data in aggregated format (sum emissions by year), so we use aggregate().
aggNEIData <- aggregate(dataNEIFinal$Emissions, by=list(dataNEIFinal$year), FUN=sum, na.rm=TRUE)

# To provide more descriptive names to aggNEIData:
# First, we create a vector with the names we want.
aggNEIDataNames <- c("Year", "TotalEmissions")
# Second, we pass the column names to aggNEIData.
names(aggNEIData) <- aggNEIDataNames

# Adding some margins.
par(mar=c(5.1,6.1,4.1,2.1))

# We create the plot.
qplot(Year, TotalEmissions, data=aggNEIData, xlab="Year", ylab="Total Emissions", main = "Evolution of Total Emissions for Vehicles - Baltimore City", geom = "line") + geom_point(color = "red", size = 5)

# Saving as PNG. It will be saved in default working directory.
dev.copy(png, "plot5.png", width = 600, height = 480)
dev.off()
