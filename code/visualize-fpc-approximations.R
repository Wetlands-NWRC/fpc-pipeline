
visualize.fpc.approximations <- function(
    featureEngine    = NULL,
    DF.variable      = NULL,
    location         = NULL,
    date             = NULL,
    land.cover       = NULL,
    variable         = NULL,
    n.locations      = 10,
    DF.colour.scheme = data.frame(
        row.names  = c("marsh",  "swamp",  "water",  "forest", "ag",     "shallow"),
        land_cover = c("marsh",  "swamp",  "water",  "forest", "ag",     "shallow"),
        colour     = c("#000000","#E69F00","#56B4E9","#009E73","#F0E442","red"    )
        ),
    my.seed          = 7654321,
    output.directory = NULL
    ) {

    thisFunctionName <- "visualize.fpc.approximations";

    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( dir.exists(output.directory) ) {
        cat(paste0("\n The directory ",output.directory," already exists; will not regenerate its contents ...\n"));
        cat(paste0("\n",thisFunctionName,"() exits."));
        cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
        return( NULL );
    } else {
        dir.create(path = output.directory, recursive = TRUE);
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.temp <- DF.variable;
    DF.temp[,"year"] <- format(x = DF.variable[,date], format = "%Y");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    land.covers <- unique(DF.temp[,land.cover]);
    years       <- unique(DF.temp[,'year'    ]);

    set.seed(my.seed);
    for ( temp.land.cover in land.covers ) {
    for ( temp.year       in years       ) {

        is.selected    <- (temp.land.cover == DF.temp[,land.cover]) & (temp.year == DF.temp[,'year']);
        temp.locations <- unique(DF.temp[is.selected,location]);

        cat(paste0("\n",thisFunctionName,"(): str(temp.locations) -- land.cover = ",temp.land.cover,", temp.year = ",temp.year,"\n"));
        print( str(temp.locations) );

        temp.locations <- sample(x = temp.locations, size = n.locations, replace = TRUE);
        for ( temp.location in temp.locations ) {
            PNG.output <- file.path(output.directory,paste0("fpc-approximation-",variable,"-",temp.land.cover,"-",temp.year,"-",temp.location,".png"));
            if ( !file.exists(PNG.output) ) {
                DF.location <- DF.temp[is.selected & (DF.temp[,location] == temp.location),];
                cat(paste0("\n",thisFunctionName,"(): str(DF.locations) -- land.cover = ",temp.land.cover,", temp.year = ",temp.year,"\n"));
                print( str(DF.location) );
                my.ggplot <- featureEngine$plot.approximations(
                    DF.input = DF.location,
                    location = location,
                    date     = date,
                    variable = variable
                    );
                ggplot2::ggsave(
                    filename = PNG.output,
                    plot     = my.ggplot,
                    dpi      = 300,
                    height   =   4,
                    width    =  16,
                    units    = "in"
                    );
                }
            }

        }}

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }
