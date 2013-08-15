#!/usr/bin/perl
use strict;
use warnings;

if(@ARGV == 0
   and not( -p *STDIN or -f *STDIN)){
  @ARGV = ("$ENV{HOME}/.worktime");
}

sub round_date{
  my($h,$m) = @_;
  if($m >= 30){
    $h++;
    $h = 0 if $h > 23;
  }
  return $h;
} # round_date

my %hours;
my %projects;
while(<>){
  chomp;
  next if /^;/;
  my ($inout,$date,$time,$project) = split / +/;
  if($inout eq 'i'){
    $projects{$project} = {date => $date,time => $time};
  }elsif($inout eq 'o'){
    die "Project not active\n" unless exists $projects{$project};

    $projects{$project}{time} =~ /^([0-9]{2}):([0-9]{2})/
      or die "Invalid start time\n";
    my $shour = round_date($1,$2);

    $time =~ /^([0-9]{2}):([0-9]{2})/
      or die "Invalid end time\n";
    my $ehour = round_date($1,$2);
    my @h;
    if($shour>$ehour){
      @h = ($shour..23,0..$ehour);
    }else{
      @h = $shour..$ehour;
    }
    foreach my $h(@h){
      $hours{$project}{$h}++;
    }
  }else{
    die "Invalid In/Out mark\n";
  }
}
foreach my $project (keys %hours){
  foreach my $hour(0..23){
    print "$project\t$hour\t@{[$hours{$project}{$hour} || 0]}\n"
  }
}
