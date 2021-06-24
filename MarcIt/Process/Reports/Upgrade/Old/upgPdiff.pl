#!/u/sirsi/Unicorn/Bin/perl

open(UPG, ">ckeysUpgraded");
@ckey008 = `cat matchAll |selcatalog -iC -e008 -oCe 2>/dev/null`;
foreach $ckey008 (@ckey008)
  {
  chomp($ckey008);
  $ckey008 =~ s/\|/^/;
  ($ckey,$t008) = split/\^/,$ckey008;
  
  #($one,$two,$three,$ldr17,$startDate,$endDate) = split/\^/,$S;
  $ldr17sym = substr($t008,17,1);
print "$ckey|$ldr17sym|\n";
  if ($ldr17 eq "" && $ldr17sym ne "")
    {
    print UPG "$ckey\n";
    }
  elsif ($ldr17 eq "7" && $ldr17sym eq "z")
    {
    print UPG "$ckey\n";
    }
  else
    {
    ;
    }
  }
exit;
open(PDIFF, ">ckeysPubDiff");
foreach $ckey008 (@ckey008)
  {
  chomp($ckey008);
  ($ckey,$t008,$S) = split/\|/,$ckey008;
  ($one,$two,$three,$ldr17,$startDate,$endDate) = split/\^/,$S;
  $date1 = substr($t008,7,4);
  $date2 = substr($t008,11,4);
  $date1 =~ s/u/0/g;
  $date2 =~ s/u/9/g;
  $startDate =~ s/u/0/g;
  $endDate =~ s/u/9/g;

  #if ($endDate eq 9999)
  #  {
  #  $endDate = `date '+%Y'`;
  #  chomp($endDate);
  #  }
  
  if ($startDate < $date1 || $endDate > $date2)
    {
    print PDIFF "$ckey|$startDate|$date1|$endDate|$date2\n";
    }
  }
  
