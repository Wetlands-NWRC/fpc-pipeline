# FPC - Pipeline
FPCA Pipeline provides access to Running FPCA pipeline End to End

## Before you start
What you will need 
- A computer that has Ubuntu >= 18, or MacOSX 
- A minimum of 32 GB of RAM, anything greater than 64 GB of ram is prefered
- the More CPU cores the better this was developed and ran on a machine with 16 cores / 8 CPUs  
<br>

# Initial Setup
## Setup fpcFeatures R Package
 
```sh
# Step 1): Clone the Repo
$ git clone https://github.com/Wetlands-NWRC/fpc-pipeline.git
```

```shell
# Step 2): change the dir to where you cloned the repo
$ cd ./fpc-pipeline
```

```sh
# step 3: create the base conda environment and activate the environment
$ conda create --name fpc-r-env
$ conda activate fpc-r-env
```
```sh
# Step 4: run the package install helper scripts from the activate env
$ (fpc-r-env) ./scripts/install-pkg-dep
```
```shell
# step 5: from the command line boot up an R Terminal
(fpc-r-env)$ R
# or Radian
(fpc-r-env)$ radian
```
```R
# step 6: install the fpcFeatures package tarball
>> install.packages(repos = NULL, type = "source", pkgs = "pkg/fpcFeatures_0.0.0.0001.tar.gz" )
# step 7: check to see if it was installed correctly
>> library(fpcFeatures)
# or to boot up the help documentation
>> browsVignettes("fpcFeatures")
```

## Setting up the pipeline
- run helper script to install pipeline dependencies
```commandline 
(fpc-r-env) $  ./scripts/install-pipe-dep
```
# Running the pipeline
To run the pipeline you need 3 pieces. 

1. code directory
2. your data
3. run-main or run-diagnostics

1 and 3 are modular you can move them were ever as long as they stay together. You cant run one without the other.

## Project setup
```
# Example Project setup
├── project-root
│   ├── code
│   │   ├── R modules
|   ├── data
│   │   ├── img
│   │   └── training_data
│   ├── run-main
```
- Assuming you project follow this structure. You need to open up the run script file and edit the dataDir variable, the path need to be relative to where the run scripts are located. 
```sh
# update this to point to the root of where your data is stored
dataDIR=${currentDIR}/data

# for example if the data dir was one level up from were the run scripts are it would look like this
dataDIR=${currentDIR}/../data
```
## Running scripts
- After you have made the appropriate changes to the run script you intend on running. just run the shell scripts from the command line
```commandline
(fpc-r-env) $ run-diagnostics
```

## Tips for running
- if you get a permissions denied when executing the shell scripts run the below command, will make the script a executable
```sh
chmod +x script
```


# Sample Directory Structure
```
── project-root
    ├── data
    │   ├── colours.json
    │   |── training_data
    │   |    ├── training_data_1_17.geojson
    │   |    ├── training_data_2_17.geojson
    │   |    ├── training_data_3_17.geojson
    │   |    ├── ...
    |   ├── img
    │   │   ├── S1_20190408_IW
    │   │   │   ├── S1_20190408_IW0000000000-0000000000.tif
    │   │   │   ├── S1_20190408_IW0000000000-0000000064.tif
    │   │   │   ├── S1_20190408_IW0000000000-0000000128.tif
    │   │   │   ├── S1_20190408_IW0000000000-0000000192.tif
    |   |   |   ├── ...
    |   |   ├── S1_YYYYMMdd_IW
    │   │   │   ├── S1_YYYYMMdd_IW0000000000-0000000000.tif
    │   │   │   ├── S1_YYYYMMdd_IW0000000000-0000000064.tif
    │   │   │   ├── S1_YYYYMMdd_IW0000000000-0000000128.tif
    │   │   │   ├── S1_YYYYMMdd_IW0000000000-0000000192.tif
    |   |   |   ├── ...   
``` 

# Sample Diagnostics Output 
```
└── output
        └── VV
            ├── code
            |   ├── R source files
            │   
            ├── DF-training.parquet
            ├── DF-training-raw.parquet
            ├── DF-VV-scores-training-2019.csv
            ├── plot-fpc-approximations
            │   ├── fpc-approximation-VV-agriculture-2019-45.4743068206469_-74.8298574506347.png
            │   ├── fpc-approximation-VV-agriculture-2019-45.4756569906309_-74.816500700304.png
            │   ├── ...
            ├── plot-training-data
            │   ├── ribbon-2019-VV-fixed.png
            │   ├── ribbon-2019-VV.png
            │   └── timeseries-2019-VV.png
            ├── plot-VV-harmonics.png
            ├── plot-VV-scores-2019.png
            ├── stderr.R.diagnostics
            ├── stdout.R.diagnostics
            └── trained-fpc-FeatureEngine.RData

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

NOTE:

If you would like to you are able to directly install this into your global R environment. All you need to do is to remove the 'r-' prefix from the package name and use R's buildin package installer method (``` install.packages ```).

However you should note that some of these packages have C++ bindings that need to be installed along with the package, as well as other dependencies that do not get automatically installed. 

<br><br>

# TODO 
Add citiations / give credit to Ken
