#!/usr/bin/perl
#%SUMMARY: standalone filter
use warnings FATAL => 'all';
use autodie;
use strict;
use 5.010;  # for '//' -- fallback if not defined

# REF: http://perldoc.perl.org/Getopt/Long.html
#   TUT: https://stackoverflow.com/questions/1183876/what-are-the-best-practices-for-implementing-a-cli-tool-in-perl
# SEE: auto_help
use Getopt::Long qw(GetOptions :config bundling permute
no_auto_abbrev no_getopt_compat no_ignore_case no_pass_through);

use constant OFS => $ENV{ORS} // " ";
use constant ORS => $ENV{ORS} // $/;
my $US = $ENV{US} // "\t";  # =IFS/OFS delimiter

$SIG{PIPE} = sub { exit };

my %opts = ( unbuffered => !!$ENV{REELF_LINE_BUFFERED} );
GetOptions(\%opts   #%OPTIONS:
, 'quiet|q:+',    # count repeated options with optional override argument
, 'hexval|x=o',   # allow hex,oct,bin number
, 'ftable|f=s',   # simple string save
, 'htable|t=t%',  # accumulate key=val to hash [ -t nm1=val1 ... -t nm2=val2 ]
, 'tree-acc|a=s%' => sub { push(@{$mmap{$_[1]}}, $_[2]) },  # accumulate values into same key of hash
, 'delimiter|d=s' => \$US  # save into var
, 'reference|F=s'   #% f:= reference | file with extents constituting space
#%
# , 'help|h' => \&help,  # call function
, 'help|h|?'        #% h = help
    => sub { local $_ = join('',&help); s/\.\/\$0\b/\Q${\basename($0)}\E/g; print $_; exit }
    # => sub { print &help; exit }
, 'unbuffered|u!'   #% u = unbuffered | use statement-buffered stdout
, 'output|o=s'      #% o:= output
) or die $/,&help;  #%

$opts{reference} //= shift @ARGV // die "Err: need reference",$/,&help;

die &help if -t STDIN and not @ARGV;
open STDOUT, '>', $opts{output} if $opts{output};
select((select(STDOUT), $|=1)[0]) if $opts{unbuffered};

sub help { open STDIN,'<',$0; grep { $_ } map { $1.$/ if /^(?:.*\s)?#%(.*)/ } <STDIN> }

## Merge keys from two hashmaps and override
my %table = ($opts{ftable} ? read_file($opts{ftable}) : ());
%table = (%table, %{$opts{htable}}) if $opts{htable};
die "Err: use '-f' or '-t' to specify list of key-values" if not %table;
