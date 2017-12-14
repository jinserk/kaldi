#!/bin/bash

. ./path.sh || exit 1;

# KWS setup. We leave it commented out by default

lang_dir=../data/lang_chain
exp_dir=../exp/tdnn_7b_chain_online

data_dir=data
index_dir=$data_dir

# Create utterance id for each utterance; Note that by "utterance" here I mean
# the keys that will appear in the lattice archive. You may have to modify here

cat $data_dir/segments | \
  awk '{print $1}' | \
  sort | uniq | perl -e '
  $idx=1;
  while(<>) {
    chomp;
    print "$_ $idx\n";
    $idx++;
  }' > $data_dir/utter_id

# Map utterance to the names that will appear in the rttm file. You have 
# to modify the commands below accoring to your rttm file. In the WSJ case
# since each file is an utterance, we assume that the actual file names will 
# be the "names" in the rttm, so the utterance names map to themselves.

#cat $datadir/segments | \
#  awk '{print $1}' | \
#  sort | uniq | perl -e '
#  while(<>) {
#    chomp;
#    print "$_ $_\n";
#  }' > $kwsdatadir/utter_map;
cat $data_dir/segments | \
  awk '{print $1" "$2}' | \
  sort | uniq > $data_dir/utter_map;

# Make indices for the utterances

make_index.sh --acwt 0.1 $data_dir $lang_dir $exp_dir $data_dir $index_dir

