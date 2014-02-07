# functions

# Function to feed to rasterEngine:
bfastmonitor_rasterEngine <- function(rasterTS, start,...)
{
  library("bfast")
  rasterTS_dims <- dim(rasterTS)
  npixels <- prod(dim(rasterTS)[1:2])
  ndates <- dim(rasterTS)[3]
  
  # "Flatten" the input array to a 2-d matrix:
  dim(rasterTS) <- c(npixels,ndates)
  # Run bfastmonitor pixel-by-pixel:
  bfm_out <- foreach(i=seq(npixels),.packages=c("bfast"),.combine=rbind) %do%
    {
      bfts <- ts(rasterTS[i,], start=c(2000,2), freq=12)
      bfm <- bfastmonitor(data=bfts, start=start)
      return(c(bfm$breakpoint, bfm$magnitude))
    }

  # Coerce the output back to the correct size array:
  dim(bfm_out) <- c(rasterTS_dims[1:2], 2)
  return(bfm_out)
}
