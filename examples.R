#######################################################################################
##  examples.R: basic examples of making maps in R
##
##  Author: Kelsey McGurrin
##
#######################################################################################


#### setup ####
library(tidyverse) #normal data plotting and wrangling
library(sf) #data frames with spatial features
library(mapview) #quick interactive maps
library(tigris) #us census data downloads



#### example 1: trees in Baltimore ####

# read in summer 2024 data - Photosynq records GPS coordinates
trees <- read_csv("input_data/sample_GC_2024.csv")
trees

# convert dataframe to shapefile 
# use EPSG code to specify CRS
# https://www.nceas.ucsb.edu/sites/default/files/2020-04/OverviewCoordinateReferenceSystems.pdf
trees_sf<-st_as_sf(trees,coords = c("long", "lat"), crs = 4326)
trees_sf

# can do normal data filter/select operations with sfs
trees_sf %>%
  filter(SPP=="Liquidambar styraciflua")

# mapview is smart!!
mapview(trees_sf)

# or add in more options
trees_sf |> 
  mapview(zcol = "SPP"
        , layer.name = 'Tree species'
        , legend = T
        , cex = 2
        )

# but sometimes a simple picture is better
# get outline of baltimore city from tigris package
baci <- counties(state = "24", cb = TRUE, resolution = "500k", year = 2022) %>% 
  filter(NAMELSAD=="Baltimore city") 
baci

# ggplot also works with sfs
ggplot(baci) + geom_sf() + theme_void()

# ggplot is not as smart as mapview though
ggplot(trees_sf) + geom_sf()

# add in more details (order matters- so things don't get covered up)
ggplot(data = baci) +
  geom_sf() +
  geom_sf(data = trees_sf, size = 0.4, color="darkgreen") 

# CAUTION: mismatched CRS
st_crs(baci)
st_crs(trees_sf)

# works ok here, but may be way off in certain times/places
# best practice: use same CRS. can do with EPSG code
trees_sf<-st_transform(trees_sf,crs = 3857)

# or by telling R to match
trees_sf<-st_transform(trees_sf,st_crs(baci))
trees_sf

# save like any other ggplot
ggsave("figures/baci_trees.png",width=4, height=6, units=c("in"))
