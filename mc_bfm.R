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
  unzip(files="data/evi_au.zip")
} else {
  evi <- brick(fn) ## monthly time series
}

## test on one time series to demonstrate how bfastmonitor works
if (FALSE) {
  plot(evi, 1)
  tsevi <- ts(as.numeric(evi[cellFromXY(evi, c(149.9479,-24.88017))]/10000), 
              start=c(2000,2), freq=12)
  plot(tsevi)
  bfm <- bfastmonitor(tsevi, start = c(2010, 1))
  plot(bfm)
  c(bfm$breakpoint, bfm$magnitude)
}

## does not work yet --> as we need to build in dealing with NA's in the time series
## Ben how have you tackled this?

if (FALSE) {
  # To run in parallel, uncomment:
  if (!file.exists(fn <- "data/test.grd")) {
    # sfQuickInit(cpu=2)
    # Now use rasterEngine to execute the function on the brick:
    bfm_out <- rasterEngine(rasterTS=evi, 
                      filename=c("data/test.grd"),
                      args=list(start=c(2010,1)), setMinMax = FALSE,
                      fun=bfastmonitor_rasterEngine, debugmode=FALSE)
    # To stop parallel engine, uncomment:
    # sfQuickStop()
  }  else {
    bfm_out <- brick(fn)
  }
  plot(bfm_out)
}

## no parallel processing
## to be added the calc based alternative to deal with NA's and limit processing to specific areas
## (4) analyse GIMMS with bfast01 and classify
fn <- "data/bfm_mod13c2.grd"
if(!file.exists(fn)) {
  bfm_evi <- calc(evi, fun = getbfm, filename = fn)
} else {
  bfm_evi <- brick(fn)
}


