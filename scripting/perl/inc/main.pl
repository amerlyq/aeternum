#!/usr/bin/perl
## REF: https://stackoverflow.com/questions/841785/how-do-i-include-a-perl-module-thats-in-a-different-directory
# use FindBin;                 # locate this script
# use lib "$FindBin::Bin/..";  # use the parent directory
# BET: install into /usr/share/perl5/vendor_perl/
#   <= https://wiki.archlinux.org/index.php/Perl_package_guidelines
use lib '.';

# REF:CMP:(use vs require): https://perlmaven.com/use-require-import
# require my::common;

# READ:REF:(Including files): https://www.perlmonks.org/?node_id=393426
use mypkg::common;

say "hi";
