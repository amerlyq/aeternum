use Getopt::Std;
$Getopt::Std::STANDARD_HELP_VERSION = 1;

# NOTE
# * keep alphabetic order (ignoring case) of letters
#   => to understand if that switch present fast
# * comment letters directly above getopts() as [o=option ..]
# * process $ARGV[0] only after all other defaults of getopts()
# * no need to comment each section -- same structure in all scripts

## Usage
#   eE=little/big-end F=format N=enumerate
#   n=number s=skip_header v=verbose
my %opts=(); getopts("eEF:hi:n:No:O:sv", \%opts);

## Defaults
my $number = $opts{n} // 1;
# NOTE multiple switches per single variable
my $bom = defined $opts{e} ? "L" : defined $opts{E} ? "N" : "L";  # byte-order
my $fmt  = $opts{F} // (defined $opts{N} ? "%08lx %08lx\n" : "%08lx\n");
# NOTE negate boolean options
my $skip = not ($opts{s} // 0);
my $skip = defined $opts{s} ? 0 : 1;
# Descriptive long names
# my $append_after = $opts{a} // 0;
# my $insert_into = $opts{i} // 0;


## Args
# NOTE fallback values if not specified
my $src = $opts{i} // $ARGV[0] // "/path/to/default/input/file";
my $dst = $opts{o} // "/tmp/output";

## Comma-separated key-value FORMAT: -o key1=val1,key2=val2,...
#   %offsets = (%offsets, split(/[,=]/, $opts{o})) if $opts{o}


## Help
# ALT:BET:(Pod::Usage): http://perldoc.perl.org/Getopt/Long.html#Documentation-and-help-texts
if( $opts{'h'} || (defined $opts{'i'} and not -e $opts{'i'}) ){
print <<HELP;
  File ending conversion
    $0 -ef ./file -o /tmp/dst
  Enumerating file from stdin
    ... | $0 -N
HELP
exit;
}

## Examples
# NOTE asymmetrical way -- set default beforehand, change by options
#   => parse hex() or int() depending on '0x' prefix
my $offset = 0;
if (defined $opts{O}) {
  if (substr($opts{O}, 0, 2) eq '0x') {
    $offset = hex($opts{O});
  } else {
    $offset = int($opts{O});
  }
}

# NOTE symmetrical way -- don't set default, values in branches
#   => directly assign functions names into vars
my ($callback, $format);
if ($opts{p} // 0) {
    $callback = \&proc_plain;
    $format = \&fmt_plain;
} else {
    $callback = \&proc_outline;
    $format = \&fmt_outline;
}

sub proc_plain {
    ...
}

while (<>) {
    next unless /\S/;           # skip empty lines
    $callback->($_) if /rgx/;   # process only matching lines
    print $_ if $opts{'v'};     # conditional shortcut for verbose
}
print $format->($_),"\n" for (@frames);
