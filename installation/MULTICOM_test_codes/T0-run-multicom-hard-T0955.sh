#!/bin/bash

mkdir -p /home/jh7x3/multicom_beta1.0/test_out/T0955_multicom/
cd /home/jh7x3/multicom_beta1.0/test_out/T0955_multicom/

source /home/jh7x3/multicom_beta1.0/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/home/jh7x3/multicom_beta1.0/tools/boost_1_55_0/lib/:/home/jh7x3/multicom_beta1.0/tools/OpenBLAS:$LD_LIBRARY_PATH

/home/jh7x3/multicom_beta1.0/src/multicom_ve.pl /home/jh7x3/multicom_beta1.0/src/multicom_system_option_casp13 /home/jh7x3/multicom_beta1.0/examples/T0955.fasta  /home/jh7x3/multicom_beta1.0/test_out/T0955_multicom/   2>&1 | tee  /home/jh7x3/multicom_beta1.0/test_out/T0955_multicom.log


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom_beta1.0/test_out/T0955_multicom.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom_beta1.0/test_out/T0955_multicom/mcomb/casp1.pdb" ]];then 
	printf "!!!!! Failed to run multicom, check the installation </home/jh7x3/multicom_beta1.0/src/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom_beta1.0/test_out/T0955_multicom/mcomb/casp1.pdb\n\n"
fi


perl /home/jh7x3/multicom_beta1.0/installation/scripts/validate_integrated_predictions.pl  T0955  /home/jh7x3/multicom_beta1.0/test_out/T0955_multicom/full_length_hard/meta /home/jh7x3/multicom_beta1.0/installation/benchmark/FM/


printf "\nCheck final predictions.."


perl /home/jh7x3/multicom_beta1.0/installation/scripts/validate_integrated_predictions_final.pl  T0955  /home/jh7x3/multicom_beta1.0/test_out/T0955_multicom/mcomb /home/jh7x3/multicom_beta1.0/installation/benchmark/FM/