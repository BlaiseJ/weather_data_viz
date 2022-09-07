source("code/local_weather_cpmd.R")

library(ggtext)

threshold <- 0

drought_by_year <- local_weather_cpmd %>% 
  select(date, prcp) %>% 
  mutate(prcp = replace_na(prcp, 0)) %>%  #replaces all NA values with zeros
#  replace_na(list(prcp = 0)) #replaces all NA values with  %>% 
  filter(prcp > threshold) %>% #this removes all zeros from precipitation
  mutate(prev_date = lag(date, n = 1)) %>% #create a lag date column with a lag of 1 day
  drop_na() %>% #drops the NA in the first lagged day
  mutate(drought_length = as.numeric(date - prev_date - 1),#gives us drought length with days word included. To remove that, we make it as.numeric. The minus 1 removes the 1 day drought
         year = year(date)) %>% 
  select(year, length = drought_length)

drought_by_year %>% 
  filter(year  == 1961) %>% 
  ggplot(aes(x = length)) + geom_histogram()

drought_by_year %>% 
  filter(year != 1941) %>% #removes 1941 because it was a partial year
  group_by(year) %>% 
  summarise(n = n(),
            median = median(length),
            mean = mean(length),
            max = max(length),
            uquartile = quantile(length, prob = .75)) %>% 
  #pivot_longer(-year) %>% #pivots everything except the year column. This will permit us plot all the quantities on same plot
  ggplot(aes(x = year, y = n)) +
    geom_line() +
  geom_smooth(se = F) +
    #facet_wrap(~name, ncol = 1, scales = "free_y")+
  labs(x = "Year",
       y = "Number of days between\n rain events",
       title = "The length of drought has been <span style = 'color:blue'>increasing</span> over the past 80 years in College Park") +
  scale_x_continuous(breaks = seq(1940, 2020, 20)) +
  theme_classic() +
  theme(
    plot.title.position = "plot",
    plot.title = element_textbox_simple(size = 18, margin = margin(b = 10))#this helps to wrap and justify the title
  )
  
ggsave("figures/drought_length.png", width = 5, height = 4)
