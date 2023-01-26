#!/bin/bash

# data_snapshot=NULL
#
# for argument in "$@"
# do
#     key=$(  echo $argument | cut -f1 -d=)
#     value=$(echo $argument | cut -f2 -d=)
#
#     if [[ $key == *"--"* ]]; then
#         v="${key/--/}"
#         declare $v="${value}"
#    fi
# done
#
# args=()
# args+=( '--data_snapshot' ${data_snapshot} )

##################################################
currentDIR=`pwd`
   codeDIR=${currentDIR}/code
 outputDIR=${currentDIR}/output

parentDIR=`dirname ${currentDIR}`
dataDIR=${parentDIR}/data

if [ ! -d ${outputDIR} ]; then
	mkdir -p ${outputDIR}
fi

cp -r ${codeDIR} ${outputDIR}
cp    $0         ${outputDIR}/code

##################################################
myRscript=${codeDIR}/main.R
stdoutFile=${outputDIR}/stdout.R.`basename ${myRscript} .R`
stderrFile=${outputDIR}/stderr.R.`basename ${myRscript} .R`
R --no-save --args ${dataDIR} ${codeDIR} ${outputDIR} < ${myRscript} > ${stdoutFile} 2> ${stderrFile}

##################################################
exit
