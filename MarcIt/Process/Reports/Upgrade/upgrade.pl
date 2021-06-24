#!/u/sirsi/Unicorn/Bin/perl

open(RECS,"recMatchAll");
open(CM,">ckeyMatch");
open(RPT, ">upgradeReport");
open(NO, ">noUpgradeReport");
print NO "          LDR17-Sirsi                         LDR17-MarcIt\n";
open(CUPG,">ckeys2Upgrade");

while($line=<RECS>)
  {
  chomp($line);
  @fields = split/\^/,$line;
  print CM "$fields[0]|$fields[1]|$fields[4]|\n";
  }
close(CM);

@ckey000 = `cat ckeyMatch |selcatalog -iC -e000,035,042,940 -oeCSF 2>/dev/null`;
foreach $ckey000 (@ckey000)
  {
  chomp($ckey000);
  ($t000,$t035,$t042,$t940sym,$ckey,$objIDit,$ldr17it,$tck) = split/\|/,$ckey000;
  $ldr17sym = substr($t000,2,1);
  $tck =~ s/ //g;
  #$ldr17sym - space
  #$ldr17it - space
  if ($ldr17it eq " " && $ldr17sym ne " ")
    {
    print RPT "$tck|$ckey|$ldr17sym|$t035|$t042|$t940sym||$objIDit|$ldr17it|\n";
    print CUPG "$ckey\n";
    }
  elsif ($ldr17it eq "7" && $ldr17sym eq "z")
    {
    print RPT "$tck|$ckey|$ldr17sym|$t035|$t042|$t940sym||$objIDit|$ldr17it|\n";
    print CUPG "$ckey\n";
    }
  else
    {
    print NO "$tck|$ckey|$ldr17sym|$t035|$t042|$t940sym||$objIDit|$ldr17it|\n";
    }
  }
 
