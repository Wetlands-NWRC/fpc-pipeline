
visualize.training.data <- function(
    DF.training      = NULL,
    colname.pattern  = NULL,
    DF.colour.scheme = data.frame(
        row.names  = c("marsh",  "swamp",  "water",  "forest", "ag",     "shallow"),
        land_cover = c("marsh",  "swamp",  "water",  "forest", "ag",     "shallow"),
        colour     = c("#000000","#E69F00","#56B4E9","#009E73","#F0E442","red"    )
        ),
    plot.timeseries  = TRUE,
    plot.heatmaps    = TRUE,
    output.directory = NULL
    ) {

    thisFunctionName <- "visualize.training.data";

    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    require(ggplot2);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( dir.exists(output.directory) ) {
        cat(paste0("\nThe directory ",output.directory," already exists; will not re-generate its contents.\n"));
        cat(paste0("\n",thisFunctionName,"() quits."));
        cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
        return( NULL );
        }

    if ( !dir.exists(output.directory) ) {
        dir.create(path = output.directory, recursive = TRUE);
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.training[,'year'] <- format(x = DF.training[,'date'], format = "%Y");
    DF.training[,'lat_lon_year'] <- apply(
        X      = DF.training[,c('latitude','longitude','year')],
        MARGIN = 1,
        FUN    = function(x) { return(paste(x,collapse = "_")) }
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( plot.timeseries ) {

        visualize.training.data_groupedTimeSeries(
            DF.training      = DF.training,
            colname.pattern  = colname.pattern,
            DF.colour.scheme = DF.colour.scheme,
            output.directory = output.directory
            );

        visualize.training.data_timeSeriesRibbonPlots(
            DF.training      = DF.training,
            colname.pattern  = colname.pattern,
            DF.colour.scheme = DF.colour.scheme,
            output.directory = output.directory
            );

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    remove(list = c('DF.training'));
    gc();
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
visualize.training.data_timeSeriesRibbonPlots <- function(
    DF.training      = NULL,
    colname.pattern  = NULL,
    DF.colour.scheme = NULL,
    output.directory = NULL
    ) {

    require(ggplot2);
    require(dplyr);

    years            <- unique(DF.training[,"year"]);
    target.variables <- grep(x = colnames(DF.training), pattern = colname.pattern, value = TRUE);

    for ( year            in years            ) {
    for ( target.variable in target.variables ) {

        PNG.output <- paste0('ribbon-',year,'-',target.variable,'.png');
        PNG.output <- file.path(output.directory,PNG.output);

        cat("\ngenerating: ",PNG.output,"\n");

        is.current.year   <- (DF.training[,"year"] == year);
        DF.temp           <- DF.training[is.current.year,c("date","land_cover",target.variable)];
        colnames(DF.temp) <- gsub(
            x           = colnames(DF.temp),
            pattern     = target.variable,
            replacement = "target.variable"
            );

        DF.temp <- DF.temp %>%
            dplyr::group_by( date, land_cover ) %>%
            dplyr::summarize(
                target_mean = mean(target.variable, na.rm = TRUE),
                target_sd   =   sd(target.variable, na.rm = TRUE)
                );

        DF.temp <- as.data.frame(DF.temp);
        DF.temp[,"target_mean_plus_sd" ] <- DF.temp[,"target_mean"] + DF.temp[,"target_sd"];
        DF.temp[,"target_mean_minus_sd"] <- DF.temp[,"target_mean"] - DF.temp[,"target_sd"];

        cat("\nstr(DF.temp)\n");
        print( str(DF.temp)   );

        cat("\nDF.temp\n");
        print( DF.temp   );

        cat("\nlevels(DF.temp[,'land_cover'])\n");
        print( levels(DF.temp[,'land_cover'])   );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        cat("\nas.character(unique(DF.temp[,'land_cover']))\n");
        print( as.character(unique(DF.temp[,'land_cover']))   );

        cat("\nDF.colour.scheme\n");
        print( DF.colour.scheme   );

        cat("\nDF.colour.scheme[DF.colour.scheme[,'land_cover'] %in% as.character(unique(DF.temp[,'land_cover'])),]\n");
        print( DF.colour.scheme[DF.colour.scheme[,'land_cover'] %in% as.character(unique(DF.temp[,'land_cover'])),]   );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        my.ggplot <- initializePlot(
            title      = NULL,
            subtitle   = paste0(year,", ",target.variable),
            my.palette = DF.colour.scheme[DF.colour.scheme[,"land_cover"] %in% as.character(unique(DF.temp[,"land_cover"])),"colour"]
            );

        my.ggplot <- my.ggplot + xlab(label = NULL);
        my.ggplot <- my.ggplot + ylab(label = NULL);

        my.ggplot <- my.ggplot + scale_x_date(
            breaks       = sort(unique(DF.temp[,"date"])),
            minor_breaks = NULL
            );

        my.ggplot <- my.ggplot + theme(
            legend.position = "none",
            axis.text.x     = element_text(angle = 90, vjust = 0.5)
            );

        my.ggplot <- my.ggplot + geom_ribbon(
            data    = DF.temp,
            mapping = aes(x = date, ymin = target_mean_minus_sd, ymax = target_mean_plus_sd, fill = land_cover),
            alpha   = 0.2
            );

        my.ggplot <- my.ggplot + geom_line(
            data    = DF.temp,
            mapping = aes(x = date, y = target_mean),
            colour  = "black",
            size    = 1.3,
            alpha   = 0.5
            );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        my.ggplot <- my.ggplot + facet_grid(land_cover ~ ., scales = "free_y");

        ggsave(
            file   = PNG.output,
            plot   = my.ggplot,
            dpi    = 150,
            height =  16,
            width  =  16,
            units  = 'in'
            );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        PNG.output <- paste0('ribbon-',year,'-',target.variable,'-fixed.png');
        PNG.output <- file.path(output.directory,PNG.output);

        cat("\ngenerating: ",PNG.output,"\n");

        if ( grepl(x = target.variable, pattern = "_scaled$") ) {
            my.ggplot <- my.ggplot + scale_y_continuous(
                limits = c(  -3,3),
                breaks = seq(-3,3,1)
                );
        } else {
            my.ggplot <- my.ggplot + scale_y_continuous(
                limits = c(  -40,20),
                breaks = seq(-40,20,10)
                );
            }

        my.ggplot <- my.ggplot + facet_grid(land_cover ~ ., scales = "fixed");

        ggsave(
            file   = PNG.output,
            plot   = my.ggplot,
            dpi    = 150,
            height =  16,
            width  =  16,
            units  = 'in'
            );

        remove(list = c('DF.temp','my.ggplot'));
        gc();

        }}

    return( NULL );

    }

visualize.training.data_groupedTimeSeries <- function(
    DF.training      = NULL,
    colname.pattern  = NULL,
    DF.colour.scheme = NULL,
    output.directory = NULL
    ) {

    require(ggplot2);

    years            <- unique(DF.training[,"year"]);
    target.variables <- grep(x = colnames(DF.training), pattern = colname.pattern, value = TRUE);

    for ( year            in years            ) {
    for ( target.variable in target.variables ) {

        PNG.output <- paste0('timeseries-',year,'-',target.variable,'.png');
        PNG.output <- file.path(output.directory,PNG.output);

        cat("\ngenerating: ",PNG.output,"\n");

        is.current.year   <- (DF.training[,"year"] == year);
        DF.temp           <- DF.training[is.current.year,c("lat_lon_year","date","land_cover",target.variable)];
        colnames(DF.temp) <- gsub(
            x           = colnames(DF.temp),
            pattern     = target.variable,
            replacement = "target.variable"
            );

        my.ggplot <- initializePlot(
            title      = NULL,
            subtitle   = paste0(year,", ",target.variable),
            my.palette = DF.colour.scheme[DF.colour.scheme[,"land_cover"] %in% as.character(unique(DF.temp[,"land_cover"])),"colour"]
            );

        my.ggplot <- my.ggplot + xlab(label = NULL);
        my.ggplot <- my.ggplot + ylab(label = NULL);

        my.ggplot <- my.ggplot + scale_x_date(
            breaks       = sort(unique(DF.temp[,"date"])),
            minor_breaks = NULL
            );

        my.ggplot <- my.ggplot + theme(
            legend.position = "none",
            axis.text.x     = element_text(angle = 90, vjust = 0.5)
            );

        if ( grepl(x = target.variable, pattern = "_scaled$") ) {
            my.ggplot <- my.ggplot + scale_y_continuous(
                limits = c(  -3,3),
                breaks = seq(-3,3,1)
                );
        } else {
            my.ggplot <- my.ggplot + scale_y_continuous(
                limits = c(  -40,20),
                breaks = seq(-40,20,10)
                );
            }

        my.ggplot <- my.ggplot + geom_line(
            data    = DF.temp,
            mapping = aes(x=date,y=target.variable,group = lat_lon_year, color = land_cover),
            alpha   = 0.3
            );

        my.ggplot <- my.ggplot + facet_grid(land_cover ~ .);

        ggsave(
            file   = PNG.output,
            plot   = my.ggplot,
            dpi    = 150,
            height =  16,
            width  =  16,
            units  = 'in'
            );

        remove(list = c('DF.temp','my.ggplot'));
        gc();

        }}

    return( NULL );

    }
