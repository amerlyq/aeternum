# REF: http://perldoc.perl.org/Getopt/Long.html
#   TUT: https://stackoverflow.com/questions/1183876/what-are-the-best-practices-for-implementing-a-cli-tool-in-perl
# SEE: auto_help
use Getopt::Long qw(GetOptions :config bundling permute
    no_auto_abbrev no_getopt_compat no_ignore_case no_pass_through);

my $US = $ENV{US} // "\t";  # =IFS/OFS delimiter

my %opts=();
GetOptions(\%opts,
    'help|h' => \&help,  # call function
    'quiet|q:+',    # count repeated options with optional override argument
    'hexval|x=o',   # allow hex,oct,bin number
    'ftable|f=s',   # simple string save
    'htable|t=t%',  # accumulate key=val to hash [ -t nm1=val1 ... -t nm2=val2 ]
    'tree-acc|a=s%' => sub { push(@{$mmap{$_[1]}}, $_[2]) },  # accumulate values into same key of hash
    'delimiter|d=s' => \$US  # save into var
) or die &help;

sub help { open(my $fh, '<:encoding(UTF-8)', $0);
    while (<$fh>) { print $2,"\n" if /^(.*\s)?#%(.*)/ }
    close($fh); exit
}

## Merge keys from two hashmaps and override
my %table = ($opts{ftable} ? read_file($opts{ftable}) : ());
%table = (%table, %{$opts{htable}}) if $opts{htable};
die "Err: use '-f' or '-t' to specify list of key-values" if not %table;
