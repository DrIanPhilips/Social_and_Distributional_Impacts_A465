#mapping A465 study area 
#to make interactive maps 
#which students can look at in a browser.  

library(sf)
library(tidyverse)
library(tmap)
library(tmaptools)


#-read data
#Welsh Index of multiple deprivation for Belanau Gwent
wimd <- st_read(dsn = "data/BG_wIMD",layer = "BG_wIMD")
names(wimd)
qtm(wimd)
st_crs(wimd)#27700

#Wimd for the LSOAs which intersect a 1000m buffer of the road.  
lsoa1k <- wimd <- st_read(dsn = "data/BG_wIMD",layer = "LSOA_in1000m_oldor_prop")
qtm(lsoa1k)
st_crs(lsoa1k)#27700

#alignment of new road
new_A465 <- st_read(dsn = "data/newA465line",layer = "newA465proj")
qtm(newroad)
st_crs(newroad)#27700

#old and new road
old_and_new <- st_read(dsn = "data/A465_corridor_BG",layer = "A465_old_and_proposed")
qtm(old_and_new)
#just keep the trunk sections which are the old road
old_A465 <- old_and_new %>% filter(type == "trunk")


#WIMD2014 for all of Wales so we can get quintiles
wimd_Wales <- read_csv("data/WIMD2014.csv")

#quantile(wimd_Wales$WIMD_2014,  probs = c(20,40,60,80,100, NA)/100)
#make quintiles for the IMD
wimd_Wales <- wimd_Wales %>% mutate(IMDQuintile = ntile(WIMD_2014, 5))
 
lsoa1k <- left_join(lsoa1k,wimd_Wales,by = c("LSOA11CD" = "LSOACode"))





tmap_mode("view")
m <- tm_basemap(server = leaflet::providers$CyclOSM)+
  tm_tiles('https://{s}.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png',)+
tm_shape(lsoa1k)+
  tm_fill(col = "IMDQuintile",palette = "-Blues", alpha = 0.5,style = "cat")+
  tm_shape(old_A465)+
  tm_lines(col = "brown", lwd = 2,alpha = 0.8)+
    tm_shape(new_A465)+
  tm_lines(col = "green", lwd = 2,alpha = 0.8)

m
  
tmap_save(m,"A465_old_new_wimdQuintile_cycleway.html")

  







