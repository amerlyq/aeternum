# NOTE: use general namespace for all dynamic vars
# ALT: don't use "package" at all and simply "source" everything in file
# REF: https://perldoc.perl.org/perlmod.html#Packages
package mypkg::common;

our @EXPORT = qw(argfull
    help opts OFS ORS
);

# SEE: recommended modules
#   https://perldoc.perl.org/perlmodlib.html#Pragmatic-Modules
use warnings FATAL => 'all';
use autodie;  # qw(:all) -- RQ:(cpan): IPC::System::Simple
use strict;
use feature ();

# NOTE: conditional inclusion
# use if $] < 5.008, "utf8";

# REF: https://perldoc.perl.org/open.html
# use open IN  => ":crlf", OUT => ":bytes";

use Symbol;

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
sub import {
    # NOTE:(here): $0 == $fname
    my ($package, $caller, $fname, $lnum) = (shift, caller);
    my $feature_tag = shift // ':5.14';  # NOTE: instead of "use 5.014" for s///r
    my @symbols = @_ ? @_ : @EXPORT;

    warnings->import;
    strict->import;
    feature->import( $feature_tag );
    # mypkg->export_to_level(1);
    # mypkg->export_to_level(1, @_);
    # OR: use Exporter (); goto \&Exporter::import;

    # REF: https://perldoc.perl.org/Symbol.html
    # for (@symbols) { *{qualify_to_ref($_, $caller)} = \*{qualify_to_ref($_, $package)}; }
    # ALT:BAD?
    { no strict 'refs'; *{"${caller}::$_"} = \*{"${caller}::$_"} for @_; }  # OR: = \&{ $func }
}

sub unimport
{
    warnings->unimport;
    strict->unimport;
    feature->unimport;
}

1;
