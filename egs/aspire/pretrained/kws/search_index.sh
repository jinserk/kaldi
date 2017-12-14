#!/bin/bash

# Copyright 2012  Johns Hopkins University (Author: Guoguo Chen)
# Apache 2.0

# Begin configuration section.  
cmd=../utils/run.pl
nbest=-1
strict=true
frame_subsampling_factor=3
# End configuration section.

echo "$0 $@"  # Print the command line for logging

. ./path.sh || exit 1;
. ../utils/parse_options.sh || exit 1;

if [ $# != 3 ]; then
   echo "Usage: steps/search_index.sh [options] <data-dir> <exp-dir> <kws-dir>"
   echo " e.g.: steps/search_index.sh data/kws exp/sgmm2_5a_mmi/decode/kws/"
   echo ""
   echo "main options (for others, see top of script file)"
   echo "  --cmd (utils/run.pl|utils/queue.pl <queue opts>) # how to run jobs."
   echo "  --nbest <int>                                    # return n best results. (-1 means all)"
   exit 1;
fi


datadir=$1;
expdir=$2;
kwsdir=$3;

mkdir -p $kwsdir/log;
nj=`cat $datadir/num_jobs` || exit 1;
if [ -f $kwsdir/keywords.fsts.gz ]; then
  keywords="\"gunzip -c $kwsdir/keywords.fsts.gz|\""
elif [ -f $kwsdir/keywords.fsts ]; then
  keywords=$kwsdir/keywords.fsts;
else
  echo "$0: no such file $kwsdir/keywords.fsts[.gz]" && exit 1;
fi

for f in $datadir/index.1.gz ; do
  [ ! -f $f ] && echo "make_index.sh: no such file $f" && exit 1;
done

if [ -z "$frame_subsampling_factor" ]; then
  if [ -f $expdir/frame_subsampling_factor ] ; then
    frame_subsampling_factor=$(cat $expdir/frame_subsampling_factor)
  else 
    frame_subsampling_factor=1
  fi
  echo "$0: Frame subsampling factor autodetected: $frame_subsampling_factor"
fi

$cmd JOB=1:$nj $kwsdir/log/search.JOB.log \
  kws-search --strict=$strict --negative-tolerance=-1 \
  --frame-subsampling-factor=${frame_subsampling_factor} \
  "ark:gzip -cdf $datadir/index.JOB.gz|" ark:$keywords \
  "ark,t:|gzip -c > $kwsdir/result.JOB.gz" \
  "ark,t:|gzip -c > $kwsdir/stats.JOB.gz" || exit 1;

exit 0;
