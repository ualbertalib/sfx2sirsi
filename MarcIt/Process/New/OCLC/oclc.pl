#!/u/sirsi/Unicorn/Bin/perl

open(NM022,"noMatch022a");
open(OBJ035,">objID035It");
open(LST035,">t035");
open(NOIt,">noOCLCit");
open(NO,">noMatch035");
open(FIND_REC, ">noFindrec");
while($line=<NM022>)
  {
  chomp($line);
  ($objectID,$t022,$t035all,$ldr17,$t856,$t245aIt) = split/\^/,$line;
  if ($t035all eq "")
    {
    print NOIt "$line\n";
    print NO "$line\n";
    }
  else
    {
    (@t035) = split/ /,$t035all;
    foreach $t035 (@t035)
      {
      next if $t035 eq "";
      print LST035 "$t035\{035\}|\n";
      print OBJ035 "$objectID|$t035|$t245aIt\n";
      }
    }
  }

close(LST035);

system("cat t035 |seltext -oCS 2>ckeys035.log >ckeys035");
system("sed 's/\{035\}//' ckeys035 >ckeys035.cleaned");
open(C035,"ckeys035.cleaned");
system("cat ckeys035.cleaned | selcatalog -iC -e008,035,337,940,245 -oCSe 2>/dev/null >CSe");
open(CSE,"CSe");
open(C23,">ckeyOCLCpos23");
while($line=<CSE>)
  {
  chomp($line);
  $line =~ s/\|/^/;
  $line =~ s/\|/^/;
  $line =~ s/\|/^/;
  ($ckey,$oclc,$t008,$theRest) = split/\^/,$line;
  $pos23 = substr($t008,23,1); #Repr
  print C23 "$ckey|$oclc|$pos23|$theRest\n";
  }
close(C23);
open(C23,"ckeyOCLCpos23");

open(MALL, ">allMatches");
#open(MATCH,">match035a");
open(CMATCH,">ckeyMatch035a");
open(NOT_E,">notElectronic");
open(DIFFID,">diffObjID");
open(M_OCLC,">matchedOCLC");

while ($line=<C23>)
  {
  chomp($line);
  ($ckey,$oclcIt,$pos23,$oclcSym,$t337,$t940,$t245Sym) = split/\|/,$line;
  $oclcSym =~ s/\(OCoLC\)//;
  $oclcSym =~ s/[a-z]//g;
  #($oclca,$oclcx) = split/ /,$oclcSym;
  if ($oclcIt eq $oclcSym)
    {
    if ($pos23 eq "o" || $t337 =~ /computer/)
      {
      #$t940 = "";
      if ($t940 =~ /[0-9][0-9][0-9]/) #identifies an ObjID
        {
        $tagsIt = `grep $oclcIt objID035It`;
        chomp($tagsIt);
        ($t940It,$t035,$t245It) = split/\|/,$tagsIt;
        print DIFFID "$t940It|$t245It||$ckey|$t940|$t245Sym|\n";
        print FIND_REC "$oclcIt\n";
        }
      else
        {
        print MALL "$oclcSym|$ckey|$pos23|$t337|$t940|\n"; 
        print CMATCH "$ckey\n";
        print NO940 "$ckey|$oclca|\n";
        }
      }
    else
      {
      print NOT_E "$ckey|$oclcSym|$pos23|$t337|\n";
      print FIND_REC "$oclcIt\n";
      }
    }
  else
    {
    print FIND_REC "$oclcIt\n";
    }
  }

@sortedMatches = `sort -u allMatches`;
push(@sortedMatches, "9|9|");
open(MULT,">multiMatch035");
open(SING,">singleMatch035");
$firstLine = "y";
$cnt = 0;
foreach $line (@sortedMatches)
  {
  chomp($line);
  ($oclcSym,$ckey,$stuff) = split/\|/,$line;
  $cnt++;
  if ($firstLine eq "y")
    {
    $firstLine = "n";
    }
  elsif ($oclcSym eq $oclcPrev)
    {
    print MULT "$linePrev\n" if $cnt != 1;
    print MULT "$line\n";
    $cnt = 0;
    print FIND_REC "$oclcSym\n";
    }
  else
    {
    print SING "$ckeyPrev|$oclcPrev|\n" if $cnt > 1;
    print M_OCLC "$oclcPrev\n" if $cnt > 1;
    }
  $linePrev = $line;
  $oclcPrev = $oclcSym;
  $ckeyPrev = $ckey;
  }

close(MULT);
close(SING);
close(M_OCLC);

open(MATCH,"singleMatch035");
open(RECMATCH,">match035a");
while ($line=<MATCH>)
  {
  chomp($line);
  ($ckey,$oclc) = split/\|/,$line;
  $rec = `grep $oclc noMatch022a`;
  chomp($rec);
  print RECMATCH "$ckey^$rec\n";
  #print CMATCH "$ckey\n";
  }
close(RECMATCH);

### No Match In Symphony ###
@recs0 = `grep "0 records" ckeys035.log`;

foreach $line2 (@recs0)
  {
  chomp($line2);
  $line2 =~ s/  0 records found for #.*: //;
  $line2 =~ s/.AL04.//;
  $line2 =~ s/ //g;
  $line2 =~ s/\"//g;
  print FIND_REC "$line2\n";
  }

close(FIND_REC);
close(NO);
system("sort -u noFindrec >noFindrecU");
system("egrep -fnoFindrecU noMatch022a >> noMatch035");
system("sort -u noMatch035 >noMatch035u");
system("egrep -fmatchedOCLC -v noMatch035u >noMatch035a");
