#!/usr/bin/perl
use warnings;
use strict;

my $sum;
while (<>) {
    my ($h, $m, $s) = split /:/, (split)[1];
    $sum += $s
            + 60 * $m
            + 3600 * $h;
}

print 'Hours: ', int($sum / 3600);
$sum %= 3600;

print ', minutes: ', int($sum / 60);
$sum %= 60;

print ', seconds: ', $sum, "\n";

=head1 work-sum.pl

Sums the time in the output of work-today.sh or work-date.

=cut

