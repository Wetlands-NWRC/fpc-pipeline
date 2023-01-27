
preprocess.training.data <- function(
    DF.input         = NULL,
    DF.colour.scheme = NULL,
    target.variable  = NULL
    ) {

    thisFunctionName <- "preprocess-training-data";

    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n# ",thisFunctionName,"() starts.\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output <- DF.input;

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    colnames(DF.output) <- tolower(colnames(DF.output));
    colnames(DF.output) <- gsub(x = colnames(DF.output), pattern = "^class$",   replacement = "land_cover");
    colnames(DF.output) <- gsub(x = colnames(DF.output), pattern = "^cdesc$",   replacement = "land_cover");
    colnames(DF.output) <- gsub(x = colnames(DF.output), pattern = "^point_x$", replacement =  "longitude");
    colnames(DF.output) <- gsub(x = colnames(DF.output), pattern = "^POINT_X$", replacement =  "longitude");
    colnames(DF.output) <- gsub(x = colnames(DF.output), pattern = "^point_y$", replacement =   "latitude");
    colnames(DF.output) <- gsub(x = colnames(DF.output), pattern = "^POINT_Y$", replacement =   "latitude");
    colnames(DF.output) <- gsub(x = colnames(DF.output), pattern = "^lon$",     replacement =  "longitude");
    colnames(DF.output) <- gsub(x = colnames(DF.output), pattern = "^lat$",     replacement =   "latitude");
    colnames(DF.output) <- gsub(x = colnames(DF.output), pattern = "^x$",       replacement =  "longitude")
    colnames(DF.output) <- gsub(x = colnames(DF.output), pattern = "^y$",       replacement =   "latitude");
    colnames(DF.output) <- gsub(x = colnames(DF.output), pattern = "^vv$",      replacement =         "VV");
    colnames(DF.output) <- gsub(x = colnames(DF.output), pattern = "^vh$",      replacement =         "VH");
    colnames(DF.output) <- gsub(x = colnames(DF.output), pattern = "^ch$",      replacement =         "CH");
    colnames(DF.output) <- gsub(x = colnames(DF.output), pattern = "^cv$",      replacement =         "CV");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output[,'date'] <- as.Date(DF.output[,'date']);

    DF.output[,'land_cover'] <- factor(
        x      = DF.output[,       'land_cover'],
        levels = DF.colour.scheme[,'land_cover']
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output <- DF.output[order(DF.output$latitude,DF.output$longitude,DF.output$date),];

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output[,'lat_lon'] <- apply(
        X      = DF.output[,c('latitude','longitude')],
        MARGIN = 1,
        FUN    = function(x) {return(paste(x,collapse="_"))}
        );

    DF.output['year'] <- sapply(
        X = DF.output[,c('date')],
        FUN = function(x) {return (format(x, "%Y"))}
    )

    DF.output[,"X_Y_year" ] <- paste(DF.output[,"longitude"],
    DF.output[,"latitude"] ,DF.output[,"year"],sep = "_");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    colnames.to.retain <- c(
        'latitude',
        'longitude',
        'lat_lon',
        'land_cover',
        'date'
        );

    colnames.to.retain <- append(
        x = colnames.to.retain,
        values = c(target.variable),
        after = 5
    )

    DF.output <- DF.output[,colnames.to.retain];

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n# ",thisFunctionName,"() exits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( DF.output );

    }

##################################################
