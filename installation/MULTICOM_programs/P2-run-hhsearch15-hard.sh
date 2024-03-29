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

mkdir -p $outputdir/hhsearch15

cd $outputdir

perl /home/jh7x3/multicom_beta1.0/src/meta/hhsearch1.5/script/tm_hhsearch1.5_main_v2.pl /home/jh7x3/multicom_beta1.0/src/meta/hhsearch1.5/hhsearch1.5_option_hard $fastafile hhsearch15  2>&1 | tee hhsearch15.log


printf "\nFinished.."
printf "\nCheck log file <$outputdir/hhsearch15.log>\n\n"


if [[ ! -f "$outputdir/hhsearch15/ss1.pdb" ]];then 
	printf "!!!!! Failed to run hhsearch15, check the installation </home/jh7x3/multicom_beta1.0/src/meta/hhsearch1.5/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/hhsearch15/ss1.pdb $outputdir/$targetid.pdb 
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi


