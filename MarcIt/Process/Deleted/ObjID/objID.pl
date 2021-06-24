#!/u/sirsi/Unicorn/Bin/perl

@ckeysID = `cat objID940 | seltext -oCS 2>ckeysID.log`;

open(MATCH,">match940");
open(MULT,">multiObjID");
open(CMATCH,">ckeyMatch940");
push(@ckeysID, "9|9|");
$firstLine = "y";
$cnt = 0;
foreach $ckeysID (@ckeysID)
  {
  chomp($ckeysID);
  $ckeysID =~ s/\{940\}//;
  ($ckey,$objID) = split/\|/,$ckeysID;
  $cnt++;
  if ($firstLine eq "y")
    {
    $firstLine = "n";
    }
  elsif ($objID eq $objIDprev)
    {
    print MULT "$ckeysIDprev|\n" if $cnt != 1;
    print MULT "$ckeysID|\n";
    $cnt = 0;
    print FIND_REC "$objID\n";
    }
  else
    {
    if ($cnt > 1)
      {
      print MATCH "$ckeyPrev|$objIDprev|\n";
      print CMATCH "$ckeyPrev\n";
      }
    }
  $ckeysIDprev = $ckeysID;
  $objIDprev = $objID;
  $ckeyPrev = $ckey;
  }

close(MATCH);

open(NOMATCH,">noMatch");
@recs0 = `grep "0 records" ckeysID.log`;

foreach $line2 (@recs0)
  {
  chomp($line2);
  $line2 =~ s/0 records found for #.*: "//;
  $line2 =~ s/".NM02.//;
  $line2 =~ s/ //g;
  print NOMATCH "$line2\n";
  }

#0 records found for #19: "110975506072061".NM02.

