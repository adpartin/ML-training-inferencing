#!/bin/bash
export PATH=$PATH:/homes/brettin/covid19/ML-Code
[ $# -eq 0 ] && {
	echo ""
	echo "Usage: "$(basename $0)" <num_inputs> <input_file_prefix> (not more than total GPUs)"
	echo ""
	echo "This program takes as input the numbea file of csv file paths on which to "
	echo "run infer15.py against the V3.April_9 models"
	echo ""
	echo "input_file_prefix is the prefix of the split, ie ZINC_descriptors.input"
	echo "num_inputs is the number of split files, not to exceed num GPUS on the node"
	echo ""
	exit 1
}

max_device=$(( $1-1 ))
dh=/homes/brettin/covid19/ML-Code/descriptor_headers.csv
th=/homes/brettin/covid19/ML-Code/training_headers.csv

mkdir -p DIR.$2
pushd DIR.$2

for m in $(find /lambda_stor/data/brettin/ML-models/V3.April_9 -name "*.autosave.model.h5") ; do
	d=$(basename $(dirname $m ))
	mkdir -p $d
	pushd $d
	for n in $(seq 0 $max_device) ; do 
		export CUDA_VISIBLE_DEVICES=$(( $n % 8 ))
		echo "CUDA_VISIBLE_DEVICES = $CUDA_VISIBLE_DEVICES"
		echo "running reg_go_infer.sh ../../"$2"0$n $m $dh $th"
		reg_go_infer.sh ../../"$2"0$n $m $dh $th > 0$n.log 2>&1 &
	done
	popd
	wait
done
popd
