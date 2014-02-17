## February 2014
## Authors: Jan Verbesselt, Jonathan Greenberg

if (FALSE) {
  ## if needed for mac type = "source"
  install.packages("spatial.tools", 
                   type = "source", repos="http://R-Forge.R-project.org")
}

require("bfast")
require("spatial.tools")

## load functions
source("functions.R")

## load data
if (!file.exists(fn <- "data/evi_au.grd")) {
  unzip(zipfile="data/evi_au.zip", exdir = "data/.")
  evi <- brick(fn)
} else {
  evi <- brick(fn) ## monthly time series
}

## test on one time series to demonstrate how bfastmonitor works
if (FALSE) {
  plot(evi, 1)
  tsevi <- ts(as.numeric(evi[cellFromXY(evi, c(149.9479,-24.88017))]/10000), 
              start=c(2000,2), freq=12)
  plot(tsevi)
  test <- getValues(evi, 10, 10)
  tsevi <- ts(as.numeric(test[1,]), start=c(2000,2), frequency = 12)
  tsevi_qtr <- as.ts(aggregate(as.zoo(tsevi), as.yearqtr, mean, na.rm=TRUE))
  plot(tsevi_qtr)
  length(tsevi_qtr)
  as.numeric(round(tsevi_qtr))
  class(tsevi_qtr)
}

## we need to build in dealing with NA's in the time series
## does not work yet
if (FALSE) {
  # To run in parallel, uncomment:
  if (!file.exists(fn <- "data/test.grd")) {
    #sfQuickInit()
    # Now use rasterEngine to execute the function on the brick:
    agg_out <- rasterEngine(rasterTS=evi, args=list(),
                      fun=zooaggregate_array, debugmode=FALSE)
    # To stop parallel engine, uncomment:
    # sfQuickStop()
  }  else {
    agg_out <- brick(fn)
  }
  plot(agg_out)
}

