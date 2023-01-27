#' Sanitizes Dataframe columns; standardize them for FPC analysis
#' 
sanitize.col.names <- function(
    DF.input = NULL
    ) {
    thisFunctionName <- "sanitize.col.names";

    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n# ",thisFunctionName,"() starts.\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    colnames(DF.input) <- tolower(colnames(DF.input));
    colnames(DF.input) <- gsub(x = colnames(DF.input), pattern = "^class$",   replacement = "land_cover");
    colnames(DF.input) <- gsub(x = colnames(DF.input), pattern = "^cdesc$",   replacement = "land_cover");
    colnames(DF.input) <- gsub(x = colnames(DF.input), pattern = "^point_x$", replacement =  "longitude");    
    colnames(DF.input) <- gsub(x = colnames(DF.input), pattern = "^point_y$", replacement =   "latitude");
    colnames(DF.input) <- gsub(x = colnames(DF.input), pattern = "^lon$",     replacement =  "longitude");
    colnames(DF.input) <- gsub(x = colnames(DF.input), pattern = "^lat$",     replacement =   "latitude");
    colnames(DF.input) <- gsub(x = colnames(DF.input), pattern = "^x$",       replacement =  "longitude")
    colnames(DF.input) <- gsub(x = colnames(DF.input), pattern = "^y$",       replacement =   "latitude");
    colnames(DF.input) <- gsub(x = colnames(DF.input), pattern = "^vv$",      replacement =         "VV");
    colnames(DF.input) <- gsub(x = colnames(DF.input), pattern = "^vh$",      replacement =         "VH");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n# ",thisFunctionName,"() exits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return(DF.input)
}