## February 2014
## Authors: Jan Verbesselt
## Objective:
## (1) testing of mc processing
## (2) derive the percentage NA's and mean per time series

if (FALSE) {
  ## if needed for mac type = "source"
  install.packages("spatial.tools", 
                   type = "source", repos="http://R-Forge.R-project.org")
}

## load packages
require("bfast")
require("spatial.tools")
sfQuickInit(cpus = 4)
require("raster")

## load functions
source("functions.R")

## load data
if (!file.exists(fn <- "data/evi_au.grd")) {
  unzip(zipfile="data/evi_au.zip", exdir = "data/.")
  evi <- brick(fn)
} else {
  evi <- brick(fn) ## monthly time series
}

## test on one time series
if (FALSE) {
  plot(evi, 1)
  tsevi <- ts(as.numeric(evi[cellFromXY(evi, c(149.9479,-24.88017))]/10000), 
              start=c(2000,2), freq=12)
  plot(tsevi)
  test <- getValues(evi, 10, 10)
  f_stats(test[1,])
}

## rasterEngine - multicore processing
fn <- "data/test"
if (!file.exists(paste(fn,".grd",sep=""))) {
  # Now use rasterEngine to execute the function on the brick:
  v <- system.time(
  out <- rasterEngine(rasterTS=evi, setMinMax = TRUE,
                        fun=tsstat_rasterEngine, debugmode=FALSE, 
                        filename=fn, dataType="INT2S", overwrite=FALSE)
  )
  ## comments: 1)when overwrite is off it does not give a error warning
  ## 2) dataType is that take into account?
  ## test gain is not so large when increasing the cpu's - maybe this improves for large data sets
  
  print(v)
#   user  system elapsed 
#   0.128   0.016   7.343
# To stop parallel engine, uncomment:

  
}  else {
  out <- brick(paste(fn,".grd",sep=""))
}

## standart calc function processing
if (!file.exists(fn <- "data/test_calc.grd")) {
  system.time(
  out2 <- calc(evi,
          fun = f_stats,
            filename = fn, dataType = "INT2S")
  )
}  else {
  out2 <- brick(fn)
}

# user  system elapsed 
# 2.804   0.016   2.826 

out
out2
plot(out)
plot(out2)


sfQuickStop()


