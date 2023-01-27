# FPC - Pipeline
FPCA Pipeline provides access to Running FPCA pipeline End to End

## Before you start
What you will need 
- A computer that has Ubuntu >= 18, or MacOSX 
- A minimum of 32 GB of RAM, anything greater than 64 GB of ram is prefered
- the More CPU cores the better this was developed and ran on a machine with 16 cores / 8 CPUs  

# Pipeline Setup
Step 1): Clone the Repo 
```sh
$ git clone https://github.com/Wetlands-NWRC/fpc-pipeline.git
```

Step 2): Create a base conda environment
```sh
$ conda create --name some-env-name
```
the above env will be the base environemtn to which we will install all the pipeline dependencies

Step 3) cd into the pipeline directory
```sh
$ cd /to/where/you/cloned/the/pipeline/fpc-pipeline
```

Step 4): activate the base environment
```sh
$ conda activate some-env-name
```

Step 5): Run install-dep, assuming you are in the root of the pipeline
```sh
$ (some-env-name) bin/install-dep
```
the above command will install r conda dependencies into the activated base env

Step 6) Install the fpcFeatureEngine R Package, boot up an R terminal from the activte conda env and enter:
```R
install.packages(repos = NULL, type = "source", pkgs = "pkg/fpcFeatures_0.0.0.0001.tar.gz" )
```
the above assumes that you are running the r terminal from the root (fpc-pipelines)

# Seting up a FPC Project
Sample Directory Structure
```
├── fpc-pipeline
│   ├── bin
│   │   ├── install-dep
│   │   ├── run-diagnostics
│   │   └── run-main
│   ├── code
│   │   ├── Code for Pipeline
│   ├── environment.yaml
│   ├── LICENSE
│   ├── pkg
│   │   └── fpcFeatures_0.0.0.0001.tar.gz
│   └── README.md
└── fpc-testing
    ├── data
    │   ├── colours.json
    │   └── training_data
    │       ├── training_data_1_17.geojson
    │       ├── training_data_2_17.geojson
    │       ├── training_data_3_17.geojson
    │       ├── ...
```

# Sample Diagnostics Output 
```
```

# R Conda Packages - house keeping
Note that these are just the dependencies and not how to install them
## Dependencies for Fpc Package
- r-cowplot
- r-dplyr
- r-fda
- r-ggplot2
- r-logger
- r-lubridate
- r-R6

## local pipeline dependencies
- r-arrow
- r-doParallel
- r-foreach
- r-gdalUtils
- r-openssl
- r-magick
- r-raster
- r-sf
- r-readr
- r-stringr
- r-tidyr

## r-arrow install
``` sh
$ conda install -c arrow-nightlies -c conda-forge --strict-channel-priority r-arrow
```

# TODO 
Add citiations / give credit to Ken
