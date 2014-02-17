## February 2014
## Authors: Jan, Jonathan

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
  tsevi_qtr <- as.ts(aggregate(as.zoo(tsevi), as.yearqtr, mean, na.rm=TRUE))
  plot(tsevi_qtr)
  length(tsevi)
  as.numeric(tsevi_qtr)
  class(tsevi_qtr)
}

## we need to build in dealing with NA's in the time series

if (FALSE) {
  # To run in parallel, uncomment:
  if (!file.exists(fn <- "data/test.grd")) {
    sfQuickInit()
    # Now use rasterEngine to execute the function on the brick:
    agg_out <- rasterEngine(rasterTS=evi, 
                      filename=c("data/test.grd"), setMinMax = FALSE,
                      fun=zooaggregate_rasterEngine, debugmode=TRUE)
    # To stop parallel engine, uncomment:
    sfQuickStop()
  }  else {
    agg_out <- brick(fn)
  }
  plot(agg_out)
}

