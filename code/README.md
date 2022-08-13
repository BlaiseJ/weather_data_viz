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