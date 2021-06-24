#!/u/sirsi/Unicorn/Bin/perl

@ckeyBarLib = `cat matchAll |selitem -iC -oCBy 2>/dev/null`;
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
    $size = @grp;
    foreach $item (@grp)
      {
      chomp($item);
      next if $item eq "";
      ($ckey,$bar,$lib) = split/\|/,$item;
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
      }
    else
      {
      print HASITM "$ckey\n"
      }
    }
  }

system("cat ckeyMatchAll | catalogdump -oF >dump 2>dump.log");
open("DMP","dump");
open(TAGS,">tags");
$firstLine = "y";
while($line=<DMP>)
  {
  chomp($line);
  if ($line =~ /^\.001/ && $firstLine eq "y")
    {
    print TAGS "$line|";
    $firstLine = "n";
    }
  elsif ($line =~ /^\.001/)
    {
    print TAGS "\n$line|";
    }
  elsif ($line =~ /^\.090/ || $line =~ /^\.856/)
    {
    print TAGS "$line|";
    }
  }
close(Tags);

open(TAGS,"tags");
while($line=<TAGS>)
  {
  chomp($line);
  ($t001,$ckey,$t090,$t090a,$t090b,$t856,$t856_3,$t856u) = split/\|/,$line;
  $ckey =~ s/a//;
#print "$ckey\n";
  $sfxStuff = `grep $ckey ckey856SFX940`;
  chomp($sfxStuff);
  ($one,$sfx856) = split/\|/,$sfxStuff;
  if ($t856u eq $sfx856)
    {
    print "yes\n";
    }
  else
    {
    #print "no\n";
    }
  #print "$ckey|$t856_3|$t856u\n";

  }

exit; 
open(NO856,">ckeyNo856");
foreach $ckeyBar (@ckeyBar)
  {
  chomp($ckeyBar);
  $foundUA856 = "n";
  foreach $line (@ckey856)
    {
    chomp($line);
    next if $line eq "";
    ($ckey856,$stuff) = split/\|/,$line;
    if ($ckey856 eq $ckeyBar)
      {
      if ($line =~ /University of Alberta Access/)
       {
        $foundUA856 = "y";
        last;
        }
      }
    }

  if ($foundUA856 eq "n")
    {
    print NO856 "$ckey\n";
    }
  }


