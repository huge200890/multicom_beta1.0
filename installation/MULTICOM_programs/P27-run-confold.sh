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

mkdir -p $outputdir/confold

cd $outputdir
sh /home/jh7x3/multicom_beta1.0/src/meta/confold2/script/tm_confold2_main.sh /home/jh7x3/multicom_beta1.0/src/meta/confold2/CONFOLD_option $fastafile confold  2>&1 | tee  confold.log


printf "\nFinished.."
printf "\nCheck log file <$outputdir/confold.log>\n\n"


if [[ ! -f "$outputdir/confold/confold2-1.pdb" ]];then 
	printf "!!!!! Failed to run confold, check the installation </home/jh7x3/multicom_beta1.0/src/meta/confold2/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/confold/confold2-1.pdb $outputdir/$targetid.pdb 
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi

