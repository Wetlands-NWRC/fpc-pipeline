
getData.colour.scheme <- function(
    DF.training = NULL
    ) {

    colnames(DF.training) <- tolower(colnames(DF.training));
    colnames(DF.training) <- gsub(x = colnames(DF.training), pattern = "^class$", replacement = "land_cover");
    colnames(DF.training) <- gsub(x = colnames(DF.training), pattern = "^cdesc$", replacement = "land_cover");

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
