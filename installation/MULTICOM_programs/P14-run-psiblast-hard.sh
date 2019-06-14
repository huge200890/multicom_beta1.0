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

mkdir -p $outputdir/psiblast

cd $outputdir
perl /home/jh7x3/multicom_v1.1/src/meta/psiblast/script/main_psiblast_v2.pl /home/jh7x3/multicom_v1.1/src/meta/psiblast/psiblast_option_hard  $fastafile psiblast  2>&1 | tee  psiblast.log



printf "\nFinished.."
printf "\nCheck log file <$outputdir/psiblast.log>\n\n"


if [[ ! -f "$outputdir/psiblast/psiblast1.pdb" ]];then 
	printf "!!!!! Failed to run psiblast, check the installation </home/jh7x3/multicom_v1.1/src/meta/psiblast/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/psiblast/psiblast1.pdb $outputdir/$targetid.pdb 
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi
