# SHREYA GANESHAN 
# R SPATIAL ANALYSIS TUTORIAL

# Download relevant data from: https://github.com/Robinlovelace/Creating-maps-in-R
# Load GGPLOT2 Package
library(ggplot2)

# Install Other packages
x = c("ggmap", "rgdal", "rgeos", "maptools", "dplyr", "tidyr", "tmap")
install.packages(x)
lapply(x, character.only = T)

# ------------------ LONDON SPORT DATA -------------------
# there are several shapefiles (made up of several different files: .prj, .dbf, .shp)

# use rgdal packasge to read london sport data using readOGR function
#rgdal is R’s interface to the “Geospatial Abstraction Library (GDAL)” which is used by other open source
 ## GIS packages such as QGIS and enables R to handle a broader range of spatial data formats

# install the rgdal pacakage  
library(rgdal)

# loading a shapefile and assigning it to a new spatial object called "lnd"
# readOGR accepts 2 arguments: 1) dsn = data source name and directory; 2) layer = file name (no need to include extension (e.g. ".shp"))
# don't have to specify "dsn" or "type", would automatically pick it up
# but good practice to include argument names
lnd = readOGR(dsn = "data", layer = "london_sport")

# spatial data/objects overview: 
# made up of several slots: 
# 1) @data - nongraphic attribute data
# 2) @polygons (or @lines) for the line data
# data slot = an attribute table; geometry slot = polygons making up physical boundaries
# specific slots accessed using @

# analyzing london sport object with basic commands
head(lnd@data, n = 2) # 2 lines
mean(lnd$Partic_Per) # OR mean(lnd@data$Partic_Per)

# @ --> calls the data slot of lnd object
# $ --> Partic_Per column (variable in head output table) in data slot
# head --> shows first 2 lines of data; default is 6 lines
# mean --> mean sports participation per 100 ppl for zones in London
# must be dealing with numeric data for mean to work 

# can check all classes of all vars in dataset
sapply(lnd@data, class)
# if Pop_2001 was a "factor" could coerce it into numeric format: 
## lnd$Pop_2001 = as.numeric(as.character(lnd$Pop_2001))

# can explore the lnd object further by with 
nrow(lnd) # 33 rows
ncol(lnd) # 4 col

# basic plotting
# uses geometry data using polygons slot
plot(lnd)

# plot function changes behavior depending on the input 
# --> polymorphism

plot(lnd@data) # totally different plot!!!, using plots non-graphical variables 

# subsetting the numerical data 
lnd@data[lnd$Partic_Per < 15, ]
# selects only the rows from lnd object where sports participation is less than 15
## rows: 17, 21, 32
### [rows, columns]
#### @data using numeric attribute data slot only

# subsetting spatial objects using the geometry slot
# select zones where sports participation is between 20%-25%
sel = lnd$Partic_Per < 25
plot(lnd[sel, ])
head(sel) # TRUE or FALSE which satisfies the conditional sel statement
# plot displays the areas that meet this criteria

# displaying which are the sportier areas relative to all other areas (>25%)
# add in "add = TRUE"
# col --> adds color 
plot(lnd[sel, ], col = 'light blue', add = TRUE)
# light blue areas are areas with 20-25% sportiness
# use "&" to experiment with multiple criteria

plot(lnd, col = "lightgrey") # full map
sel2 = lnd$Partic_Per > 25
plot(lnd[sel2, ], col = "light blue", add = TRUE)
# only those areas with (high) participation above 25% highlighted in blue

#Congratulations! You have just interrogated and visualised a spatial object: where are areas with high levels
## of sports participation in London?

# CHALLENGE: Select all zones whose geographic centroid lies within 10 km of the geographic
## centroid of inner London.
# SOLUTION: file.edit("intro-spatial.Rmd") OR github.com/Robinlovelace/Creating-maps-in-R/blob/master/README.Rmd

library(rgeos)
# rgeos: R's interface to the powerful vector processing library geos

plot(lnd, col = "grey") # full map 

