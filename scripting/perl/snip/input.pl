#!/usr/bin/perl

while (<<>>) {
  print "$ARGV:$.: $_";
} continue { close ARGV if eof ARGV }
