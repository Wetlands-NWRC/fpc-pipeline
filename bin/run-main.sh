#!/bin/bash

if [ $# -eq 0 ] 
then
  echo "Setting Default Value"
  targetVar="VV"
else
  targetVar=$1
fi

##################################################
DIR_PATH=`dirname ${BASH_SOURCE:-$0}`
codeDIR=${DIR_PATH}/../code

##################################################
currentDIR=`pwd`
outputDIR=${currentDIR}/output/${targetVar}

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
R --no-save --args ${dataDIR} ${codeDIR} ${outputDIR} ${targetVar} < ${myRscript} > ${stdoutFile} 2> ${stderrFile}

##################################################
exit
