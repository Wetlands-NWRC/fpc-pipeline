
getData.geojson <- function(
    input.directory = NULL,
    parquet.output  = "geojson.parquet",
    to.dB           = FALSE,
    target.variable = NULL,
    func            = NULL
    ) {

    thisFunctionName <- "getData.geojson";

    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n# ",thisFunctionName,"() starts.\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(arrow);
    require(jsonlite);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( file.exists(parquet.output) ) {

        cat(paste0("\nThe file ",parquet.output," already exists; loading the file ...\n"));
        DF.output <- arrow::read_parquet(file = parquet.output);

    } else {

        cat(paste0("\nThe file ",parquet.output," does not yet exists; processing json files ...\n"));
        # TODO throw exception if the len of geojson.files == 0
        geojson.files <- list.files(path = input.directory, pattern = "\\.geojson$");
        cat("\ngeojson.files\n");
        print( geojson.files   );

        DF.output <- data.frame();
        for ( geojson.file in geojson.files ) {
            temp.path <- file.path(input.directory,geojson.file);
            cat(paste0("\nprocessing ",temp.path));
            json.obj  <- jsonlite::fromJSON(txt = temp.path);
            DF.output <- rbind(DF.output,json.obj$features$properties);
            }
        cat("\n\n");

        if(to.dB){
            DF.output[target.variable] <- apply(
                X = DF.output[target.variable],
                MARGIN = 1,
                FUN = func
            )
        }

        arrow::write_parquet(
            sink = parquet.output,
            x    = DF.output
            );

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n# ",thisFunctionName,"() exits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( DF.output );

    }

##################################################