# finding London's geographic centroid
# add ", byid = T" for all
plot(lnd, col = "grey", byid = T)
cent_lnd =gCentroid(lnd[lnd$name == "City of London",])
points(cent_lnd, cex = 3)

# setting a 10km buffer
lnd_buffer = gBuffer(spgeom = cent_lnd, width = 10000)
# why several warnings? 
# default width is in meters

# method 1: subsetting using intersecting zones 
lnd_central = lnd[lnd_buffer, ] #selection is too big
# test selection for method 1
plot(lnd_central, col = "lightblue", add = T)
plot(lnd_buffer, add = T) # some areas just touch the buffer

# method 2: subsetting using only points within 10km buffer
lnd_cents = SpatialPoints(coordinates(lnd), 
                          proj4string = CRS(proj4string(lnd)))
sel = lnd_cents[lnd_buffer,] # selecting pts inside buffer
points(sel) # displaying where points are located
lnd_central = lnd[sel,] # selecting zones intersecting with sel
plot(lnd_central, add = TRUE, col = "lightslateblue", border = "grey")
plot(lnd_buffer, add = TRUE, border = "red", lwd = 2)

# add text to plot
text(coordinates(cent_lnd), "Central\nLondon")

# Selecting Quadrants

# find the centre of the london area
easting_lnd = coordinates(gCentroid(lnd))[[1]]
northing_lnd = coordinates(gCentroid(lnd))[[2]]

# testing whether or not a coordinate is east or north of the centre
east = sapply(coordinates(lnd)[,1], function(x) x > easting_lnd)
north = sapply(coordinates(lnd)[,2], function(x) x > northing_lnd)

# test if the coordinates is east and north of the centre
lnd$quadrant = "unknown"
lnd$quadrant[east & north] = "northeast"

# CHALLENGE: Based on the the above code as refrence try and find the
## remaining 3 quadrants and colour them as per Figure 6. 
### Hint - you can use the llgridlines function in order to 
#### overlay the long-lat lines. For bonus points try to desolve the 
##### quadrants so the map is left with only 4 polygons.

lnd$quadrant[!east & north] = "northwest"
lnd$quadrant[east & !north] = "southeast"
lnd$quadrant[!east & !north] = "southwest"
plot(lnd)
plot(lnd[east & north,], add = TRUE, col = "red" )
llgridlines(lnd, lty= 3, side ="EN", offset = -0.5)

lnd_disolved = rgeos::gUnaryUnion(spgeom = lnd, id = lnd$quadrant)

library(tmap)
qtm(lnd, fill = "quadrant") +
  tm_shape(lnd_disolved) +
  tm_borders(lwd = 7)

# CREATING AND MANIPULATING SPATIAL DATA
# GIS operations
# join spatial and non-spatial data so it can be mapped 

# can create R objects by entering the name of the class we want to make 
# creating vector and data.frame objects
vec = vector(mode = "numeric", length = 3)
df = data.frame(x = 1:3, y = c(1/2, 2/3, 3/4))

# check the class of these new objects above 
class(vec)
class(df)

# same logic for spatial data
# input must be numeric matrix or data.frame

sp1 = SpatialPoints(coords = df) # created a spatial points object (fundamental spatial data type)
# other fundamental spatial data types: lines (SpatialLines), polygons (SpatialPolygons), pixels (SpatialPixels)
class(sp1)

# extending pre-existing object sp1 by adding data from df
spdf = SpatialPointsDataFrame(sp1, data = df)
class(spdf)
# if enter "map" instead of df in spdf object creation, would yield an error
# usually, spatial data read-in from externally-created file 
## e.g. using readOGR()

# Projections: Setting and Transforming CRS in R
# spatial data comes with an associate CRS (unlike spatial objects above)
# CRS = Coordinate Reference System 
# spatial data should always have CRS
proj4string(lnd) = NA_character_ # removes CRS information from lnd
proj4string(lnd) = CRS("+init=epsg:27700") # assign a new CRS

