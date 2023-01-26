
tiff2parquet <- function(
    dir.tiffs    = NULL,
    n.cores      = 1,
    dir.parquets = "parquets"
    ) {

    thisFunctionName <- "tiff2parquet";

    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n# ",thisFunctionName,"() starts.\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(raster);
    require(stringr);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( dir.exists(dir.parquets) ) {
        cat(paste0("\n# The folder ",dir.parquets," already exists; will not redo calculations ...\n"));
        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        cat(paste0("\n# ",thisFunctionName,"() exits."));
        cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
        return( NULL );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.dates <- tiff2parquet_get.dates(dir.tiffs = dir.tiffs);

    cat("\nstr(DF.dates)\n");
    print( str(DF.dates)   );

    cat("\nDF.dates\n");
    print( DF.dates   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.tiff.filenames <- tiff2parquet_get.tiff.filenames(
        dir.tiffs = dir.tiffs,
        DF.dates  = DF.dates
        );

    cat("\nstr(DF.tiff.filenames)\n");
    print( str(DF.tiff.filenames)   );

    cat("\nDF.tiff.filenames[1:100,]\n");
    print( DF.tiff.filenames[1:100,]   );

    write.csv(
        x         = DF.tiff.filenames,
        file      = "DF-tiff-filenames.csv",
        row.names = FALSE
        );

    arrow::write_parquet(
        x    = DF.tiff.filenames,
        sink = "DF-tiff-filenames.parquet"
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    tiff2parquet_persist(
        dir.tiffs         = dir.tiffs,
        DF.tiff.filenames = DF.tiff.filenames,
        n.cores           = n.cores,
        dir.parquets      = dir.parquets
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n# ",thisFunctionName,"() exits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
tiff2parquet_persist <- function(
    dir.tiffs         = NULL,
    DF.tiff.filenames = NULL,
    dir.parquets      = "parquets",
    n.cores           = 1
    ) {

    require(doParallel);
    require(foreach);
    require(parallel);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.batches <- unique(DF.tiff.filenames[,c('year','batch')]);
    DF.batches[,'parquet'] <- apply(
        X      = DF.batches[,c('year','batch')],
        MARGIN = 1,
        FUN    = function(x) { return(paste0("data-",x[1],"-",x[2],".parquet")) }
        );
    rownames(DF.batches) <- seq(1,nrow(DF.batches));

    write.csv(
        x         = DF.batches,
        file      = "DF-batches.csv",
        row.names = FALSE
        );

    arrow::write_parquet(
        x    = DF.batches,
        sink = "DF-batches.parquet"
        );

    cat("\nstr(DF.batches)\n");
    print( str(DF.batches)   );

    cat("\nDF.batches[1:10,]\n");
    print( DF.batches[1:10,]   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( !dir.exists(dir.parquets) ) { dir.create(path = dir.parquets, recursive = TRUE) }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    doParallel::registerDoParallel(n.cores);

  # for ( batch.index in seq(1,2) ) {
  # for ( batch.index in seq(1,nrow(DF.batches)) ) {
  # foreach ( batch.index = seq(1,4) ) %dopar% {
    foreach ( batch.index = seq(1,nrow(DF.batches)) ) %dopar% {

        temp.year    <- DF.batches[batch.index,'year'];
        temp.batch   <- DF.batches[batch.index,'batch'];
        temp.parquet <- DF.batches[batch.index,'parquet'];

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        temp.log <- temp.parquet;
        temp.log <- gsub(x = temp.log, pattern = "\\.parquet", replacement = ".log");
        temp.log <- gsub(x = temp.log, pattern = "^data-",     replacement = "sink-");

        temp.sink <- file(description = file.path(dir.parquets,temp.log), open = "wt");
        sink(file = temp.sink, type = "output" );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");

        # print system time to log
        cat(paste0("\n##### Sys.time(): ",Sys.time(),"\n"));

        start.proc.time <- proc.time();

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        DF.tiffs <- DF.tiff.filenames[DF.tiff.filenames$year == temp.year,];
        DF.tiffs <- DF.tiffs[DF.tiffs$batch == temp.batch,];

        DF.data <- data.frame();
        for ( tiff.index in seq(1,nrow(DF.tiffs)) ) {
            temp.date    <- DF.tiffs[tiff.index,'date'];
            temp.dir     <- DF.tiffs[tiff.index,'directory'];
            temp.tiff    <- DF.tiffs[tiff.index,'tiff'];
            temp.path    <- file.path(dir.tiffs,temp.dir,temp.tiff);
            cat("\ntemp.path\n");
            print( temp.path   );
            temp.stack  <- raster::stack(x = temp.path);
            # temp.values <- raster::getValues(x = temp.stack);
            temp.values <- cbind(raster::coordinates(obj = temp.stack),raster::getValues(x = temp.stack));
            colnames(temp.values) <- tiff2parquet_clean.colnames(
                x         = colnames(temp.values),
                directory = temp.dir
                );
            temp.colnames <- colnames(temp.values);
            temp.values <- as.data.frame(temp.values);
            temp.values[,'date'] <- rep(x = temp.date, times = nrow(temp.values));
            temp.values <- temp.values[,c('date',temp.colnames)];
            cat("\nstr(temp.values)\n");
            print( str(temp.values)   );
            # cat("\ntemp.values[1:10,]\n");
            # print( temp.values[1:10,]   );
            DF.data <- rbind(DF.data,temp.values);
            base::remove(list = c("temp.values"))
            base::gc();
            }

        arrow::write_parquet(
            sink = file.path(dir.parquets,temp.parquet),
            x    = DF.data
            );

        base::remove(list = c("DF.data"))
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

tiff2parquet_clean.colnames <- function(
    x         = NULL,
    directory = NULL
    ) {
    temp.pattern  <- paste0("(",paste( x = unlist(strsplit(x = directory,split="_")), collapse = "|" ),")");
    temp.colnames <- gsub(x = x, pattern = temp.pattern, replacement = "");
    temp.colnames <- gsub(
        x           = temp.colnames,
        pattern     = "[0-9]{4}",
        replacement = ""
        );
    temp.colnames <- gsub(
        x           = temp.colnames,
        pattern     = "_{2,}",
        replacement = "_"
        );
    temp.colnames <- gsub(
        x           = temp.colnames,
        pattern     = "^_",
        replacement = ""
        );
    temp.colnames <- gsub(
        x           = temp.colnames,
        pattern     = "^[0-9]+_",
        replacement = ""
        );
    return(temp.colnames);
    }

tiff2parquet_get.tiff.filenames <- function(
    dir.tiffs    = NULL,
    DF.dates     = NULL,
    tiff.pattern = "\\.tif{1,2}$"
    ) {

    DF.output <- data.frame();
    for ( row.index in base::seq(1,base::nrow(DF.dates)) ) {

        temp.dir   <- DF.dates[row.index,'directory'];
        temp.year  <- DF.dates[row.index,'year'     ];
        temp.date  <- DF.dates[row.index,'date'     ];

        tiff.filenames <- base::list.files(
            path    = base::file.path(dir.tiffs,temp.dir),
            pattern = tiff.pattern
            );

        batch.names <- tiff.filenames;
        batch.names <- gsub(x = batch.names, pattern = temp.dir,     replacement = "");
        batch.names <- gsub(x = batch.names, pattern = tiff.pattern, replacement = "");

        DF.temp <- data.frame(
            year      = rep(x = temp.year, times = length(tiff.filenames)),
            batch     = batch.names,
            date      = rep(x = temp.date, times = length(tiff.filenames)),
            directory = rep(x = temp.dir,  times = length(tiff.filenames)),
            tiff      = tiff.filenames
            );

        DF.output <- rbind(DF.output,DF.temp);

        base::remove(list = c("DF.temp"));
        base::gc();

        }

    DF.output <- DF.output[order(DF.output$year,DF.output$batch,DF.output$date),];
    return( DF.output );

    }

tiff2parquet_get.dates <- function(
    dir.tiffs    = NULL,
    date.pattern = "[0-9]{8}",
    date.format  = "%Y%m%d"
    ) {

    require(stringr);

    image.directories <- base::list.files(
        path    = dir.tiffs,
        pattern = date.pattern
        );

    image.dates <- base::as.Date(
        x = stringr::str_extract(
            string  = image.directories,
            pattern = date.pattern
            ),
        format = date.format
        );

    DF.output <- data.frame(
        directory = image.directories,
        year      = format(x = image.dates, format = "%Y"),
        date      = image.dates
        );

    return( DF.output );

    }
