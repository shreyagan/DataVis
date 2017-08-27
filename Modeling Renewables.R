# CLIMATE DATA VISUALIZATION PROJECT 
# SHREYA GANESHAN

# -------------------------------- RENEWABLES DEPLOYMENT -------------------------------- 

# obtain data from OECD
# https://data.oecd.org/energy/renewable-energy.htm
# perspectives: total; % primary energy supply 
# highlighted countries: World (WLD)
# select background: none
# time: yearly, 1971-2015
# download CSV (selected data only)

# read in data
renewables_percent = read.csv("renewables%.csv", sep = ",", header = T)

# preview data
head(renewables_percent)
tail(renewables_percent)
# there are 45 levels (observations) but year 2015 does not have any data

# extraneous data: columns 1-5, column 6, row 45 
renewables_percent = renewables_percent[c(1:44), c(6,7)]
colnames(renewables_percent) = c("year", "renewables_percent")
is.data.frame(renewables_percent) # true 

# final data
renewables_percent

#plotting data: renewables deployment as percent of primary energy supply
plot(renewables_percent, xlab = "Year", ylab = "% of Primary Energy Supply", 
     main = "Renewables Deployment (TPES) from 1971-2014", type = "l", col = "red")


# obtain data from OECD
# https://data.oecd.org/energy/renewable-energy.htm
# perspectives: total; thousand toe (total of oile equivalent)
# highlighted countries: World (WLD)
# select background: none
# time: yearly, 1971-2015
# download CSV (selected data only)

# read in data
renewables_toe = read.csv("renewablestoe.csv", sep = ",", header = T)

# preview data
head(renewables_toe)
tail(renewables_toe)
# there are 45 levels (observations) but year 2015 does not have any data

# extraneous data: columns 1-5, column 6, row 45 
renewables_toe = renewables_toe[c(1:44), c(6,7)]
colnames(renewables_toe) = c("year", "renewables_toe")
is.data.frame(renewables_toe) # true 

# final data
renewables_toe

#plotting data: renewables deployment in oil equivalents
plot(renewables_toe, xlab = "Year", ylab = "Thousand TOE", 
     main = "Renewables Deployment (TOE) from 1971-2014", type = "l", col = "purple")
