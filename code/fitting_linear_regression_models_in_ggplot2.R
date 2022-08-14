source("code/local_weather_cpmd.R")

prcp_snow_annual <- local_weather_cpmd %>% 
  drop_na() %>% #remove all data points that have NAs
  filter(snow > 0) %>% #to get only days where there was snow
  mutate(year = year(date)) %>% 
  group_by(year) %>% #group by year and find the sum of prcp and snow for each year
  summarise(prcp = sum(prcp), 
            snow = sum(snow)) %>% 
  filter(year != 2022)

prcp_snow_annual %>% 
  pivot_longer(-year) %>% 
  ggplot(aes(x = year, y = value)) +
  geom_line() +
  facet_wrap(~name, ncol = 1, scales = "free_y")

#to check for correlation

prcp_snow_annual %>% 
  ggplot(aes(x = prcp, y = snow, color = year)) +
  geom_point()

cor.test(prcp_snow_annual$prcp, prcp_snow_annual$snow)

#daily level correlation

prcp_snow_daily <- local_weather_cpmd %>% 
  drop_na() %>% #remove all data points that have NAs
  filter(snow > 0 & tmax <= 0) %>% #to get only days where there was snow and max temp <=0
  mutate(year = year(date)) %>% 
  filter(year != 2022) 

#Building our model
snow_model <- lm(snow~tmax*prcp + 0, data = prcp_snow_daily) #addind zero, removes the intercept
summary(snow_model) #the main effects and interaction are all significant with weak correlation
#now fit predicted values of this model to our ggplot in line 39 below

prcp_snow_daily %>% 
  mutate(predicted = predict(snow_model, prcp_snow_daily)) %>% 
  ggplot(aes(x = prcp, y = snow)) +
  geom_point(color = "lightgray") + 
  geom_smooth(aes(color = "simple"), formula = "y~x+0", method = "lm", se = F) +#adding 0 adjust regression line to begin from point zero
  geom_segment(x = 0, y = 0, 
               xend = max(prcp_snow_daily$prcp), 
               yend = 10*max(prcp_snow_daily$prcp), size = 1, #this is the rule of 1:10
               aes(color = "rule_of_thumb")) + 
  geom_smooth(aes(y = predicted, color = "advanced"), se = F) +
  labs(x = "Total daily precipitation (mm)",
       y = "Total daily snowfall (mm)") +
  scale_color_manual(name = NULL,
                     breaks = c("rule_of_thumb", "simple", "advanced"),
                     labels = c("10:1 rule of thumb", 
                                "Simple model",
                                "Advanced model"),
                     values = c("blacK", "blue", "red")) +
  theme_classic()
ggsave("figures/model_snow_ratio.png", width = 6, height = 4)







