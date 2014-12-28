#!/usr/bin/perl
use warnings;
use strict;

open my $IN, '-|', 'worktime', '-w' or die $!;
while (<$IN>) {
    my @F = split;
    $F[3] =~ s/\..*//;
    print "@F\n";
}
