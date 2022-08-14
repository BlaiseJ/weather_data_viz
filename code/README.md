Elements
--------
TMAX is in tenths of degrees. Divide by 10 to get it in o C
PRCP is in tenths of mm. Divide by 10 to have in mm
SNOW is in mm

Removing anomalous values
-------------------------
From the line graph of prcp for example, I filtered for prcp < 150 mm. I did this after the
rename(tolower) statement
The downside of the filter approach is that it removes all data for the entire row

Second method is the mutate with if_else function (recommended)

Problem with data
-----------------
tmax has a bunch of NA values from 1951 t0 1955 and 1958 to 1994. So I filtered data from 1995 to 2021

Using lubridate to work with dates in ggplots
---------------------------------------------
Instead of using the 26 years worth of dates, I created a pseudo date called new_date by using this years date (2022) and adding to month and day of each month

To make our plotted data for all other years gray and that for 2022 different color, I created a new date variable called this_year which I then added in my mutate function.

I then added a color argument in ggplot which colored by is_this_year

Cummulative_precipitation_plot
------------------------------
ggtext package helps to wrap text in the plot area
scales pacaked helps to make day date to have the suffix nd, rd, th etc e.g. 2nd, 3rd, 4th

Styling facet_wrap figures
--------------------------
To change the panel labels outside of the y-axis to actual labels, I created a variable called neat_labels
Add these labels in the facet_wrap statement
I added line breaks to labels that overlapped the y-axis
Added a horizontal line to represent x-axis for each panel using geom_hline(yintercept = 0)
But this line seems to be clipped, so I added a cord_cartesian statement