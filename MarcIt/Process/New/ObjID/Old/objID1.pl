#!/u/sirsi/Unicorn/Bin/perl

@ckeysID = `cat objID940 | seltext -oCS 2>ckeysID.log`;

open(MATCH,">match940");
open(CMATCH,">ckeyMatch940");
open(C856,">ckey856SFX940");
open(NO,">noMatch940");

foreach $ckeysID (@ckeysID)
  {
  chomp($ckeysID);
  ($ckey,$objID) = split/\|/,$ckeysID;
  $objID =~ s/\{940\}//;
  print MATCH "$ckey|$objID\n";
  print CMATCH "$ckey\n";
  @lines = `grep $objID records`; 
  foreach $line1 (@lines)
    {
    chomp($line1);
    ($stuff,$sfx856) = split/\|/,$line1;
    $sfx856 =~ s/\^//;
    print C856 "$ckey|$sfx856|\n";
    }
  }

close(MATCH);

@recs0 = `grep "0 records" ckeysID.log`;

foreach $line2 (@recs0)
  {
  chomp($line2);
  $line2 =~ s/0 records found for #.*: "//;
  $line2 =~ s/".NM02.//;
  $line2 =~ s/ //g;
  @lines2 = `grep $line2 records 2>/dev/null`;
  foreach $rec (@lines2)
    {
    chomp($rec);
    print NO "$rec\n";
    }
  }
close(NO);
