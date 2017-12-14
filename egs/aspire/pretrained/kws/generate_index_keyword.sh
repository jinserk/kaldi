#!/bin/bash

# Copyright 2012  Johns Hopkins University (Author: Guoguo Chen)
# Apache 2.0.


if [ $# -ne 2 ]; then
   echo "Usage: local/generate_index_keyword.sh <text-file> <index-dir>"
   echo " e.g.: local/generate_index_keyword.sh data/train/text index"
   exit 1;
fi

text=$1;
kwsdatadir=$2;

mkdir -p $kwsdatadir;

# Generate keywords; we generate 20 unigram keywords with at least 20 counts,
# 20 bigram keywords with at least 10 counts and 10 trigram keywords with at
# least 5 counts.
cat $text | perl -e '
  %unigram = ();
  %bigram = ();
  %trigram = ();
  while(<>) {
    chomp;
    @col=split(" ", $_);
    shift @col;
    for($i = 0; $i < @col; $i++) {
      # unigram case
      if (!defined($unigram{$col[$i]})) {
        $unigram{$col[$i]} = 0;
      }
      $unigram{$col[$i]}++;

      # bigram case
      if ($i < @col-1) {
        $word = $col[$i] . " " . $col[$i+1];
        if (!defined($bigram{$word})) {
          $bigram{$word} = 0;
        }
        $bigram{$word}++;
      }

      # trigram case
      if ($i < @col-2) {
        $word = $col[$i] . " " . $col[$i+1] . " " . $col[$i+2];
        if (!defined($trigram{$word})) {
          $trigram{$word} = 0;
        }
        $trigram{$word}++;
      }
    }
  }

  $min_count = 20;
  foreach $x (keys %unigram) {
    if ($unigram{$x} >= $min_count) {
      print "$x\n";
    }
  }
  
  $min_count = 4;
  foreach $x (keys %bigram) {
    if ($bigram{$x} >= $min_count) {
      print "$x\n";
    }
  }

  $min_count = 3;
  foreach $x (keys %trigram) {
    if ($trigram{$x} == $min_count) {
      print "$x\n";
    }
  }
  ' > $kwsdatadir/raw_keywords.txt

echo "Keywords generation succeeded"
