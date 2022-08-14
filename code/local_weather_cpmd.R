library(tidyverse)
library(glue)
library(lubridate)

#because this file is a txt not tsv, we will do a read_table NOT read_tsv
invent_url <- "https://www.ncei.noaa.gov/pub/data/ghcn/daily/ghcnd-inventory.txt"

inventory <- read_table(invent_url,
           col_names = c("stations", "lat", "lon", "variable", "start", "end"))

inventory


my_lat <- 38.99325903873295 * 2 * pi/360 #multiply by * 2 * pi/360 to convert to radians
my_lon <- -76.92883829339722 * 2 * pi/360 #multiply by * 2 * pi/360 to convert to radians

# Now we cal the distance from my lat and lon to the lat/lon of each of the weather stations
#This will help to choose the station closest to College Park, MD. See README file

my_station <- inventory %>% 
  mutate(lat_r = lat * 2 * pi/360,
         lon_r = lon * 2 * pi/360,
         d = 1.609344 * 3963 * acos((sin(lat_r) * sin(my_lat)) + cos(lat_r) * cos(my_lat) * cos(my_lon - lon_r))) %>%
  filter(start < 1960 & end > 2020) %>% 
  top_n(n = -1, d) %>% #gives just the station that meets the above condition on d
  distinct(stations) %>%   #get the one station which is USC00180700
  pull(stations) #pulls out the station  from stations
#arrange(d) # -d will show the furthest weather station from College Park MD
# multiplying by 1.609344 converts distance from miles to km
my_station

#Now having identified the closest station, we download the data for that station

station_daily <- glue("https://www.ncei.noaa.gov/pub/data/ghcn/daily/by_station/{my_station}.csv.gz")
  
local_weather_cpmd <- read_csv(station_daily,#reads data but need to edit headers. Check the readme file on the website for info
         col_names = c("station", "date", "variable", "value", "a", "b", "c", "d")) %>% 
  select(date, variable, value) %>% 
  pivot_wider(names_from = "variable", values_from = "value") %>% 
  select(date, TMAX, PRCP, SNOW) %>% 
  mutate(date = ymd(date), #convert date to yy-mm-dd format
         TMAX = TMAX / 10, #convert to oC
         PRCP = PRCP / 10) %>% #convert to mm
  rename_all(tolower) %>% 
  #filter(prcp < 150) %>% #one way of dealing with anomalous data
  mutate(snow = if_else(snow < 400, snow, NA_real_),#second way of handling anomalies
         prcp = if_else(prcp < 150, prcp, NA_real_)) 

local_weather_cpmd

#IDENTIFYING PROBLEMATIC DATA WITH LINE PLOTS AND HISTOGRAMS

#FOR TMAX

local_weather_cpmd %>% 
  ggplot(aes(x = date, y = tmax)) + geom_line()

local_weather_cpmd %>% 
  slice_max(n = 5, tmax) #to get the top 5 highest values

local_weather_cpmd %>% 
  ggplot(aes(x = tmax)) + geom_histogram(binwidth = 2.5)

#FOR PRCP

local_weather_cpmd %>% 
  ggplot(aes(x = date, y = prcp)) + geom_line()

local_weather_cpmd %>% 
  slice_max(n = 5, prcp) #to get the top 5 highest values

local_weather_cpmd %>% 
  ggplot(aes(x = prcp)) + geom_histogram() + #most data points are to left so adjust y-axis
  scale_y_continuous(limits = c(0, 50))


#FOR SNOW

local_weather_cpmd %>% 
  ggplot(aes(x = date, y = snow)) + geom_line()

local_weather_cpmd %>% 
  slice_max(n = 5, snow) #to get the top 5 highest values

local_weather_cpmd %>% 
  ggplot(aes(x = snow)) + geom_histogram() + #most data points are to left so adjust y-axis
  scale_y_continuous(limits = c(0, 50))


#USING GROUP_BY FUNCTION WITH SUMMARIZE

this_year <- year(today())

local_weather_cpmd %>% 
  select(date, tmax) %>% 
  mutate(year = year(date)) %>%  #gets the year out of our date value
  filter(year > 1995 & year != this_year) %>%  #because data <1948 begins from April and 2022 is partial year
  #tail() %>% 
  group_by(year) %>% 
  summarise(tmax = mean(tmax)) %>% 
  mutate(normalize_range = (year >=1995 & year <= 2021),
         normalize_mean = sum(tmax * normalize_range)/sum(normalize_range),
         t_diff = tmax - normalize_mean) %>% 
  ggplot(aes(x = year, y = t_diff)) +
  geom_line() + 
  geom_smooth()

#USING GROUP_BY FUNCTION WITHOUT SUMMARIZE

local_weather_cpmd %>% 
  select(date, tmax) %>% 
  drop_na(tmax) %>% 
  mutate(year = year(date),
         month = month(date)) %>%  #gets the year out of our date value
  filter(year > 1995) %>%   #because data <1948 begins from April and 2022 is partial year
  #tail() %>% 
  group_by(year, month) %>% 
  summarise(tmax = mean(tmax),
            .groups = "drop") %>%  #drops or removes grouping
  group_by(month) %>% 
  mutate(normalized_range = year >= 1995 & year <= 2022,
         normalized_temp = sum(tmax * normalized_range)/sum(normalized_range),
         t_diff = tmax - normalized_temp,
         is_this_year = year == this_year) %>%  #we see data is grouped by months
  ungroup() %>%  #removes the groupings
  #filter(month == 1) %>%  #this filter statement shows us that norm temp for Jan is same all yrs
  ggplot(aes(x = month, y = t_diff, group = year, color = is_this_year)) +
  geom_line() +
  scale_color_manual(breaks = c(F,T),
                     values = c("lightgray", "dodgerblue"),
                     guide = "none") +
  theme_classic()



