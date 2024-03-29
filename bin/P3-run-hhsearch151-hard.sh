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

mkdir -p $outputdir/hhsearch151

cd $outputdir
perl /home/jh7x3/multicom_beta1.0/src/meta/hhsearch151/script/tm_hhsearch151_main.pl /home/jh7x3/multicom_beta1.0/src/meta/hhsearch151/hhsearch151_option_hard $fastafile hhsearch151  2>&1 | tee  hhsearch151.log


printf "\nFinished.."
printf "\nCheck log file <$outputdir/hhsearch151.log>\n\n"


if [[ ! -f "$outputdir/hhsearch151/hg1.pdb" ]];then 
	printf "!!!!! Failed to run hhsearch151, check the installation </home/jh7x3/multicom_beta1.0/src/meta/hhsearch151/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/hhsearch151/hg1.pdb $outputdir/$targetid.pdb 
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi

