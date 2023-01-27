
convert.to.dB <- function(x, value=0) {
    if (x < 0) {
        return(value)
    }
    else {
        dB.value <- log10(x) * 10
        return(dB.value) 
    }
}