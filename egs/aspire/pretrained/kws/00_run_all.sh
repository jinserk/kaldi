#!/bin/bash

. ./path.sh || exit 1;

# KWS setup. We leave it commented out by default

data_dir=data
lang_dir=../data/lang_chain
exp_dir=../exp/tdnn_7b_chain_online
graph_dir=$exp_dir/graph_pp
kwsdata_dir=$data_dir
decode_dir=decode
kws_dir=$decode_dir

# decode the test data
#local/nnet3/prep_test_aspire.sh --stage 6 --decode-num-jobs 30 \
#  --acwt 1.0 --post-decode-acwt 10.0 --window 10 --overlap 5 \
#  --sub-speaker-frames 6000 --max-count 75 --ivector-scale 0.75 \
#  --pass2-decode-opts "--min-active 1000" \
#  dev_aspire $lang_dir $graph_dir $exp_dir

# $duration is the length of the search collection, in seconds
#duration=`feat-to-len scp:data/test_eval92/feats.scp  ark,t:- | awk '{x+=$2} END{print x/100;}'`
#local/generate_example_kws.sh data/test_eval92/ data/kws/
#local/kws_data_prep.sh data/lang_test_bd_tgpr/ data/test_eval92/ data/kws/

#duration=`feat-to-len scp:$data_dir/feats.scp  ark,t:- | awk '{x+=$2} END{print x/100;}'`
#local/generate_example_kws.sh $data_dir $kwsdata_dir
kws_data_prep.sh $lang_dir $data_dir $kwsdata_dir

#steps/make_index.sh --cmd "$decode_cmd" --acwt 0.1 \
#  data/kws/ data/lang_test_bd_tgpr/ \
#  exp/tri4b/decode_bd_tgpr_eval92/ \
#  exp/tri4b/decode_bd_tgpr_eval92/kws

make_index.sh --acwt 0.1 $kwsdata_dir $lang_dir $exp_dir $decode_dir $kws_dir

search_index.sh $kwsdata_dir $exp_dir $kws_dir

# If you want to provide the start time for each utterance, you can use the --segments
# option. In WSJ each file is an utterance, so we don't have to set the start time.
duration=`cat $decode_dir/duration`
gunzip -c $kws_dir/result.* | \
  write_kwslist.pl --flen=0.01 --duration=$duration --normalize=true --language=english \
    --kwlist-filename=$kwsdata_dir/raw_keywords.txt \
    --keywords=$kwsdata_dir/keywords.txt --segments=$data_dir/segments \
    --utter-map=$kwsdata_dir/utter_map --utter-id=$kwsdata_dir/utter_id \
    - $kws_dir/kwslist.xml

