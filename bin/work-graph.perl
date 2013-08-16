#!/usr/bin/perl
use strict;
use warnings;

if(@ARGV == 0 and not (-p *STDIN or -f *STDIN)) {
    @ARGV = ("$ENV{HOME}/.worktime");
}

sub round_date {
  my ($h, $m) = @_;
  if ($m >= 30) {
      $h++;
      $h = 0 if $h > 23;
  }
  return $h;
}

my %hours;
my %projects;
while (<>) {
    chomp;
    next if /^;/;
    my ($inout, $date, $time, $project) = split / +/;
    if ('i' eq $inout) {
        $projects{$project} = {date => $date, time => $time};
    } elsif ('o' eq $inout) {
        die "Project not active\n" unless exists $projects{$project};

        $projects{$project}{time} =~ /^([0-9]{2}):([0-9]{2})/
            or die "Invalid start time\n";
        my $shour = round_date($1, $2);

        $time =~ /^([0-9]{2}):([0-9]{2})/
            or die "Invalid end time\n";
        my $ehour = round_date($1, $2);
        my @h;
        if ($shour > $ehour){
            @h = ($shour .. 23, 0 .. $ehour);
        } else {
            @h = $shour .. $ehour;
        }
        for my $h (@h) {
            $hours{$project}{$h}++;
        }
    } else {
        die "Invalid In/Out mark\n";
    }
}
for my $project (keys %hours) {
    for my $hour (0 .. 23) {
        print "$project\t$hour\t@{[$hours{$project}{$hour} || 0]}\n";
    }
}

=head1 Work Graph

Outputs data in a format that can be used by gnuplot to draw a "punchcard".

  plot '< work-simplify.sh | work-graph.perl | grep PROJECT' u 2:3 with boxes

=cut
