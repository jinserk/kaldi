#!/bin/bash

. ./path.sh || exit 1;

# KWS setup. We leave it commented out by default

lang_dir=../data/lang_chain
exp_dir=../exp/tdnn_7b_chain_online
graph_dir=$exp_dir/graph_pp

data_dir=data
kws_dir=kws

if [ ! -f "$kws_dir/raw_keywords.txt" ]; then
  echo "no such file $kws_dir/raw_keywords.txt"
  exit 1
fi

# Create keyword id for each keyword

cat $kws_dir/raw_keywords.txt | perl -e '
  $idx=1;
  while(<>) {
    chomp;
    printf "ICS-%04d $_\n", $idx;
    $idx++;
  }' > $kws_dir/keywords.txt

# Map the keywords to integers; note that we remove the keywords that
# are not in our $langdir/words.txt, as we won't find them anyway...

cat $kws_dir/keywords.txt | \
  ../utils/sym2int.pl --map-oov 0 -f 2- $lang_dir/words.txt | \
  grep -v " 0 " | grep -v " 0$" > $kws_dir/keywords.int

# Compile keywords into FSTs

transcripts-to-fsts ark:$kws_dir/keywords.int ark:$kws_dir/keywords.fsts

# Search indices

search_index.sh $data_dir $exp_dir $kws_dir

# If you want to provide the start time for each utterance, you can use the --segments
# option. In WSJ each file is an utterance, so we don't have to set the start time.

duration=`cat $data_dir/duration`
gunzip -c $kws_dir/result.* | \
  write_kwslist.pl --flen=0.01 --duration=$duration --normalize=false --language=english \
    --kwlist-filename=$kws_dir/raw_keywords.txt \
    --keywords=$kws_dir/keywords.txt --segments=$data_dir/segments \
    --utter-map=$data_dir/utter_map --utter-id=$data_dir/utter_id \
    --verbose 2 \
    - $kws_dir/kwslist.xml

