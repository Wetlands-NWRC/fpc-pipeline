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

# To Run the pipeline
See example below. <br>
If you are in the fpc-testing dir, and your directory looks like the skeleton in the example. you would go
```sh
$ ../fpc-pipeline/bin/run-diagnostics
```

## Tips for running
- do not remove the shell scipts from the bin folder. the script works of its relative position in the project. if you move it some where else other than fpc-pipeline/bin it will not work as expected
- if you get a permissions denied when executing the shell scripts run the below command, will make the script a executable
```sh 
chmod +x script
```


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

# TODO 
Add citiations / give credit to Ken
