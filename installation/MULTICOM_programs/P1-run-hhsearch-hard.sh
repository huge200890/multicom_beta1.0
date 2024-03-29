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

mkdir -p $outputdir/hhsearch

cd $outputdir

perl /home/jh7x3/multicom_beta1.0/src/meta/hhsearch/script/tm_hhsearch_main_v2.pl /home/jh7x3/multicom_beta1.0/src/meta/hhsearch/hhsearch_option_hard $fastafile hhsearch  2>&1 | tee   run_hhsearch.log

printf "\nFinished.."
printf "\nCheck log file <$outputdir/run_hhsearch.log>\n\n"


if [[ ! -f "$outputdir/hhsearch/hh1.pdb" ]];then 
	printf "!!!!! Failed to run hhsearch, check the installation </home/jh7x3/multicom_beta1.0/src/meta/hhsearch/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/hhsearch/hh1.pdb $outputdir/$targetid.pdb 
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi

