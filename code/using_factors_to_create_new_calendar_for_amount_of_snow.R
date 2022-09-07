source("code/local_weather_cpmd.R")

library(ggtext)
#creating a snow year

snow_data <- local_weather_cpmd %>% 
  select(date, snow) %>% 
  drop_na(snow) %>% 
  mutate(cal_year = year(date), #gives calendar year
         month = month(date),#calendar month
         snow_year = if_else(date < ymd(glue("{cal_year}-07-01")),#builds July 1st of a certain year
                             cal_year - 1, #if the statement is true and
                             cal_year)) %>% #tail(n = 30) #if the statement is false
  select(month, snow_year, snow) %>% 
  filter(snow_year > 1943 & snow_year != 2022)

snow_data %>% 
  group_by(snow_year) %>% 
  summarise(total_snow = sum(snow)) %>% 
  ggplot(aes(x = snow_year, y = total_snow)) +
  geom_line()


#Creating a dummy dataframe
dummy_var <- crossing(snow_year = 1944:2021,
                      month = 1:12) %>% 
  mutate(dummy = 0)

#adding informative title
total_snowfall <- snow_data %>% 
  group_by(snow_year) %>% 
  summarise(total_snow = sum(snow)) %>%
  filter(snow_year == 2020) %>% 
  mutate(total_snow = total_snow/10) %>% 
  pull(total_snow)

#plotting snowfall by year and month
snow_data %>%
  right_join(., dummy_var, by = c("snow_year", "month")) %>% 
  #filter(is.na(snow)) %>% #we see that we have 80 rows of month/year combination having NA values for snow
  mutate(snow = if_else(is.na(snow), dummy, snow)) %>%  #if snow has NA, replace with dummy else use the value of snow
  group_by(snow_year, month) %>% 
  summarise(snow = sum(snow), .groups = "drop") %>% 
  mutate(month = factor(month, levels = c(8:12, 1:7)),#creates a vector that goes from 7 to 12 and 1 to 6
         is_this_year = 2020 == snow_year) %>%  
  ggplot(aes(x = month, y = snow, group = snow_year, color = is_this_year)) + 
  geom_line(show.legend = F) +#from here down, we are highlighting current snow year i.e. 2021
  scale_color_manual(name = NULL,
                     breaks = c(T, F),
                     values = c("dodgerblue", "gray")) +
  scale_x_discrete(breaks = c(9, 11, 1, 3, 5),
                   labels = month.abb[c(9, 11, 1, 3, 5)],
                   expand = c(0,0)) +
  scale_y_continuous(breaks = seq(0, 800, 200),
                     labels = seq(0, 80, 20)) + #these two lines change units from mm to cm
  labs(x = NULL,
       y = "Total monthly snowfall (cm)",
       title = glue("The <span style = 'color:dodgerblue'>snow year 2020</span> had a total of {total_snowfall} cm of snow")) +
  theme(
    panel.background = element_blank(),
    panel.grid = element_blank(),
    axis.line = element_line(),
    plot.title.position = "plot",
    plot.title = element_markdown()
  )
ggsave("figures/snow_by_snow_year.png", width = 6, height = 4)






