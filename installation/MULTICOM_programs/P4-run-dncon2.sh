#!/bin/bash

if [ $# != 3 ]; then
	echo "$0 <target id> <fasta> <output-directory>"
	exit
fi

targetid=$1
fastafile=$2
outputdir=$3

mkdir -p $outputdir
cd $outputdir

if [[ "$fastafile" != /* ]]
then
   echo "Please provide absolute path for $fastafile"
   exit
fi

if [[ "$outputdir" != /* ]]
then
   echo "Please provide absolute path for $outputdir"
   exit
fi

mkdir -p $outputdir/

cd $outputdir
/home/jh7x3/multicom_beta1.0/tools/DNCON2/dncon2-v1.0.sh $fastafile $outputdir/  2>&1 | tee  $outputdir/dncono2.log


printf "\nFinished.."
printf "\nCheck log file <$outputdir/dncono2.log>\n\n"


if [[ ! -f "$outputdir/$targetid.dncon2.rr" ]];then 
	printf "!!!!! Failed to run DNCON2, check the installation </home/jh7x3/multicom_beta1.0/tools/DNCON2/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: $outputdir/$targetid.dncon2.rr\n\n"
fi

