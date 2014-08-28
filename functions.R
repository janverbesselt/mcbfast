# functions

## percentage NA's
f_pna <- function(x) { sum(is.na(x)) / length(x) }
f_stats <- function(x) {
  o1 <- round(f_pna(x)*100) # obtain integer values
  o2 <- round(mean(x,na.rm=TRUE))
  return(c(o1, o2))
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

# Function to feed to rasterEngine:
bfastmonitor_rasterEngine <- function(rasterTS, start, ...)
{
  library("bfast")
  library("raster")
  rasterTS_dims <- dim(rasterTS)
  npixels <- prod(dim(rasterTS)[1:2])
  ndates <- dim(rasterTS)[3]
  
  # "Flatten" the input array to a 2-d matrix:
  dim(rasterTS) <- c(npixels,ndates)
  # Run bfastmonitor pixel-by-pixel:
  bfm_out <- foreach(i=seq(npixels),.packages=c("bfast","zoo","raster"),.combine=rbind) %do% {
      bfts <- ts(rasterTS[i,], start=c(2000,2), freq=12)
      bfm <- bfastmonitor(data=bfts, start=start)
      return(c(bfm$breakpoint, bfm$magnitude))
  }
  
  # Coerce the output back to the correct size array:
  dim(bfm_out) <- c(rasterTS_dims[1:2], 2)
  return(bfm_out)
}

# Function to feed to rasterEngine:
zooaggregate_array <- function(rasterTS, ...)
{
  # cpus - number of cores to run on (for parallel processing). Default is "max", which is half of the available cores.
  library("bfast")
  rasterTS_dims <- dim(rasterTS)
  npixels <- prod(dim(rasterTS)[1:2])
  ndates <- dim(rasterTS)[3]
  
  # "Flatten" the input array to a 2-d matrix:
  dim(rasterTS) <- c(npixels,ndates)
  # Run bfastmonitor pixel-by-pixel:
  agg_out <- foreach(i=seq(npixels), .packages=c("bfast"), .combine=rbind) %do% {
    zts <- ts(as.numeric(rasterTS[i,]), start=c(2000,2), freq=12)
    out <- as.ts(aggregate(as.zoo(zts), as.yearqtr, mean, na.rm=TRUE))
    return(as.numeric(round(out)))
  }
  # Coerce the output back to the correct size array:
  dim(agg_out) <- c(rasterTS_dims[1:2], 48)
  return(agg_out)
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
