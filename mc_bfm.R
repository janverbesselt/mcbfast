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
evi <- brick("data/evi_au.grd") ## monthly time series

## test on one time series to demonstrate how bfastmonitor works
if (FALSE) {
  plot(evi, 1)
  tsevi <- ts(as.numeric(evi[cellFromXY(evi, c(149.9479,-24.88017))]/10000), 
              start=c(2000,2), freq=12)
  plot(tsevi)
  fit <- bfastmonitor(tsevi, start = c(2010, 1))
  plot(fit)
}

# To run in parallel, uncomment:
# sfQuickInit(cpu=2)

# Now use rasterEngine to execute the function on the brick:
bfastmonitor_raster <- rasterEngine(rasterTS=evi, 
  filename=c("data/test.grd"),
  args=list(start=c(2010,1)), setMinMax = FALSE,
  fun=bfastmonitor_rasterEngine, debugmode=FALSE)

# To stop parallel engine, uncomment:
# sfQuickStop()

plot(bfastmonitor_raster)
