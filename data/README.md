Getting weather data
--------------------
- Got to https://data.giss.nasa.gov/
- Datasets > GISTEMP Surface Temperatures
- Scroll down to
Tables of Global and Hemispheric Monthly Means and Zonal Annual Means
- Then download CSV file from the first option
Global-mean monthly, seasonal, and annual means, 1880-present, updated through most recent month:
- Save in data/ directory
- Open README.md file in data/ and save website for data and url for csv file > Save
NOTE: Avoid pushing very large files to GitHub

Downloaded data from:
https://data.giss.nasa.gov/gistemp/
https://data.giss.nasa.gov/gistemp/tabledata_v4/GLB.Ts+dSST.csv

Weather Data for College Park Maryland
---------------------------------------
- Go to https://www.ncei.noaa.gov/cdo-web/
- Browse datasets > click Daily Summaries > click More > Download Data column > NCEI HTTPS Server
- Read through the Readme.txt file to get an idea of the data and sources/metadata
- We will look at the ghcnd-inventory.txt file to get the weather station closest to where we live [Maryland]
- Right click on ghcnd-inventory.txt and copy url [https://www.ncei.noaa.gov/pub/data/ghcn/daily/ghcnd-inventory.txt]
- Paste this in a new R script

Find Out Longitude and Latitude of college park MD
--------------------------------------------------
- Search College Park on Google Maps > right click and copy 

Find distance between two longitude and latitude points
-------------------------------------------------------
- Search this on google (https://www.geeksforgeeks.org/program-distance-two-points-earth/)

Distance, d = 3963.0 * arccos[(sin(lat1) * sin(lat2)) + cos(lat1) * cos(lat2) * cos(long2 – long1)]

The obtained distance, d, is in miles. If you want your value to be in units of kilometers, multiple d by 1.609344.
d in kilometers = 1.609344 * d in miles
Thus you can have the shortest distance between two places on Earth using the great circle distance approach.

- After identifying the closest station, head to the website and download the data for that station
- Select the by_station/ directory > right click on any station name > copy url













