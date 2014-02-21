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
require("raster")
## load functions
source("functions.R")
## percentage NA's
f_pna <- function(x) { sum(is.na(x)) / length(x) }
f_stats <- function(x) {
  o1 <- round(f_pna(x)*100) # obtain integer values
  o2 <- round(mean(x,na.rm=TRUE))
  return(c(o1, o2))
}

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

## define the rasterEngine helper function
# Function to feed to rasterEngine:
tsstat_rasterEngine <- function(rasterTS)  {
  rasterTS_dims <- dim(rasterTS)
  npixels <- prod(dim(rasterTS)[1:2])
  ndates <- dim(rasterTS)[3]
  # "Flatten" the input array to a 2-d matrix:
  dim(rasterTS) <- c(npixels,ndates)
  # Run bfastmonitor pixel-by-pixel:
  out <- foreach(i=seq(npixels),.packages=c("zoo"),.combine=rbind) %do% {
    f_pna <- function(x) { sum(is.na(x)) / length(x) }
    f_stats <- function(x) {
      o1 <- round(f_pna(x)*100) # obtain integer values
      o2 <- round(mean(x,na.rm=TRUE))
      return(c(o1, o2))
    }
    return(f_stats(rasterTS[i,]))
  }
  # Coerce the output back to the correct size array:
  dim(out) <- c(rasterTS_dims[1:2], 2)
  return(out)
}

## rasterEngine - multicore processing
fn <- "data/test"
if (!file.exists(paste(fn,".grd",sep=""))) {
  sfQuickInit(cpus = 2)
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
  sfQuickStop()
  
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



