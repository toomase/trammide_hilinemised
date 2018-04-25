# load data from TLT API for tram arrivals in stops
# schedule cronjob to download data for every 2 min
library(tidyverse)

# Load tram stops url list
tram_stops <- readRDS("~/Dropbox/DataScience/R/trammide_hilinemised/data/tram_stops.rds")

# Function to download API call information for a given stop url
read_csv_char <- function(x){
  raw <- read_csv(x, col_types = "cccccc",
                  col_names = c("transport", "route_num", "expected_time_in_seconds",
                                "schedule_time_in_seconds", "stop_name", "empty"))
  raw %>%
    select(-empty) %>%
    filter(!transport %in% c("stop", "Transport")) %>% 
    mutate(url = x,
           timestamp = round(as.numeric(Sys.time()), 0))
}

# ignore errors
read_csv_char_possibly <- possibly(read_csv_char, NULL)

timestamp <- round(as.numeric(Sys.time()), 0)  # timestamp of data

# fail path for saving
file <- paste('~/Dropbox/DataScience/R/trammide_hilinemised/data/arrival/', timestamp, '.rds', sep = '')

# do API call for all tram stops
tram_arrival <- map_df(tram_stops$url, read_csv_char_possibly) 

# save sf data object
saveRDS(tram_arrival, file)

## rstudio serveri script, mis käib iga 2 min tagant 15-17.04
## seejärel sisene cronjob vaatesse
# sudo crontab -u rstudio -e

## lisa cronjob vaates järgnevad read
# */2 * 15-17 4 * Rscript ~/Dropbox/DataScience/R/trammide_hilinemised/load_data_arrival.R