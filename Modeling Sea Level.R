# CLIMATE DATA VISUALIZATION PROJECT 
# SHREYA GANESHAN

# -------------------------------- SEA LEVEL -------------------------------- 

# obtain data from UNEP Data Explorer
# http://ede.grid.unep.ch/results.php 
# dataset: global mean sea level (NOAA/LSA) 
# compiled by: National Oceanic and Atmospheric Administration (NOAA) / Laboratory for Satellite Altimetry
# units: global mean sea level change in mm of mean sea level 

# TABLE tab to see an overview of the data, notice that there is no data value for 2015
# DOWNLOAD DATA tab – save as Microsoft excel
# databse will prepare spreadsheet, then hit “click here” to download
# go to 3rd sheet on Excel file called “Gobal”
# the Active Sheet as a CSV file
# rename the file something pithy

# read in data
sealevel = read.csv("UNEP_global_sea_level.csv", sep = ",", header = T)
sealevel

# we can see that the data runs from 1992 - 2014
# there seems to be only 1 row of data - horizontally organized

# save as a matrix
sealevel = matrix(sealevel)
sealevel = t(sealevel) # transposes the data so it reads vertically 
sealevel
sealevel = t(sealevel)
sealevel
# we only want rows 2-24
# row 1 contains the heading "global"
sealevel_2 = matrix(sealevel[(2:24),1], nrow = 23, ncol = 1)
sealevel_2

# adding years corresponding to the data points - don't need a loop for this
year = matrix(1992:2014, nrow = 23, ncol = 1)
year

# creating the final dataframe
sealevel_3 = cbind(year, sealevel_2)
sealevel_3
colnames(sealevel_3) = c("year" , "sea_level")
sealevel_3

#plotting data: sea level rise (global mean sea level change in mm of mean sea level)
plot(sealevel_3, xlab = "Year", ylab = "Mean Sea Level Change (mm)", 
     main = "Global Mean Sea Level Change 1992-2014", type = "l", col = "green")