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

# We select the records that belong to Los Angeles County.
dataNEILA <- subset(dataNEI, dataNEI$fips == "06037")

# Now, we select records for Baltimore City that have the SCC codes we need using the previous filtered data.
dataNEIBaltimoreFinal <- subset(dataNEIBaltimore, dataNEIBaltimore$SCC %in% dataSCCVehicle$SCC)

# Now, we select records for Los Angeles County that have the SCC codes we need using the previous filtered data.
dataNEILAFinal <- subset(dataNEILA, dataNEILA$SCC %in% dataSCCVehicle$SCC)

# We create a vector just the years.
dataYearsBaltimore <- unique(dataNEIBaltimoreFinal$year)
dataYearsLA <- unique(dataNEILAFinal$year)
# We create a list to store the total emissions per year.
totalEmissionYearBaltimore <- tapply(dataNEIBaltimoreFinal$Emissions, dataNEIBaltimoreFinal$year, FUN = sum)
totalEmissionYearLA <- tapply(dataNEILAFinal$Emissions, dataNEILAFinal$year, FUN = sum)

# We create an empty vector that will store the emissions from the previous list.
yearEmissionsBaltimore <- c()
yearEmissionsLA <- c()

# We iterate through the list to populate the vector for total emissions data.
for (i in 1:length(totalEmissionYearBaltimore)) {
    
    yearEmissionsBaltimore[i] = totalEmissionYearBaltimore[[i]]
    
}

for (i in 1:length(totalEmissionYearLA)) {
    
    yearEmissionsLA[i] = totalEmissionYearLA[[i]]
    
}

par(mfrow = c(1,2))

dataRange <- range(yearEmissionsBaltimore, yearEmissionsLA, na.rm = TRUE)

plot(dataYearsBaltimore, yearEmissionsBaltimore, pch = 19, xlab = "Year", ylab = "Total Emissions", main = "Vehicle Emissions - Baltimore City", type = "b", ylim = dataRange)
plot(dataYearsLA, yearEmissionsLA, pch = 19, xlab = "Year", ylab = "Total Emissions", main = "Vehicle Emissions - LA County", type = "b", ylim = dataRange)

# Saving as PNG. It will be saved in default working directory.
dev.copy(png, "plot6.png", width = 1700, height = 480)
dev.off()
