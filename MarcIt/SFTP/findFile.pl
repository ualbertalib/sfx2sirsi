#!/u/sirsi/Unicorn/Bin/perl

#if ($#ARGV != 0) {die "$0 requires 1 argument.\n";}

#$a = $ARGV[0];

chomp($lastRan = `cat lastRan_d`);
open(LIST,"fileList");
open(GET,">getFile");
while($line=<LIST>)
  {
  chomp($line);
  next if $line !~ /^ec_/;
  $date = substr($line,3,8);
  $mon = substr($date,0,2);
  $day = substr($date,2,2);
  $yr = substr($date,4,4);
  $formatted = "$yr$mon$day";
  print GET "$line\n" if $formatted > $lastRan;
  }
close(LIST);
close(GET);
