source("code/local_weather_cpmd.R")

neat_labels <- c("prob_prcp" = "Probability of\n precipitation", 
                 "mean_prcp" = "Average amount\n of daily precipitation\n (mm)", 
                 "mean_event" = "Average amount\n of precipitation\n by event (mm)")


local_weather_cpmd %>% 
  select(date, prcp) %>% 
  mutate(day = day(date),
         month = month(date),
         year = year(date)) %>% 
  drop_na(prcp) %>% 
  group_by(month, day) %>% 
  summarise(prob_prcp = mean(prcp > 0), #probability of a rain event
            mean_prcp = mean(prcp),
            mean_event = mean(prcp[prcp > 0]),
            .groups = "drop") %>% 
  mutate(date = ymd(glue("2020-{month}-{day}"))) %>% 
  select(-month, -day) %>% 
  pivot_longer(cols = c(prob_prcp, mean_prcp, mean_event)) %>% 
  mutate(name = factor(name, levels = c("prob_prcp", "mean_prcp", "mean_event"))) %>% #reorder levels
  ggplot(aes(x = date, y = value)) +
  geom_line() +
  geom_hline(yintercept = 0) +
  geom_smooth(SE = F) +
  facet_wrap(~name, ncol = 1, scales = "free_y", strip.position = "left", #strip.position changes the panel labels from top to left
             labeller = labeller(name = neat_labels)) + #labels outsied y-axis are replaced
  scale_y_continuous(limits = c(0, NA), expand = c(0,0)) +#0=let axis begin at zero, NA=let ggplot decide the height
  scale_x_date(date_breaks = "2 months",
               date_labels = "%B") +
  coord_cartesian(clip = "off") +
  labs(
    x = NULL, #removes the x-axis labels
    y = NULL #removes the y-axis labels
  ) +
  theme(
    strip.placement = "outside", #sends the panel labels from left to outside of y-axis
    strip.background = element_blank(), #removes background of strip
    panel.background = element_blank(),
    panel.grid = element_blank(),
    axis.line = element_line()
  )

ggsave("figures/prcp_prob_amount.png", width = 5, height = 7)



#ADDING A VERTICAL LINE INSTEAD TO CONTRAST OUR DATA

today_month <- month(today())
today_day <- day(today())
today_date <- ymd(glue("2020-{today_month}-{today_day}"))


local_weather_cpmd %>% 
  select(date, prcp) %>% 
  mutate(day = day(date),
         month = month(date),
         year = year(date)) %>% 
  drop_na(prcp) %>% 
  group_by(month, day) %>% 
  summarise(prob_prcp = mean(prcp > 0), #probability of a rain event
            mean_prcp = mean(prcp),
            mean_event = mean(prcp[prcp > 0]),
            .groups = "drop") %>% 
  mutate(date = ymd(glue("2020-{month}-{day}"))) %>% 
  select(-month, -day) %>% 
  pivot_longer(cols = c(prob_prcp, mean_prcp, mean_event)) %>% 
  mutate(name = factor(name, levels = c("prob_prcp", "mean_prcp", "mean_event"))) %>% #reorder levels
  ggplot(aes(x = date, y = value)) +
  geom_vline(xintercept = today_date, color = "brown", size = 1) +
  geom_line() +
  geom_smooth(SE = F) +
  facet_wrap(~name, ncol = 1, scales = "free_y", strip.position = "left", #strip.position changes the panel labels from top to left
             labeller = labeller(name = neat_labels)) + #labels outsied y-axis are replaced
  scale_y_continuous(limits = c(0, NA), expand = c(0,0)) +#0=let axis begin at zero, NA=let ggplot decide the height
  scale_x_date(date_breaks = "2 months",
               date_labels = "%B") +
  coord_cartesian(clip = "off") +
  labs(
    x = NULL, #removes the x-axis labels
    y = NULL #removes the y-axis labels
  ) +
  theme(
    strip.placement = "outside", #sends the panel labels from left to outside of y-axis
    strip.background = element_blank(), #removes background of strip
    panel.background = element_blank(),
    panel.grid = element_blank(),
    axis.line = element_line()
  )

ggsave("figures/prcp_prob_amount2.png", width = 5, height = 7)
