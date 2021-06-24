#!/u/sirsi/Unicorn/Bin/perl

require("addCopy.pl");

open(ADDCOPY,">addCopy.trans");
@ckeyBarLib = `cat ckeyMatchAll |selitem -iC -oCBy 2>/dev/null`;
push(@ckeyBarLib,"999");

$ckeyPrev = "0";
$grp = "";
$firstLine = "y";
open(HASITM,">ckeyHasUAINT");
open(NOITM,">ckeyNoUAINT");
foreach $ckeyBarLib (@ckeyBarLib)
  {
  chomp($ckeyBarLib);
  ($ckey,$bar,$lib) = split/\|/,$ckeyBarLib;
  $bar =~ s/ //g;
  if ($ckey eq $ckeyPrev || $firstLine eq "y")
    {
    push (@grp,$ckeyBarLib);
    $firstLine = "n";
    $ckeyPrev = $ckey;
    }
  else
    {
    $ckeyPrev = $ckey;
    $foundUAINT = "n";
    foreach $item (@grp)
      {
      chomp($item);
      next if $item eq "";
      ($ckey,$bar,$lib) = split/\|/,$item;
      $bar =~ s/ //g;
      if ($lib eq "UAINTERNET")
        {
        $foundUAINT = "y";
        push (@ckeyBar,"$ckey");
        }
      else
        {
        #print "$ckey,$bar,$lib,$foundUAINT\n";
        }
      }
    @grp = "";
    push (@grp,$ckeyBarLib);
    if ($foundUAINT eq "n")
      {
      print NOITM "$ckey\n";
      &addCopy($bar);
      }
    else
      {
      print HASITM "$ckey\n"
      }
    }
  }