# normal for R to issue a warning when the CRS is changed
# this is so the user know they are changing the CRS NOT reprojecting the data
# using proj4string, 27700 represents the British National Grid
# ESPG code WGS84 (espg:4326) used commonly worldwide
# how to search all available ESPG codes and create new "lnd" version in WGS84:
ESPG = make_EPSG() # remove prior CRS information from lnd
ESPG[grep("WGS 84$", ESPG$note),] # searching for WGS 84

# reprojecting this new CRS
lnd84 = spTransform(lnd, CRS("+init=epsg:4326"))
# spTransform converts the coordinates of lnd into the WGS84 CRS, a more widely used CRS
# transformed old CRS to new, more distributable and widely used CRS
# this new data should be stored in .RData or .Rds (better) formats

# saving lnd84 object (will use later)
saveRDS(object = lnd84, file = "data/lnd84.Rds")

# can remove the lnd84 object with the "rm" command
rm(lnd84)
# can load this back in later with "readRDS(file = "data/lnd84.Rds)

# Attribute Joints
# used to link additional pieces of information to polygons
# in lnd object, there are 4 attribute variables:
names(lnd)
# can also add more variables from external sources -- will use London boroughs crime data

# reload "london_sport" shapefile as a new object and plot it:
library(rgdal) # load "rgdal" again

# create new object called "lnd" from "london_sport" shapefile
lnd = readOGR(dsn = "data", "london_sport")
plot(lnd) # plotting object
nrow(lnd) # returns that there are 33 rows

# want to join in non-spatial data of reported crimes in London
# data stored in "mps-recordedcrime-borough.csv"
# each line is a separate crime
# aggregate crimes at borough level to join to the "lnd" spatial dataset

# create and check out new "crime_data" object 
# check out the data in a spreadsheet: 
crime_data = read.csv("data/mps-recordedcrime-borough.csv", stringsAsFactors = FALSE)
head(crime_data$CrimeType) # more info about crime type

# extract "Theft & Handling" crimes and save it in a new data frame
# == to select only those observations that meet a specific condition
crime_theft = crime_data[crime_data$CrimeType == "Theft & Handling",]
head(crime_theft) # shows default 6 rows of data 
head(crime_theft, 2) # shows only 2 rows of data 
is.data.frame(crime_theft) # TRUE

# calculate sum of crime count for each district and save result 
crime_ag = aggregate(CrimeCount ~ Borough, FUN = sum, data = crime_theft)
# CrimeCount ~ Borough -> means aggregating CrimeCount BY Borough
# could not do a reverse order because Borough is not a numeric vector
head(crime_ag)

# now, we have crime data at the borough level, we need to join this with the lnd object
# use: 1) BOROUGH varaiable from "crime_ag" object
## and 2) NAME variable from "lnd" object 
### sometimes, names of objects do not match so need to be careful when joining 

# check which names in "crime_ag" object match "lnd" object (spatial)
# compare "name" coumn in "lnd" to "Borough" column in "crime_ag" to see whcih rows match 
lnd$name %in% crime_ag$Borough
# only last row doesn't match

# confirm which rows do not match 
lnd$name[!lnd$name %in% crime_ag$Borough] # only: City of London

# %in% -> identifies which values in lnd$name are also in Borough names in crime_ag
# City of London does not exist in crime_ag data (but does in lnd$names)
# reasons for this: City of London could have its own police force
## the borough name in crime_ag that does not match lnd$names --> NULL
crime_ag$Borough[!crime_ag$Borough %in% lnd$name]

# Challenge: Identify the number of crimes taking place in Borough "NULL" less than 4,000
# ******** CHECK THIS

# after having checked that one borough doesn't match, we are ready to join the data 
# spatial lnd and non-spatial crime_ag datasets 
# use the left_join function from dyplr package OR merge function
# if we don't load the package before applying a function, nothing will happen

# load dplyr package 
library(dplyr) 

