source("code/local_weather_cpmd.R")

library(ggtext)
#USING LUBRIDATE AND GGPLOT2 TO WORK WITH DATES

#Calculating cummulative precipitation amount each year

this_year <- year(today())

local_weather_cpmd %>% 
  select(date, prcp) %>% 
  drop_na(prcp) %>% 
  mutate(year = year(date),
         month = month(date),
         day = day(date),
         is_this_year = year == this_year) %>%  #gets the year, month and day out of our date value
  filter(year > 1995 & (month != 2 & day != 29)) %>% #drop Feb 29th since it's a leap year
  #tail() %>% 
  group_by(year) %>% 
  mutate(cum_prcp = cumsum(prcp)) %>% 
  ungroup() %>%  #removes the groupings
  #filter(month == 1) %>%  #this filter statement shows us that norm temp for Jan is same all yrs
  mutate(new_date = ymd(glue("2022-{month}-{day}"))) %>% 
  ggplot(aes(x = new_date, y = cum_prcp, group = year, 
             color = is_this_year, size = is_this_year)) +
  geom_line(show.legend = F) + #removes legend from plot area
  geom_smooth(aes(group = 1), color = "black", size = 0.3, se = F) + #gives a smooth line across plot and removes SE
  scale_color_manual(breaks = c(F,T),
                     values = c("lightgray", "dodgerblue")) +
  scale_size_manual(breaks = c(F, T),
                    values = c(0.3, 1)) +
  scale_x_date(date_labels = "%B", date_breaks = "2 months") + #full month names every 2 months
  scale_y_continuous(breaks = seq(0, 1500, 300),#specify current y-axis units
                     labels = seq(0, 150, 30), #give new y-axis units
                     limits = c(0, 1500), #expands the y-axis
                     expand = c(0,0)) + #removes space on x- and y-axes
  labs(
    x = NULL,
    y = "Cummulative precipitation (cm)",
    title = "Through Agust 13th, the cummulative precipitation near College Park, MD is below average for 2022"
  ) +
  theme(
    plot.title.position = "plot",
    plot.title = element_textbox_simple(),
    panel.background = element_blank(),
    panel.grid = element_blank(),
    axis.line = element_line()
  )
ggsave("figures/cummulative_prcp.png", width = 6, height = 5)
  






#USING GROUP_BY FUNCTION WITH AND WITHOUT SUMMARIZE