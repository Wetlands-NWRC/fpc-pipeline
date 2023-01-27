
compute.fpc.scores <- function(
    x                    = 'longitude',
    y                    = 'latitude',
    date                 = 'date',
    variable             = NULL,
    RData.trained.engine = NULL,
    dir.parquets         = NULL,
    n.cores              = NULL,
    dir.scores           = 'fpc-scores'
    ) {

    thisFunctionName <- "compute.fpc.scores";

    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n# ",thisFunctionName,"() starts.\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(raster);
    require(stringr);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( dir.exists(dir.scores) ) {
        cat(paste0("\n# The folder ",dir.scores," already exists; will not redo calculations ...\n"));
        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        cat(paste0("\n# ",thisFunctionName,"() exits."));
        cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
        return( NULL );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    compute.fpc.scores_inner(
        x                    = x,
        y                    = y,
        date                 = date,
        variable             = variable,
        RData.trained.engine = RData.trained.engine,
        dir.parquets         = dir.parquets,
        n.cores              = n.cores,
        dir.scores           = dir.scores
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n# ",thisFunctionName,"() exits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
compute.fpc.scores_inner <- function(
    x                    = NULL,
    y                    = NULL,
    date                 = NULL,
    variable             = NULL,
    RData.trained.engine = NULL,
    dir.parquets         = NULL,
    n.cores              = 1,
    dir.scores           = 'fpc-scores'
    ) {

    require(doParallel);
    require(foreach);
    require(parallel);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( !dir.exists(dir.scores) ) { dir.create(path = dir.scores, recursive = TRUE) }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    doParallel::registerDoParallel(n.cores);

    data.parquets <- list.files(path = dir.parquets, pattern = "data-.+\\.parquet");
    foreach ( data.parquet = data.parquets ) %dopar% {

        temp.log <- data.parquet;
        temp.log <- gsub(x = temp.log, pattern = "\\.parquet", replacement = ".log");
        temp.log <- gsub(x = temp.log, pattern = "^data-",     replacement = "sink-");

        temp.sink <- file(description = file.path(dir.scores,temp.log), open = "wt");
        sink(file = temp.sink, type = "output" );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");

        # print system time to log
        cat(paste0("\n##### Sys.time(): ",Sys.time(),"\n"));

        start.proc.time <- proc.time();

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        DF.batch <- arrow::read_parquet(file.path(dir.parquets,data.parquet));

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        y_x <- paste0(y,'_',x);
        DF.batch[,y_x] <- apply(
            X      = DF.batch[,c(y,x)],
            MARGIN = 1,
            FUN    = function(z) {return(paste0(z[1],'_',z[2]))}
            );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        trained.fpc.FeatureEngine <- readRDS(file = RData.trained.engine);

        DF.scores <- trained.fpc.FeatureEngine$transform(
            newdata  = DF.batch[,c(y_x,date,variable)],
            location = y_x,
            date     = date,
            variable = variable
            );

        bspline.colnames <- grep(x = colnames(DF.scores), pattern = "^[0-9]+$", value = TRUE);
        DF.scores        <- DF.scores[,setdiff(colnames(DF.scores),bspline.colnames)];

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        DF.scores[,y     ] <- as.numeric(gsub(x = DF.scores[,y_x], pattern = "_.+", replacement = ""));
        DF.scores[,x     ] <- as.numeric(gsub(x = DF.scores[,y_x], pattern = ".+_", replacement = ""));
        DF.scores[,'year'] <- as.numeric(DF.scores[,'year']);
        DF.scores <- DF.scores[,c(y,x,setdiff(colnames(DF.scores),c(y,x,y_x)))];

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        scores.parquet <- gsub(x = data.parquet, pattern = "^data-", replacement = "scores-");
        arrow::write_parquet(
            sink = file.path(dir.scores,scores.parquet),
            x    = DF.scores
            );

        base::remove(list = c("trained.fpc.FeatureEngine","DF.batch","DF.scores","bspline.colnames","scores.parquet"));
        base::gc();

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        cat("\nshowConnections()\n");
        print( showConnections()   );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
        # print warning messages to log
        cat("\n##### warnings()\n")
        print(warnings());

        # print session info to log
        cat("\n##### sessionInfo()\n")
        print( sessionInfo() );

        # print system time to log
        cat(paste0("\n##### Sys.time(): ",Sys.time(),"\n"));

        # print elapsed time to log
        stop.proc.time <- proc.time();
        cat("\n##### start.proc.time() - stop.proc.time()\n");
        print( stop.proc.time - start.proc.time );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        sink(file = NULL, type = "output" );
        sink();

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    return( NULL );

    }
