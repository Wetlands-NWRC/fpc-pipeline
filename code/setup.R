options(warn = -1)

require(configr)

#' used to load a YAML file that contains runtime
#' returns a list of key, value pairs
setup.workspace <- function(config) {
    if(!file.exists(config)){
        e.message <- paste0(config, "Does not exist...")
        stop(e.message)
    }
    config <- read.config(config)

    return(config)
}