# use left_join bc we want to maintain the length of the data frame 
## to remain unchanged when variables are appended with new columns
# "*join" (inner_join and anti_join) match variabels with the same name
# specify association betwen variables in 2 data sets
??left_join
# dataset we are adding to
head(lnd$name)
# the variables we want to join 
head(crime_ag$Borough)

# this will not work bc there seem to be "no common variables"
## need to specify a "by" parameter
head(left_join(lnd@data, crime_ag))
# specifiying the by parameter
lnd@data = left_join(lnd@data, crime_ag, by = c("name" = "Borough"))

# looking at new lnd@data object --> can see new vars added 
# thus, the attribute joint was successful 
# what this means: we can plot the rate of theft crimes in London BY borough
library(tmap) # loading the tmap package
qtm(lnd, "CrimeCount") # plot the basic map

# qtm = quick thematic map

# Challenge: Create a map of additional variables in London
# ******** CHECK THIS
# now, we should be able to take datasets from many aources (e.g. data.london.gov.uk) and join them to geographical data

# Clipping and Spatial Joints
# we have learned how to join by attributes (e.g. Borough name) and
## now we can learn how to join data by spatial joints

# examples using transportation infrastructure spatial data (data to join)
# goal is to join these spatial points to geographical data 

library(rgdal)
# create a new stations object using "lnd-stns" shapefile 
#stations = readOGR(dsn = "data", layer = "lnd-stns")
stations = read_shape("data/lnd-stns.shp")
proj4string(stations)
###### NOT WORKING AND NEED TO FINISH !!!!!!!!!!!!!!!

# MAKING MAPS WITH TMAP, GGPLOT2, AND LEAFLET
# tmap - helps overcome the limitations of base graphics and ggmap
library(tmap)
vignette("tmap-nutshell") # gives an overview of what tmap has to offer
# 1) TMAP 
# NEED TO ADD TO THIS 

# 2) GGMAP
# based on the ggplot2 package - an implementation of the Grammor of Graphics
# ggplot2 can replace base graphics in R with 
# its default options match good visualizations practice and are well-dcoumented

# create a scatter plot with attribute data in the lnd object
library(ggplot2)
p = ggplot(lnd@data, aes(Partic_Per, Pop_2001))
p

# real power of ggplot2 lies in its abilty to add layers to a plot - such as text 
p + geom_point(aes(colour = Partic_Per, size = Pop_2001)) + geom_text(size = 2, aes(label = name))

# the idea of layers (geoms) different from standard plots
# BUT each function does some clever stuff to make plotting easier 

# now, we will create a map to show the % of pop. in each London Borough who regularly participate in sports activities 

# ggmap requires that spatial data is supplied as a data.frame using fortify()
# generic plot() function uses Spatial* objects directly
# BUT ggplot2 cannot
# thus, we need to extract objects as a dataframe explicitly using the fortify() function
# need to install maptools or rgeos to do this

library(rgeos)
lnd_f = fortify(lnd) # regions are defined for each polygons 
# this steps loses the attribute information associated with the lnd objet 
# can add it back using the left_join function from dyplr package

head(lnd_f, n = 2) # first 2 rows of the fortified data 
lnd$id = row.names(lnd) # allocate id variables to the spatial (sp) data
lnd$id 
head(lnd@data, n = 2) # final check before attribute info is joined back in w left_join
# left_join requries a shared variable name 
lnd_f = left_join(lnd_f, lnd@data) # data is joined by "id"

# this new ldf_f object contains coordinated AND attribute info for each London Borough
# now we can produce a map with ggplot2, since we have sp and attribute data 
# coor_equal() --> same as asp = T in regular R plots 

map = ggplot(lnd_f, aes(long, lat, group = group, fill = Partic_Per)) + geom_polygon() + coord_equal() + labs(x = "Easting (m)", 
  y = "Northing (m)", fill = "% Sports\nParticipation") + 
  ggtitle("London Sports Participation")
map # return the map with default colors: blue

# done! 
# can change colors and save plots with ggsave()
map + scale_fill_gradient(low = "white", high = "black") # creates a white and black plot

