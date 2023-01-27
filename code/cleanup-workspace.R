#' Removes all non essential files
#' if DEBUG is set to TRUE will not remove any files from the current dir

run.cleanup <- function(DUBUG = FALSE, things.to.remove = NULL) {
    thisFunctionName <- "run.cleanup";

    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n# ", thisFunctionName, "() starts.\n"));


    if (DEBUG) {
        cat(paste0("\n# DEBUG is set to ",DEBUG," will keep all output files ...\n"));
        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        cat(paste0("\n# ", thisFunctionName, "() exits."));
        cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");

        return(NULL)
    }

    if (is.null(things.to.remove)) {
        things.to.remove <- c()

    }


    for (file in things.to.remove) {
        if(file.exists(file)) {
            unlink(file, recursive = TRUE)
        }
    }

    cat(paste0("\n# ",thisFunctionName,"() exits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");

    return(NULL)

}