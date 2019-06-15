#!/bin/bash

mkdir -p /home/jh7x3/multicom_beta1.0/test_out/T0957s2_multicom/
cd /home/jh7x3/multicom_beta1.0/test_out/T0957s2_multicom/

source /home/jh7x3/multicom_beta1.0/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/home/jh7x3/multicom_beta1.0/tools/boost_1_55_0/lib/:/home/jh7x3/multicom_beta1.0/tools/OpenBLAS:$LD_LIBRARY_PATH

/home/jh7x3/multicom_beta1.0/src/multicom_ve.pl /home/jh7x3/multicom_beta1.0/src/multicom_system_option_casp13 /home/jh7x3/multicom_beta1.0/examples/T0957s2.fasta  /home/jh7x3/multicom_beta1.0/test_out/T0957s2_multicom/   2>&1 | tee  /home/jh7x3/multicom_beta1.0/test_out/T0957s2_multicom.log


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom_beta1.0/test_out/T0957s2_multicom.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom_beta1.0/test_out/T0957s2_multicom/mcomb/casp1.pdb" ]];then 
	printf "!!!!! Failed to run multicom, check the installation </home/jh7x3/multicom_beta1.0/src/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom_beta1.0/test_out/T0957s2_multicom/mcomb/casp1.pdb\n\n"
fi

