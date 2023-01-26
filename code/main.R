
command.arguments <- commandArgs(trailingOnly = TRUE);
data.directory    <- normalizePath(command.arguments[1]);
code.directory    <- normalizePath(command.arguments[2]);
output.directory  <- normalizePath(command.arguments[3]);

print( data.directory );
print( code.directory );
print( output.directory );

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

start.proc.time <- proc.time();

# set working directory to output directory
setwd( output.directory );

##################################################
require(arrow);
require(doParallel);
require(foreach);
require(ggplot2);
require(ncdf4);
require(openssl);
require(parallel);
require(raster);
require(terra);
require(terrainr);
require(sf);
require(stringr);
require(tidyr);

require(fpcFeatures);

# source supporting R code
code.files <- c(
    "compute-fpc-scores.R",
    "getData-colour-scheme.R",
    "getData-geojson.R",
    "initializePlot.R",
    "persist-fpc-scores.R",
    "plot-RGB-fpc-scores.R",
    "preprocess-training-data.R",
    "tiff2parquet.R",
    "train-fpc-FeatureEngine.R",
    "utils-rgb.R",
    "visualize-fpc-approximations.R",
    "visualize-training-data.R"
    );

for ( code.file in code.files ) {
    source(file.path(code.directory,code.file));
    }

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
my.seed <- 7654321;
set.seed(my.seed);

is.macOS  <- grepl(x = sessionInfo()[['platform']], pattern = 'apple', ignore.case = TRUE);
n.cores   <- ifelse(test = is.macOS, yes = 2, no = parallel::detectCores() - 1);
cat(paste0("\n# n.cores = ",n.cores,"\n"));

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
dir.geoson   <- file.path(data.directory,"TrainingData_Geojson");
dir.tiffs    <- file.path(data.directory,"img");
dir.parquets <- "parquets-data";
dir.scores   <- "parquets-scores";

target.variable      <- 'VV';
n.harmonics          <- 7;
RData.trained.engine <- 'trained-fpc-FeatureEngine.RData';

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
DF.training <- getData.geojson(
    input.directory = dir.geoson,
    parquet.output  = "DF-training-raw.parquet"
    );

DF.colour.scheme <- getData.colour.scheme(
    DF.training = DF.training
    );

cat("\nstr(DF.colour.scheme)\n");
print( str(DF.colour.scheme)   );

DF.training <- preprocess.training.data(
    DF.input         = DF.training,
    DF.colour.scheme = DF.colour.scheme
    );

arrow::write_parquet(
    sink = "DF-training.parquet",
    x    = DF.training
    );

cat("\nstr(DF.training)\n");
print( str(DF.training)   );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
visualize.training.data(
    DF.training      = DF.training,
    colname.pattern  = "(VV|VH)",
    DF.colour.scheme = DF.colour.scheme,
    output.directory = "plot-training-data"
    );
gc();

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
trained.fpc.FeatureEngine <- train.fpc.FeatureEngine(
    DF.training      = DF.training,
    x                = 'longitude',
    y                = 'latitude',
    land.cover       = 'land_cover',
    date             = 'date',
    variable         = target.variable,
    min.date         = as.Date("2019-01-15"),
    max.date         = as.Date("2019-12-16"),
    n.harmonics      = n.harmonics,
    DF.colour.scheme = DF.colour.scheme,
    RData.output     = RData.trained.engine
    );
gc();
print( str(trained.fpc.FeatureEngine) );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
DF.training[,"latitude_longitude"] <- apply(
    X      = DF.training[,c("latitude","longitude")],
    MARGIN = 1,
    FUN    = function(x) { return(paste(x = x, collapse = "_")) }
    );

visualize.fpc.approximations(
    featureEngine    = trained.fpc.FeatureEngine,
    DF.variable      = DF.training,
    location         = 'latitude_longitude',
    date             = 'date',
    land.cover       = 'land_cover',
    variable         = target.variable,
    n.locations      = 10,
    DF.colour.scheme = DF.colour.scheme,
    my.seed          = my.seed,
    output.directory = "plot-fpc-approximations"
    );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
tiff2parquet(
    dir.tiffs    = dir.tiffs,
    n.cores      = n.cores,
    dir.parquets = dir.parquets
    );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
compute.fpc.scores(
    x                    = 'x',
    y                    = 'y',
    date                 = 'date',
    variable             = target.variable,
    RData.trained.engine = RData.trained.engine,
    dir.parquets         = dir.parquets,
    n.cores              = n.cores,
    dir.scores           = dir.scores
    );

persist.fpc.scores(
    dir.scores = dir.scores,
    variable   = target.variable,
    n.cores    = n.cores
    );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
plot.RGB.fpc.scores(
    dir.tiffs            = dir.tiffs,
    dir.scores           = dir.scores,
    variable             = target.variable,
    x                    = 'x',
    y                    = 'y',
    digits               = 4,
    channel.red          = 'fpc_1',
    channel.green        = 'fpc_2',
    channel.blue         = 'fpc_3',
    parquet.file.stem    = paste0('DF-tidy-scores-',     target.variable),
    PNG.output.file.stem = paste0('plot-RGB-fpc-scores-',target.variable),
    dots.per.inch        = 300,
    n.cores              = n.cores
    );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

##################################################
print( warnings() );

print( getOption('repos') );

print( .libPaths() );

print( sessionInfo() );

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

stop.proc.time <- proc.time();
print( stop.proc.time - start.proc.time );
