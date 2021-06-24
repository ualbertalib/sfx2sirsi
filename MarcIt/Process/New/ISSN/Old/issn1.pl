#!/u/sirsi/Unicorn/Bin/perl

open(NM940,"noMatch940");
open(LST022,">t022");
open(NOIT,">noISSNit");
open(NO,">noMatch022");
open(FIND_REC, ">noFindrec");
while($line=<NM940>)
  {
  chomp($line);
  ($objectID,$t022,$t035) = split/\^/,$line;
  if ($t022 eq "")
    {
    print NOIT "$line\n";
    print NO "$line\n";
    }
  else
    {
    print LST022 "$t022\{022\}|\n";
    }
  }

close(LST022);

system("cat t022 |seltext -oCS 2>ckeys022.log >ckeys022");

### Mult ###
@mult = `grep -v "0 records" ckeys022.log | grep -v "1 records" |grep records`;
open(PMULT, ">possibleMult022");
foreach $line2 (@mult)
  {
  chomp($line2);
  $line2 =~ s/  .* records found for #.*: //;
  $line2 =~ s/.T022.//;
  $line2 =~ s/ //g;
  @lines2 = `grep "$line2" ckeys022 2>/dev/null`;
  foreach $rec (@lines2)
    {
    chomp($rec);
    $rec =~ s/\{022\}//; 
    print PMULT "$rec\n";
    }
  }
close(PMULT);

open(MULTSING,">multOrSingle");
open(MULT,">multmatches022");
@ckeyISSNs = `cat possibleMult022 | selcatalog -iC -e022 -oCSe 2>/dev/null`;
foreach $ckeyISSNs (@ckeyISSNs)
  {
  chomp($ckeyISSNs);
  ($ckey,$issnIt,$issnSym) = split/\|/,$ckeyISSNs;
  if ($issnSym ne "")
    {
    ($issna,$subs) = split/ /,$issnSym;
    if ($issna eq $issnIt)
      {
      print MULTSING "$issna|$ckey|\n";
      }
    else
      {
      print FIND_REC "$issnIt\n";
      }
    }
  else
    {
    print FIND_REC "$issnIt\n";
    }
  }
close(MULTSING);

open(SING,">ckeys022Single");

open(MULTSING,"multOrSingle");
system("echo \"9|9|\" >>multOrSingle");
open(NMULT,">noLongerMult");
open(MULT,">multmatches022");
$linePrev = "a";
$issnPrev = "0";
$cnt = 0;
$firstLine = "y";
while ($line=<MULTSING>)
  {
  chomp($line);
  ($issn,$ckey) = split/\|/,$line;
  $cnt++;
  if ($firstLine eq "y")
    {
    $firstLine = "n";
    }
  elsif ($issn eq $issnPrev)
    {
    print MULT "$linePrev\n";
    print MULT "$line\n";
    $cnt = 0;
    }
  elsif ($issn ne $issnPrev)
    {
    print SING "$ckeyPrev|$issnPrev|\n" if $cnt > 1;;
    }
  else
    {
    ;
    }
  $linePrev = $line;
  $issnPrev = $issn;
  $ckeyPrev = $ckey;
  }

system("sort -u multmatches022 >multmatches022u");
open(MM,"multmatches022u");
while($line=<MM>)
  {
  chomp($line);
  ($issn,$c) = split/\|/,$line;
  print FIND_REC "$issn\n";
  } 
close(MM);

### Single ###
@recs1 = `grep "1 records" ckeys022.log`;
#open(SING,">ckeys022Single");
foreach $line2 (@recs1)
  {
  chomp($line2);
  $line2 =~ s/  1 records found for #.*: //;
  $line2 =~ s/.T022.//;
  $line2 =~ s/ //g;
  @lines2 = `grep $line2 ckeys022 2>/dev/null`;
  foreach $rec (@lines2)
    {
    chomp($rec);
    $rec =~ s/\{022\}//;
    print SING "$rec\n";
    }
  }
  
@ckeys = `cat ckeys022Single |selcatalog -iC -e022,337,940,008 -oCSe 2>ckeys022-022.log`;

open(MATCH,">match022a");
open(CMATCH,">ckeyMatch022a");
open(NOT_E,">notElectronic");
open(DIFFID,">diffObjID");
open(NO940,">noObjID");
open(M_ISSN,">matchedISSN");
foreach $ckey022 (@ckeys)
  {
  chomp($ckey022);
  ($ckey,$issn,$symISSN,$t337,$t940,$t008) = split/\|/,$ckey022;
  ($issna,$issnx) = split/ /,$symISSN;
  $pos23 = substr($t008,23,1); # Mod_Rec
  if ($issn eq $issna)
    {
    if ($pos23 eq "o" || $t337 =~ /computer/)
      {
      $t940 = "";
      if ($t940 =~ /[0-9][0-9][0-9]/) #identifies an ObjID
        {
        print DIFFID "$ckey|$issn|\n";
        print FIND_REC "$issn\n";
        }
      else
        {
        print MATCH "$ckey|$issn|\n";
        print CMATCH "$ckey\n";
        print NO940 "$ckey|$issn|\n";
        print M_ISSN "$issn\n";
        }
      }
    else
      {
      print NOT_E "$ckey|$issn|$t337|$pos23|\n";
      print FIND_REC "$issn\n";
      }
    }
  else
    {
    print FIND_REC "$issn\n";
    }
  }


### No Match In Symphony ###
@recs0 = `grep "0 records" ckeys022.log`;

foreach $line2 (@recs0)
  {
  chomp($line2);
  #0 records found for #575: 1354-2699.T022.
  $line2 =~ s/  0 records found for #.*: //;
  $line2 =~ s/.T022.//;
  $line2 =~ s/ //g;
  print FIND_REC "$issn\n";
  }
close(FIND_REC);
close(NO);
system("sort -u noFindrec >noFindrecU");
system("egrep -fnoFindrecU noMatch940 >> noMatch022");
system("sort -u noMatch022 >noMatch022u");
system("egrep -fmatchedISSN -v noMatch022u >noMatch022a");
