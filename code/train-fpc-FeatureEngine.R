
train.fpc.FeatureEngine <- function(
    DF.training         = NULL,
    x                   = 'lon',
    y                   = 'lat',
    land.cover          = 'land_cover',
    date                = 'date',
    variable            = 'VV',
    min.date            = NULL,
    max.date            = NULL,
    n.partition         = 100,
    n.order             =   3,
    n.basis             =   9,
    smoothing.parameter =   0.1,
    n.harmonics         =   7,
    RData.output        = 'trained-fpc-FeatureEngine.RData',
    DF.colour.scheme    = NULL
    ) {

    thisFunctionName <- "train.fpc.FeatureEngine";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(fpcFeatures);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    y_x <- paste(x = c(y, x), collapse = "_");
    DF.training <- DF.training[,c(y,x,land.cover,date,variable)];
    DF.training[,y_x] <- apply(
        X      = DF.training[,c(y,x)],
        MARGIN = 1,
        FUN    = function(x) { return(paste(x,collapse="_")) }
        );

    DF.land.cover <- unique(DF.training[,c(y_x,land.cover)]);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( (!is.null(RData.output)) & file.exists(RData.output) ) {

        trained.fpc.FeatureEngine <- readRDS(file = RData.output);

    } else {

        trained.fpc.FeatureEngine <- fpcFeatureEngine$new(
            training.data       = DF.training,
            location            = y_x,
            date                = date,
            variable            = variable,
            min.date            = min.date,
            max.date            = max.date,
            n.partition         = n.partition,
            n.order             = n.order,
            n.basis             = n.basis,
            smoothing.parameter = smoothing.parameter,
            n.harmonics         = n.harmonics
            );

        trained.fpc.FeatureEngine$fit();

        if ( !is.null(RData.output) ) {
            saveRDS(file = RData.output, object = trained.fpc.FeatureEngine);
            }

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    PNG.harmonics <- paste0("plot-",variable,"-harmonics.png");
    if ( !file.exists(PNG.harmonics) ) {
        ggplot2::ggsave(
            file   = PNG.harmonics,
            plot   = trained.fpc.FeatureEngine$plot.harmonics(),
            dpi    = 150,
            height =   4 * n.harmonics,
            width  =  16,
            units  = 'in'
            );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.training[,'year'] <- format(x = DF.training[,'date'], format = "%Y");

    years <- unique(DF.training[,'year']);
    for ( temp.year in years ) {

        PNG.temp.year <- paste0("plot-",variable,"-scores-",temp.year,".png");
        CSV.temp.year <- paste0("DF-",variable,"-scores-training-",temp.year,".csv")
        if ( !file.exists(PNG.temp.year) ) {

            DF.temp <- DF.training[DF.training[,'year'] == temp.year,];
            DF.fpc <- trained.fpc.FeatureEngine$transform(
                newdata  = DF.temp,
                location = y_x,
                date     = date,
                variable = variable
                );
            remove(list = c("DF.temp"));

            DF.fpc <- merge(
                x    = DF.fpc,
                y    = DF.land.cover,
                by.x = y_x,
                by.y = y_x
                );
            DF.fpc <- DF.fpc[,c(y_x,'year',land.cover,paste0('fpc_',1:n.harmonics))]

            train.fpc.FeatureEngine_score.scatterplot(
                DF.fpc           = DF.fpc,
                year             = temp.year,
                DF.colour.scheme = DF.colour.scheme,
                PNG.output       = PNG.temp.year
                );

            DF.fpc[,c(y,x)] <- matrix(
                ncol  = 2,
                byrow = TRUE,
                data  = apply(
                    X      = DF.fpc[c(y_x,'year')],
                    MARGIN = 1,
                    FUN    = function(x) { return(as.numeric(unlist(strsplit(x = x[1], split = "_")))) }
                    )
                );
            DF.fpc <- DF.fpc[,c(y,x,setdiff(colnames(DF.fpc),c(y,x)))];


            write.csv(
                x         = DF.fpc,
                file      = CSV.temp.year,
                row.names = FALSE
                );

            remove(list = c("DF.fpc"));
            gc();

            }

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    remove(list = c("DF.training"));
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( trained.fpc.FeatureEngine );

    }

##################################################
train.fpc.FeatureEngine_score.scatterplot <- function(
    DF.fpc           = NULL,
    year             = NULL,
    DF.colour.scheme = NULL,
    textsize.title   = 50,
    textsize.axis    = 35,
    PNG.output       = NULL
    ) {

    my.palette <- DF.colour.scheme[,"colour"];

    my.ggplot <- ggplot2::ggplot(data = NULL) + ggplot2::theme_bw();
    my.ggplot <- my.ggplot + ggplot2::theme(
        title            = ggplot2::element_text(size = textsize.title, face = "bold"),
        axis.title.x     = ggplot2::element_text(size = textsize.axis,  face = "bold"),
        axis.title.y     = ggplot2::element_text(size = textsize.axis,  face = "bold"),
        axis.text.x      = ggplot2::element_text(size = textsize.axis,  face = "bold"),
        axis.text.y      = ggplot2::element_text(size = textsize.axis,  face = "bold"),
        strip.text.y     = ggplot2::element_text(size = textsize.axis,  face = "bold"),
        legend.title     = element_blank(),
        legend.text      = ggplot2::element_text(size = textsize.axis),
        panel.grid.major = ggplot2::element_line(colour = "gray", linetype = 2, size = 0.25),
        panel.grid.minor = ggplot2::element_line(colour = "gray", linetype = 2, size = 0.25)
        );

    my.ggplot <- my.ggplot + ggplot2::labs(title = NULL, subtitle = year);
    my.ggplot <- my.ggplot + ggplot2::scale_colour_manual(values = my.palette);
    my.ggplot <- my.ggplot + ggplot2::scale_fill_manual(  values = my.palette);
    my.ggplot <- my.ggplot + guides(
        colour = guide_legend(override.aes = list(alpha =  0.75, size = 5))
        )

    my.ggplot <- my.ggplot + scale_x_continuous(limits = 300*c(-1,1), breaks = seq(-300,300,100))
    my.ggplot <- my.ggplot + scale_y_continuous(limits = 150*c(-1,1), breaks = seq(-150,150, 50))

    my.ggplot <- my.ggplot + ggplot2::xlab("FPC 1 score")
    my.ggplot <- my.ggplot + ggplot2::ylab("FPC 2 score")

    my.ggplot <- my.ggplot + geom_point(
        data    = DF.fpc,
        mapping = aes(x = fpc_1, y = fpc_2, colour = land_cover),
        size    = 0.5,
        alpha   = 0.5
        )

    ggplot2::ggsave(
        file   = PNG.output,
        plot   = my.ggplot,
        dpi    = 150,
        height =  14,
        width  =  18,
        units  = 'in'
        );

    }
