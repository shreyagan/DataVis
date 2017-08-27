# CLIMATE DATA VISUALIZATION PROJECT 
# SHREYA GANESHAN

# -------------------------------- GLOBAL CO2 EMISSIONS -------------------------------- 

# obtain data from World Bank Indicators Database
# http://databank.worldbank.org/data/reports.aspx?source=world-development-indicators&preview=on
# database: world development indicators
# country: world
# series: CO2 emissions (kt)
# time: 1960-2016
# download options: csv
# database will download a zip folder with 2 csv files (will open in Excel): 1) data 2) definition and source
# rename files so the names are shorter and are easier to understand
# move files to your working directory 

# read in dataset
worldco2 = read.csv("worldco23.csv", header = T, sep = ",")

# print the first 6 rows of the data 
head(worldco2)

# clean the dataset
# create a table with 2 columns: 1) time 2) worldco2

# delete columns by setting them to NULL
worldco2$Country.Name = NULL
worldco2$Country.Code = NULL
worldco2$Series.Code = NULL
worldco2$Series.Name = NULL
head(worldco2)
tail(worldco2)

# make sure that only the first row of data remains for you to work with 
worldco2 = worldco2[1,]
head(worldco2)
# transpose data such that the rows become columns and columns become rows
worldco2_2 = data.frame(t(worldco2))
worldco2_2

# only worldco2 column (2nd column) is saved as a vector X1

# number of observations in the data vector (X1)
length(worldco2_2$X1) #57

# delete the last 3 rows beacuse there is no 2014-2016 data
worldco2_3 = data.frame(worldco2_2[1:54,])
worldco2_3
head(worldco2_3)
worldco2_3[,1]

worldco2_4 = data.frame(worldco2_3[,1])
worldco2_4
head(worldco2_4)
tail(worldco2_4)
length(worldco2_4) #1 - therefore, it is stored as a string of characters not a matrix; fix this below

#populating a matrix of 54 rows to store the co2 data
co2 = matrix(worldco2_4, nrow = 54, ncol = 1)
for (i in 1:54) {
  co2 = matrix(worldco2_4$worldco2_3...1., nrow = 54, ncol = 1)
}

# since as.matrix will not necessarily convert any arbitrary data.frame to numeric,
## convert the matrix elements into numeric types 
# is.numeric(co2) ---> will initially return false 
# is.character(co2) ---> will initially return true
dims = dim(co2)
co2 = as.numeric(co2)
dim(co2) = dims 
dims

# now, co2 is a numeric matrix
is.numeric(co2)
is.matrix(co2)

# adding years corresponding to the emissions data points - don't need a loop for this
year = matrix(1960:2013, nrow = 54, ncol = 1)
year

# combining the years and co2 columns 
co2_full = cbind(year, co2)
co2_full

# adding column names to the co2_full matrix
colnames(co2_full) = c("year" , "co2")
co2_full

# creating the FINAL co2 dataset 
co2_full = data.frame(co2_full)
co2_full

# plotting world c02 emissions
plot(co2_full, xlab = "Year", ylab = "Global CO2 emissions (kt)", 
     main = "Global CO2 Emissions from 1960-2013", type = "l", col = "blue")
