
# NOTE: all plain text files are prefixed with "f"
my $flatspace = shift @ARGV;

# NOTE: all dirpaths are prefixed with "d"
my $drootfs = shift @ARGV;

my $offset = do { local $_ = (shift @ARGV // 0); /^0/ ? oct : int };

my $ptr_sz = shift @ARGV // 4;
