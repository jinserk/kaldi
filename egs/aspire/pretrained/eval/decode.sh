#!/bin/bash

# options
online=true
do_endpointing=false

exp_dir=../exp/tdnn_7b_chain_online

file=$(basename $1)
name="${file%.*}"
decode_dir=$name

. ./path.sh
. ../utils/parse_options.sh || exit 1;

mkdir -p $decode_dir
sox $1 -t wav -c 1 -r 8000 -e si "$decode_dir/${name}_cv.wav"

online2-wav-nnet3-latgen-faster \
	--online=$online \
	--do-endpointing=$do_endpointing \
	--frame-subsampling-factor=3 \
	--config=$exp_dir/conf/online.conf \
	--max-active=7000 \
	--beam=15.0 \
	--lattice-beam=6.0 \
	--acoustic-scale=1.0 \
	--word-symbol-table=$exp_dir/graph_pp/words.txt \
	$exp_dir/final.mdl \
	$exp_dir/graph_pp/HCLG.fst \
	"ark:echo utterance-id1 utterance-id1|" \
	"scp,p:echo utterance-id1 ${decode_dir}/${name}_cv.wav|" \
	"ark:|gzip -c > $decode_dir/lat.gz" \
	2>&1 | tee "$decode_dir/$name.log"
