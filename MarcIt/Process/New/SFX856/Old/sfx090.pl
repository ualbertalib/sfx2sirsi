#!/u/sirsi/Unicorn/Bin/perl

#system("cat ckeyMatchAll | catalogdump -oF >dump 2>dump.log");

open(DMP,"dump");
open(ADD,">add090");
$firstLine = "y";
$foundUA090 = "n";
while($line=<DMP>)
  {
  chomp($line);
  if ($firstLine eq "y")
    {
    print ADD "*** DOCUMENT BOUNDARY ***\n";
    print ADD "FORM=MARC\n";
    $firstLine = "n";
    }
  elsif ($line =~ /DOCUMENT BOUNDARY/)
    {
    if ($foundUA090 eq "n")
      {
      print ADD ".090.   |aInternet Access|bAEU\n";
      print ADD ".1003. |a$ckey\n";
      print ADD "*** DOCUMENT BOUNDARY ***\n";
      print ADD "FORM=MARC\n";
      }
    $foundUA090 = "n";
    }
  elsif ($line =~ /END/)
    {
    if ($foundUA090 eq "n")
      {
      print ADD ".090.   |aInternet Access|bAEU\n";
      print ADD ".1003. |a$ckey\n";
      }
    }
  elsif ($line =~ /^\.001\./)
    {
    $line =~ s/.001. \|a//;
    $ckey = $line;
    $sfxStuff = `grep $ckey matchAll`;
    chomp($sfxStuff);
    ($one,$sfx856) = split/\|/,$sfxStuff;
    }
  elsif ($line =~ /^\.090\./)
    {
    if ($line =~ /Internet Access\|bAEU/)
      {
      $foundUA090 = "y";
      }
    else
      {
      #print ADD "$line\n";
      }
    }
  }

close(ADD);

