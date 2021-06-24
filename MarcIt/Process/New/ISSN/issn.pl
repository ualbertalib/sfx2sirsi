#!/u/sirsi/Unicorn/Bin/perl

open(NM940,"noMatch940");
open(OBJ022,">objID022It");
open(LST022,">t022");
open(NOIt,">noISSNit");
open(NO,">noMatch022");
open(FIND_REC, ">noFindrec");
while($line=<NM940>)
  {
  chomp($line);
  ($objectID,$t022,$t035,$ldr17,$t856,$t245) = split/\^/,$line;
  print OBJ022 "$objectID|$t022|$t245|\n";
  if ($t022 eq "")
    {
    print NOIt "$line\n";
    print NO "$line\n";
    }
  else
    {
    print LST022 "$t022\{022\}|\n";
    }
  }

close(LST022);
close(OBJ022);

system("cat t022 |seltext -oCS 2>ckeys022.log >ckeys022");
@ckeys022cleaned = `sed 's/\{022\}//' ckeys022`;

open(PCKEY,">possibleCkeys");
open(CISSN,">ckeyISSN");
foreach $line (@ckeys022cleaned)
  {
  chomp($line);
  print CISSN "$line\n";
  ($ckey,$issnIT) = split/\|/,$line;
  print PCKEY "$ckey\n";
  }
close(PCKEY);
close(CISSN);

system("cat possibleCkeys |catalogdump -oF >dump 2>dump.log");

open(DMP,"dump");
open(SYM,">symphonyTags");
$found940 = "y";
while ($line=<DMP>)
  {
  chomp($line);
  if ($line =~ /^\.001/)
    {
    $line =~ s/.001. \|a//;
    if ($found940 eq "n")
      {
      print SYM "|\n$line|";
      }
    else
      {
      print SYM "$line|";
      }
    $found940 = "n";
    $found337 = "n";
    }
  elsif ($line =~ /^\.008/)
    {
    $line =~ s/.008. \|a//;
    $pos23 = substr($line,23,1); #Repr  
    print SYM "$pos23|";
    }
  elsif ($line =~ /^\.022/)
    {
    $line =~ s/.022....//;
    ($stuff,$one,$others) = split/\|/,$line;
    if ($one =~ /^a/)
      {
      $one =~ s/^a//;
      ($t022a,$stuff) = split/ /,$one; #removes text
      print SYM "$t022a|";
      }
    else
      {
      print SYM "|";
      }
    }
  elsif ($line =~ /^\.245/)
    {
    $line =~ s/.245....\|a//;
    ($t245a,$stuff) = split/\|/,$line;
    print SYM "$t245a|";
    }
  elsif ($line =~ /^\.337/)
    {
    $line =~ s/.337.   \|a//;
    ($t337a,$stuff) = split/\|/,$line;
    print SYM "$t337a|";
    $found337 = "y";
    }
  elsif ($line =~ /^\.940/)
    {
    $line =~ s/.940.   \|a//;
    if ($found337 eq "n")
      {
      print SYM "|$line|\n";
      }
    else
      {
      print SYM "$line|\n";
      }
    $found940 = "y";
    }
  }

open(MALL, ">allMatches");
open(MATCH,">match022a");
open(CMATCH,">ckeyMatch022a");
open(NOT_E,">notElectronic");
open(DIFFID,">diffObjID");
open(NO940,">noObjID");
open(M_ISSN,">matchedISSN");

open(SYM,"symphonyTags");
while ($line=<SYM>)
  {
  chomp($line);
  ($ckey,$pos23,$issna,$t245Sym,$t337,$t940) = split/\|/,$line;
  $ckeyISSN = `grep $ckey ckeyISSN`;
  chomp($ckeyISSN);
  ($c,$issnIt) = split/\|/,$ckeyISSN;
  if ($issnIt eq $issna)
    {
    if ($pos23 eq "o" || $t337 =~ /computer/)
      {
      #$t940 = "";
      if ($t940 =~ /[0-9][0-9][0-9]/) #identifies an ObjID
        {
        $tagsIt = `grep $issnIt objID022It`;
        chomp($tagsIt);
        ($t940It,$t022,$t245It) = split/\|/,$tagsIt;
        print DIFFID "$t940It|$t245It||$ckey|$t940|$t245Sym|\n";
        print FIND_REC "$issnIt\n";
        }
      else
        {
        print MALL "$issna|$ckey|$pos23|$t337|$t940|\n"; 
        #print CMATCH "$ckey\n";
        print NO940 "$ckey|$issna|\n";
        }
      }
    else
      {
      print NOT_E "$ckey|$issna|$pos23|$t337|\n";
      print FIND_REC "$issnIt\n";
      }
    }
  else
    {
    print FIND_REC "$issnIt\n";
    }
  }

@sortedMatches = `sort -u allMatches`;
push(@sortedMatches, "9|9|");
open(MULT,">multiMatch022");
open(SING,">singleMatch022");
$firstLine = "y";
$cnt = 0;
foreach $line (@sortedMatches)
  {
  chomp($line);
  ($issna,$ckey,$stuff) = split/\|/,$line;
  $cnt++;
  if ($firstLine eq "y")
    {
    $firstLine = "n";
    }
  elsif ($issna eq $issnPrev)
    {
    print MULT "$linePrev\n" if $cnt != 1;
    print MULT "$line\n";
    $cnt = 0;
    print FIND_REC "$issna\n";
    }
  else
    {
    print SING "$ckeyPrev|$issnPrev|\n" if $cnt > 1;
    print M_ISSN "$issnPrev\n" if $cnt > 1;
    }
  $linePrev = $line;
  $issnPrev = $issna;
  $ckeyPrev = $ckey;
  }

close(MULT);
close(SING);
close(M_ISSN);

open(MATCH,"singleMatch022");
open(RECMATCH,">match022a");
while ($line=<MATCH>)
  {
  chomp($line);
  ($ckey,$issn) = split/\|/,$line;
  $rec = `grep $issn noMatch940`;
  chomp($rec);
  print RECMATCH "$ckey^$rec\n";
  print CMATCH "$ckey\n";
  }
close(RECMATCH);

### No Match In Symphony ###
@recs0 = `grep "0 records" ckeys022.log`;

foreach $line2 (@recs0)
  {
  chomp($line2);
  $line2 =~ s/  0 records found for #.*: //;
  $line2 =~ s/.T022.//;
  $line2 =~ s/ //g;
  print FIND_REC "$line2\n";
  }

close(FIND_REC);
close(NO);
system("sort -u noFindrec >noFindrecU");
system("egrep -fnoFindrecU noMatch940 >> noMatch022");
system("sort -u noMatch022 >noMatch022u");
system("egrep -fmatchedISSN -v noMatch022u >noMatch022a");
