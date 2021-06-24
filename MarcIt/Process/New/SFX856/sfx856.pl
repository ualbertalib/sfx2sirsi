#!/u/sirsi/Unicorn/Bin/perl

system("cat ckeyMatchAll | catalogdump -oF >dump 2>dump.log");
system("echo END >>dump");

open(DMP,"dump");
open(ADD,">add856");
open(REP,">replace856");
open(GOOD,">noAction856");
open(TMP,">tmp");
open(EQ,">equalsSFX");
open(NE,">notEqSFX");
open(NORES,">noResolver");
open(NOITM,">noUAINTitem");
$firstLine = "y";
$foundGood856 = "n";
$foundUpdate856 = "n";
$foundUA856 = "n";
$foundUA090 = "n";
while($line=<DMP>)
  {
  chomp($line);
  if ($firstLine eq "y")
    {
    print ADD "*** DOCUMENT BOUNDARY ***\n";
    print ADD "FORM=MARC\n";
    print REP "** DOCUMENT BOUNDARY ***\n";
    print REP "FORM=MARC\n";
    $firstLine = "n";
    }
  elsif ($line =~ /DOCUMENT BOUNDARY/)
    {
    close(TMP);
    open(TMP,"tmp");
    if ($foundUpdate856 eq "y")
      {
      print REP ".090.   |aInternet Access|bAEU\n" if $foundUA090 eq "n";
      while ($line=<TMP>)
        {
        print REP "$line";
        }
      print REP ".856. 40|3University of Alberta Access|u$sfx856\n";
      print REP ".1003. |a$ckey\n";
      print REP "*** DOCUMENT BOUNDARY ***\n";
      print REP "FORM=MARC\n";
      }
    elsif ($foundUA856 eq "n")
      {
      print ADD ".090.   |aInternet Access|bAEU\n" if $foundUA090 eq "n";
      print ADD ".856. 40|3University of Alberta Access|u$sfx856\n";
      print ADD ".1003. |a$ckey\n";
      print ADD "*** DOCUMENT BOUNDARY ***\n";
      print ADD "FORM=MARC\n";
      } 
    else
      {
      print GOOD "$ckey|$ual856\n";
      } 
    $foundGood856 = "n";
    $foundUpdate856 = "n";
    $foundUA856 = "n";
    $foundUA090 = "n";
    close(TMP);
    open(TMP,">tmp");
    }
  elsif ($line =~ /^END/)
    {
    close(TMP);
    open(TMP,"tmp");
    if ($foundUpdate856 eq "y")
      {
      print REP ".090.   |aInternet Access|bAEU\n" if $foundUA090 eq "n";
      while ($line=<TMP>)
        {
        print REP "$line";
        }
      print REP ".856. 40|3University of Alberta Access|u$sfx856\n";
      print REP ".1003. |a$ckey\n";
      }
    elsif ($foundUA856 eq "n")
      {
      print ADD ".090.   |aInternet Access|bAEU\n" if $foundUA090 eq "n";
      print ADD ".856. 40|3University of Alberta Access|u$sfx856\n";
      print ADD ".1003. |a$ckey\n";
      }
    else
      {
      print GOOD "$ckey|$ual856\n";
      }
    close(TMP);
    }
  elsif ($line =~ /^\.001\./)
    {
    $line =~ s/.001. \|a//;
    $ckey = $line;
    $sfxStuff = `grep $ckey recMatchAll`;
    chomp($sfxStuff);
    (@fields) = split/\^/,$sfxStuff;
    $sfx856 = $fields[5];
    }
  elsif ($line =~ /^\.090\./)
    {
    if ($line =~ /Internet Access/ &&
        $line =~ /AEU/)
      {
      $foundUA090 = "y";
      }
    }
  elsif ($line =~ /^\.245\./)
    {
    ($t,$t245a,$other) = split/\|/,$line;
    $t245a =~ s/^a//;
    }
  elsif ($line =~ /^\.856\./)
    {
    if ($line =~ /University of Alberta Access/)
      {
      $foundUA856 = "y";
      $hasUAINTitem = `grep $ckey ckeyHasUAINTu`;
      chomp($hasUAINTitem);
      if ($line =~ /resolver.library.ualberta.ca/ &&
         $hasUAINTitem eq $ckey)
        {
        $ual856 = $line;
        $foundGood856 = "y";
        ($t,$s3,$u) = split/\|/,$line;
        $u =~ s/^u//;
        if ($u eq $sfx856)
          {
          print EQ "$u\n";
          }
        else
          {
          print NE "$u\n";
          }
        }
      elsif ($line =~ /resolver.library.ualberta.ca/ &&
         $hasUAINTitem ne $ckey)
        {
        $foundGood856 = "y";
        print NOITM "$ckey|$line\n";
        ($t,$s3,$u) = split/\|/,$line;
        $u =~ s/^u//;
        if ($u eq $sfx856)
          {
          print EQ "$u\n";
          }
        else
          {
          print NE "$u\n";
          }
        }
      elsif ($line !~ /resolver.library.ualberta.ca/ &&
         $hasUAINTitem eq $ckey)
        {
        $foundUpdate856 = "n";
        # Do not replcse non-resolver, just add SFX link
        print NORES "$ckey|$t940|$t245a|\n";
        }
      else
        {
        $foundUpdate856 = "n";
        }
      }
    else
      {
      print TMP "$line\n";
      }
    }
  elsif ($line =~ /^\.940\./)
    {
    $t940 = $line;
    $t940 =~ s/.940.   \|a//;
    }
  }
close(REP);
close(ADD);
close(GOOD);
close(TMP);
