
rgb.transform <- function(
    x    = NULL,
    xmin = as.numeric(quantile(x = as.matrix(x), probs = c(0.05), na.rm = TRUE)),
    xmax = as.numeric(quantile(x = as.matrix(x), probs = c(0.95), na.rm = TRUE))
    ) {
    x    <- as.matrix(x);
    temp <- 255 * (x - xmin) / (xmax - xmin) ;
    temp <- sapply(X = temp, FUN = function(z) {max(0,min(255,z))} );
    if ( is.matrix(x) ) {
        temp <- matrix(temp, nrow = nrow(x), ncol = ncol(x));
        }
    return(as.numeric(temp));
    }
