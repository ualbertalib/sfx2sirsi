#!/u/sirsi/Unicorn/Bin/perl

@sortedMatches = `sort -u allMatches.test`;
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
    print MULT "$linePrev|$cnt\n" if $cnt != 1;
    print MULT "$line|$cnt|\n";
    $cnt = 0;
    print FIND_REC "$issna\n";
    }
  else
    {
    print SING "$ckeyPrev|$issnPrev|\n" if $cnt > 1;
    print M_ISSN "$issnPrev\n" if $cnt > 1;
    }
  $linePrev2 = $linePrev;
  $linePrev = $line;
  $issnPrev = $issna;
  $ckeyPrev = $ckey;
  }


