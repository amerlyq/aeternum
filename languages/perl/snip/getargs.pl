
# NOTE: all plain text files are prefixed with "f"
my $flatspace = shift @ARGV;

# NOTE: all dirpaths are prefixed with "d"
my $drootfs = shift @ARGV;

## ALSO:
# die("Not a file: $_") for grep {!-f} @files;

my $offset = do { local $_ = (shift @ARGV // 0); /^0/ ? oct : int };

my $ptr_sz = shift @ARGV // 4;

## ALT:(a // b)
# $foo = $bar if defined $bar;  ->  $foo = $bar // $foo;
# $foo = $bar unless defined $foo;  ->  $foo //= $bar
# sub setifdef { $_[0] = $_[1] if defined($_[1]) }
# setifdef $foo, $bar;

## IDEA:
# {local $_ = $bar; $foo = $_ if defined $_;}
# @list = @{$_} for grep defined, $listref_or_undef
