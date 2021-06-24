#!/u/sirsi/Unicorn/Bin/perl

open(KEYS,"dump");
open(MERGE,">merge090-856");
$firstLine = "y";

while($line=<KEYS>)
  {
  chomp($line);
  if ($firstLine eq "y")
    {
    print MERGE "*** DOCUMENT BOUNDARY ***\n";
    print MERGE "FORM=MARC\n";
    $firstLine = "n";
    }
  elsif ($line =~ /DOCUMENT BOUNDARY/)
    {
    print MERGE ".1003. |a$catkey\n";
    print MERGE "*** DOCUMENT BOUNDARY ***\n";
    print MERGE "FORM=MARC\n";
    $foundUA090 = "n";
    $foundUA856 = "n";
    }
  elsif ($line =~ /^\.001\./)
    {
    $tag = $line;
    $tag =~ s/.001. \|a//;
    $catkey = $tag;
    }
  elsif ($line =~ /^\.090\./)
    {
    if ($line =~ /Internet Access|bAEU/)
      {
      $found090UA = "y";
      }
    print MERGE "$line\n";
    }
  elsif ($line =~ /^\.856\./)
    {
    if ($found090 eq "n")
      {
      print MERGE ".090.   |aInternet Access|bAEU\n";
      print ".090.   |aInternet Access|bAEU\n";
      }

    if ($line =~ /University of Alberta Access/)
      {
      $foundUA856 = "y";
      }
    print MERGE "$line\n";
    }
  }

print MERGE ".1003. |a$catkey\n";
close(MERGE);

#cat addRest | catalogmerge -aMARC -bc -if -t090,856 -d -r >merge.keys 2>merge.log &
#grep -v **Entry merge.log |translate >mergeTrans.log &
#cat merge.keys | touchkeys 2>touchkeys.log &
