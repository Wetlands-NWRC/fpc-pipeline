
getData.colour.scheme <- function(
    DF.training = NULL
    ) {

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

    boq.land.covers     <- c("marsh","swamp","water","forest","ag","shallow_water");
    train.land.covers   <- sort(unique(DF.training[,'land_cover']));
    unknown.land.covers <- setdiff(train.land.covers,boq.land.covers);

    if ( length(unknown.land.covers) == 0 ) {
        DF.colour.scheme <- data.frame(
            land_cover = boq.land.covers,
            colour     = c("#000000","#E69F00","#56B4E9","#009E73","#F0E442","red")
            );
    } else {
        DF.colour.scheme <- data.frame(
            land_cover = train.land.covers,
            colour     = getData.colour.scheme_random.palette(n.colours = length(train.land.covers))
            );
        }

    rownames(DF.colour.scheme) <- DF.colour.scheme[,"land_cover"];
    return(DF.colour.scheme);

    }


getData.colour.scheme.json <- function(
    DF.training = NULL,
    colours.json = NULL
) {

    land.covers <- sort(unique(DF.training[, "land_cover"]))

    if (!file.exists(colours.json)){
        DF.colour.scheme <- data.frame(
            land_cover = land.covers,
            colour = getData.colour.scheme_random.palette(length(land.covers))
        )
        rownames(DF.colour.scheme) <- DF.colour.scheme[, "land_cover"]
        json.obj <- jsonlite::write_json(
            x = DF.colour.scheme,
            path = colours.json,
            pretty = TRUE,
        )
        return(DF.colour.scheme)
    }
    else{
        DF.colour.scheme <- data.frame()
        json.obj <- jsonlite::fromJSON(txt = colours.json)
        DF.colour.scheme <- rbind(DF.colour.scheme, json.obj)

        DF.colour.scheme <- update.colours.json(
            DF.colour.scheme = DF.colour.scheme,
            land.cover = land.covers,
            colours.json = colours.json
        )

        return(DF.colour.scheme)
    }
}


##################################################
getData.colour.scheme_random.palette <- function(
    n.colours = 10
    ) {
    DF.temp <- data.frame(
        index  = seq(1,n.colours),
        colour = character(n.colours)
        );
    DF.temp[,'colour'] <- apply(
        X      = DF.temp,
        MARGIN = 1,
        FUN    = function(x) {
            return(paste0("#",paste(sample(x = as.character(c(seq(0,9),"A","B","C","D","E","F")), size = 6, replace = TRUE), collapse = "")))
            }
        );
    return( DF.temp[,'colour'] );
    }


update.colours.json <- function(
    DF.colour.scheme = NULL,
    land.cover       = NULL,
    colours.json     = NULL
) {
    diff <- setdiff(land.cover, DF.colour.scheme[,"land_cover"])
    needsUpdate <- length(diff) > 0

    if(needsUpdate) {
        DF.update <- data.frame(
            land_cover = diff,
            colour = getData.colour.scheme_random.palette(length(diff))
        )
        rownames(DF.update) <- diff
        DF.colour.scheme <- rbind(DF.colour.scheme, DF.update)
        jsonlite::write_json(
            x = DF.colour.scheme,
            path = colours.json,
            pretty = TRUE
        )
        return(DF.colour.scheme)
    }
    else {
       return(DF.colour.scheme)
    }
}