source("code/local_weather_cpmd.R")

#VISUALIZING CORRELATION WITH DOUBLE Y-AXES
tmax_prcp <- local_weather_cpmd %>% 
  mutate(year = year(date)) %>% 
  filter(year > 1947 & year != year(today())) %>% #dropped years bc data is incomplete
  group_by(year) %>% 
  summarise(tmax = mean(tmax, na.rm = T),
            prcp = sum(prcp, na.rm = T))

tmax_prcp %>% 
  pivot_longer(-year) %>% #pivot all variables except for year
  ggplot(aes(x = year, y = value)) +
  geom_line() + #scales=free_y gives different y-axes scales to plots
  facet_wrap(~name, ncol = 1, scales = "free_y") +#ncol=1 stacks the plots one over another
  geom_smooth(SE = F) #adds smooth line and removes SE


scaled_tmax_prcp <- tmax_prcp %>% 
  mutate(tmax_tr = (tmax - min(tmax))/ (max(tmax) - min(tmax)),
         tmax_min = min(tmax),
         tmax_max = max(tmax),
         prcp_tr = (prcp - min(prcp))/ (max(prcp) - min(prcp)),
         prcp_min = min(prcp),
         prcp_max = max(prcp))

#supperimposing the tmax and prcp plots together
tmax_plot <- tmax_prcp %>% 
  ggplot(aes(x = year, y = tmax)) +
  geom_line(color = "blue")

tmax_plot +
  geom_line(aes(y = prcp/50, color = "red"))

#we want plot scales to go from 0-1 to see the overlap well. So we go back to line 19 and create a mutate for it

tmax_plot <- scaled_tmax_prcp %>% 
  ggplot(aes(x = year, y = tmax_tr)) +
  geom_line(color = "blue")
  
tmax_plot +
  geom_line(aes(y = prcp_tr, color = "red")) +
  scale_y_continuous(labels = seq(10, 30, 5),
                     breaks = (seq(10, 30, 5) - 6.59)/20.3,
                     limits = (c(5, 27.5) - 6.59)/20.3,#6.59 and 20.3 are tmin/tmax values from scaled_tmax_prcp
                     name = "Average Annual Temperature",
                     sec.axis = sec_axis(trans = ~., #this implies we will not be transforming the data
                                         labels = seq(300, 2100, 200),
                                         breaks = (seq(300, 2100, 200) - 374)/1675,
                                         name = "Total Precipitation (mm)")) +
  theme(
    axis.title.y.left = element_text(color = "blue"),
    axis.title.y.right = element_text(color = "red")
  )

#MORE DIRECT WAY OF DOING CORRELATION ANALYSIS
tmax_prcp %>% 
  ggplot(aes(x = tmax, y = prcp)) +
  geom_point() +
  geom_smooth(method = "lm")

cor.test(tmax_prcp$tmax, tmax_prcp$prcp)
cor.test(tmax_prcp$tmax, tmax_prcp$prcp, method = "spearman", exact = F)





