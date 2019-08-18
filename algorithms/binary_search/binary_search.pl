# SEE:REF: generic ALG with record read function and linear block processing
#   https://metacpan.org/pod/release/RANT/Search-Binary-0.95/Binary.pm
# ALT:(linear-oneline): $ perl -wslane 'if(hex($F[0])<=hex($va)&&hex($va)<hex($F[0])+hex($F[1])){print;exit}' -- -va="$1" "$vmmap"

sub binsearch_generic {
    my ($low, $high, $cmpfn, $mid) = @_;
    die if $low > $high;
    return $mid if ($cmpfn->($low) > 0);  # HACK: use arg4 instead of undef

    while ($low < $high) {
        $mid = $low + int(($high - $low) / 2) + 1;  # prevent int overflow for $mid > INT_MAX/2
        # DEBUG: printf "%d < %d < %d\n", $low, $mid, $high;
        if ($cmpfn->($mid) > 0) {
            $high = $mid - 1;
        } else {
            $low = $mid;
        }
    }
    return ($cmpfn->($mid) == 0) ? $mid : $low;
}

# DEBUG: printf "%d <=> %d (%d)\n\n", $tableref->[$_[0]]->[0], $value, $tableref->[$_[0]]->[0] <=> $value;
sub binsearch_table { my ($tableref, $value) = (shift, shift);
    return binsearch_generic(0, scalar(@$tableref) - 1,
        sub { $tableref->[$_[0]]->[0] <=> $value }, @_);
}
