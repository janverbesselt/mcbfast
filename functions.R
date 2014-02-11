# functions

# Function to feed to rasterEngine:
bfastmonitor_rasterEngine <- function(rasterTS, start)
{
  library("bfast")
  rasterTS_dims <- dim(rasterTS)
  npixels <- prod(dim(rasterTS)[1:2])
  ndates <- dim(rasterTS)[3]
  
  # "Flatten" the input array to a 2-d matrix:
  dim(rasterTS) <- c(npixels,ndates)
  # Run bfastmonitor pixel-by-pixel:
  bfm_out <- foreach(i=seq(npixels),.packages=c("bfast"),.combine=rbind) %do% {
      bfts <- ts(rasterTS[i,], start=c(2000,2), freq=12)
      bfm <- bfastmonitor(data=bfts, start=start)
      return(c(bfm$breakpoint, bfm$magnitude))
  }
  
  # Coerce the output back to the correct size array:
  dim(bfm_out) <- c(rasterTS_dims[1:2], 2)
  return(bfm_out)
}

bfmxt <- function(x) {
  xt <- ts(x, start=c(2000,2), frequency=12)
  bfm <- try(bfastmonitor(xt, start = c(2010, 1)))
  if (inherits(bfm,  "try-error")) {
    out <- c(NA, NA, 1)
  } else {
    out <- c(bfm$breakpoint, bfm$magnitude, 0)
  }
  return(out)
}

getbfm <- function(x)
{
  mask <- apply(x, 1, FUN = function(x) { sum(is.na(x)) / length(x) } )
  i <- (mask < 0.1)
  res <- matrix(NA, length(i), 3)
  if(sum(i) > 0) {
    i <- which(i)
    res[i,] <- t(apply(x[i,], 1, bfmxt)) 
  }
  res
}


## testing
if (FALSE) {
  x <- getValues(evi, 1, 100)
  mask <- apply(x, 1, FUN = function(x) { sum(is.na(x)) / length(x) } )
  i <- (mask < 0.05)
  res <- matrix(NA, length(i), 3)
  if(sum(i) > 0) {
    i <- which(i)
    res[i,] <- t(apply(x[i,], 1, bfmxt)) 
  }
  res
  
}
