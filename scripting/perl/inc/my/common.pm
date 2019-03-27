# NOTE: use general namespace for all dynamic vars
# ALT: don't use "package" at all and simply "source" everything in file
# REF: https://perldoc.perl.org/perlmod.html#Packages
package mypkg;

use warnings FATAL => 'all';
use autodie;  # qw(:all)
use strict;
use feature ();

## WARN: only if you don't have your own "sub import"
# @ISA = qw(Exporter);
# @EXPORT_OK = qw ($b);
# use Exporter qw( import );

# REF: https://metacpan.org/release/Modern-Perl/source/lib/Modern/Perl.pm
# https://stackoverflow.com/questions/3460456/do-perl-subclasses-inherit-imported-modules-and-pragmas
# ALT: https://perldoc.perl.org/Exporter.html#Good-Practices
# E.G.(custom import): /usr/share/perl5/core_perl/subs.pm
# ALSO: find and import all subroutines in module
#   https://stackoverflow.com/questions/607282/whats-the-best-way-to-discover-all-subroutines-a-perl-module-has
#   https://stackoverflow.com/questions/732133/how-can-i-export-all-subs-in-a-perl-package
sub import
{
    my $caller = caller;
    my $pakage = shift;
    my ($feature_tag) = @_;

    warnings->import;
    strict->import;
    # NOTE: instead of "use 5.014" for s///r
    $feature_tag = ':5.14' if not defined $feature_tag;
    feature->import( $feature_tag );
    # mypkg->export_to_level(1);
    # mypkg->export_to_level(1, @_);
    # OR: use Exporter (); goto \&Exporter::import;

    @_ = qw(argparse parse $opts) if not @_;
    {
        no strict 'refs';
        *{"${caller}::$_"} = \*{"${caller}::$_"} for @_;  # OR: = \&{ $func }
    }
}

sub unimport
{
    warnings->unimport;
    strict->unimport;
    feature->unimport;
}

1;
