library(tidyverse)
library(sf)
library(janitor)
library(tmap)
library(terra)
library(readxl)
library(leaflet)

CAFO_df <- st_read("/Users/alexreed/Documents/MEDS/Website/data/CAFO_Density") |>
  clean_names() 

states <- read_xlsx("/Users/alexreed/Documents/MEDS/Website/data/states.xlsx") 
colnames(states)[colnames(states) == 'name'] <- 'state_name' 


CAFO_by_state <- CAFO_df |>
  group_by(state_name) |>
  summarise(count = sum(caf_os)) 

combined <- left_join(states, CAFO_by_state) 

cafos_plot <- combined |>
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)


cafos_plot |>
  leaflet() |>
  addProviderTiles(providers$Esri.WorldImagery, group = "World Imagery") |>
  addProviderTiles(providers$Stamen.TonerLite, group = "Toner Lite") |>
  addLayersControl(baseGroups = c("World Imagery", "Toner Lite")) |>
  addMarkers(clusterOptions = markerClusterOptions())


CAFO_by_state <- st_as_sf(CAFO_by_state)

tm_shape(CAFO_by_state) +
  tm_polygons() +
  tm_dots("count",
          breaks = c(0, 0, 10, 100, 500, 1000, 2000, 3000))


tm_shape(CAFO_df) +
  tm_polygons() +
  tm_dots("caf_os")