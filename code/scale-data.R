reshapeData_attachScaledVariable <- function(
    DF.input        = NULL,
    target.variable = NULL,
    by.variable     = NULL
    ) {


    require(dplyr);

    my.formula <- as.formula(paste0(target.variable," ~ ",by.variable));

    DF.means <- aggregate(formula = my.formula, data = DF.input, FUN = mean);
    colnames(DF.means) <- gsub(
        x           = colnames(DF.means),
        pattern     = target.variable,
        replacement = "mean_target"
        );

    DF.sds <- aggregate(formula = my.formula, data = DF.input, FUN = sd  );
    colnames(DF.sds) <- gsub(
        x           = colnames(DF.sds),
        pattern     = target.variable,
        replacement = "sd_target"
        );

    DF.output <- dplyr::left_join(
        x  = DF.input,
        y  = DF.means,
        by = by.variable
        );

    DF.output <- dplyr::left_join(
        x  = DF.output,
        y  = DF.sds,
        by = by.variable
        );

    DF.output <- as.data.frame(DF.output);

    DF.output[,"scaled_variable"] <- DF.output[, target.variable ] - DF.output[,"mean_target"];
    DF.output[,"scaled_variable"] <- DF.output[,"scaled_variable"] / DF.output[,  "sd_target"];

    colnames(DF.output) <- gsub(
        x           = colnames(DF.output),
        pattern     = "scaled_variable",
        replacement = paste0(target.variable,"_scaled")
        );

    DF.output <- DF.output[,setdiff(colnames(DF.output),c("mean_target","sd_target"))];

    return( DF.output );

}

#' noramlize.remove.mean.global
#' this function removes the global mean of the dataset based on the date then  
#' then subtracts the global mean at the date from every observation for that 
#' date
#' @NOTE: this overwrites the VV variable
normalize.remove.mean.global <- function(
    DF.input,
    target.variable,
    date.column = NULL,
    scale.data = FALSE
)

{
    thisFunctionName <- "normalize.remove.mean.global";

    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n# ",thisFunctionName,"() starts.\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # exit if we dont want to scale data
    if(!scale.data){
    cat(paste0("\nscale.data is set to ",scale.data," not running normalization; returning the input DF...\n"));
        return(DF.input)
    }
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\nscale.data is set to ",scale.data," running normalization ...\n"));
    
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # set defults
    date.column <- if (is.null(date.column)) { date.column <- "date" }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # extract unique date values
    dates.unique <- unique(DF.input[,date.column])
    # create a Dataframe to write the results to
    DF.output <- base::data.frame()

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # for each unique date do the calculation

    for (date in dates.unique) {
        # select a single date to query in the input DF by
        date.select <- as.Date(date, format="%Y-%m-%d", origin="1970-01-01")
        # print(date.select)
        DF.date <- DF.input[DF.input$date == date.select,]

        # calculate global mean of the selecting date
        global.mean <- mean(DF.date[,c(target.variable)])
        # print(global.mean)

        # subtract the global mean from each observation in the table
        DF.date[target.variable] <- lapply(
            X = DF.date[target.variable],
            FUN = function(x){ global.mean - x }
        )

        # write the output to the out data frame
        DF.output <- rbind(DF.output, DF.date)
    }
    return(DF.output)
}