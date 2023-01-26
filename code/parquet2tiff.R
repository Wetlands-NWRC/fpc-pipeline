#' Used to convert score parquets to tiff format
#' this assuems that the imput y,x paris are reguallrly 
#' spaced coordinates else will rasir error
parquet2tiff <- function(
  dir.scores.parquet    = NULL,
  n.cores               = 1,
  dir.scores.tiff       = NULL,
  fpc.bands             = NULL,
  x                     = NULL,
  y                     = NULL
) {

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # Set defults
    if(is.null(dir.scores.parquet)) {dir.scores.parquet <- "parquets-scores"}
    if(is.null(dir.scores.tiff)){dir.scores.tiff <- "tiffs-scores"}
    if(is.null(x)){x <- "x" }
    if(is.null(y)){y <- "y" }
    if(is.null(fpc.bands)) {fpc.bands <- c('fpc_1', 'fpc_2', 'fpc_3')}
  
    thisFunctionName <- "parquet2tiff";

    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n# ",thisFunctionName,"() starts.\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

    if ( dir.exists(dir.scores.tiff) ) {
        cat(paste0("\n# The folder ",dir.scores.tiff," already exists; will not redo calculations ...\n"));
        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        cat(paste0("\n# ",thisFunctionName,"() exits."));
        cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
        return( NULL );
    } else {
        cat(paste0("\n# The folder ",dir.scores.tiff," does not exists; creating", dir.scores.tiff, "...\n"));
        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        dir.create(dir.scores.tiff)
        cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(arrow);
    require(rgdal);
    require(raster);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

    fpc.xyz <- c(x, y, fpc.bands)

    # get parquet files from scoreds dir
    parquet.scores <- list.files(
      path = dir.scores.parquet,
      pattern = '\\.parquet$',
      full.names = TRUE
    )

    for (scores in parquet.scores) {
       # load parquet
       loads.parquet <- arrow::read_parquet(
         file = scores
       )
       DF.scores <- base::as.data.frame(loads.parquet)
       
       # sanitize the file path extract the tail, this is the 
       # name of the tif
       sanitized.path <- basename(scores)
       tiff.name.out <- file.path(dir.scores.tiff, sanitized.path)
       r <- raster::rasterFromXYZ(DF.scores[, fpc.xyz])
      #  raster::crs(r) <- "EPSG:4326"
       writeRaster(r, tiff.name.out, format = "GTiff")
       remove(list = c("loads.parquet", "DF.scores", "r"))
    }
  return(NULL)
}