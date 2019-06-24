#!/usr/bin/perl
# Permanent header for all scripts
use warnings FATAL => 'all';  # treat all warnings as fatal, always die
use autodie qw(:all);         # similar to 'bash -e' -- immediate exit on error
use bigint qw(hex);           # correct 'hex()' for numbers > 32bit
use strict;                   # more warnings for loose/misused syntax
use utf8;                     # non-ASCII support in script/stdin/stdout

# WARN: 'perl -w' != 'use warnings;'
#   https://perlmaven.com/always-use-strict-and-use-warnings
# WARN: 'autodie' don't support exotic 'system { $cmd } @args';
#   http://search.cpan.org/~pjf/autodie-2.29/lib/autodie.pm
#   https://stackoverflow.com/questions/3941632/are-there-disadvantages-to-autodie

use v5.10; # Only needed for 'static vars' -- initialized only once
# E.G. 'state ($var) = 1'
#   https://perldoc.perl.org/feature.html#FEATURE-BUNDLES
#   https://perldoc.perl.org/feature.html#IMPLICIT-LOADING

use 5.014;  # (== 'use v5.14' but w/o warnings)
# USE: for s///r  == substitute into new var instead of in-place

## NOTE: some wide-used C functions
# use POSIX qw/ceil/;
