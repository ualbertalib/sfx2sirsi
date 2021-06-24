#!/u/sirsi/Unicorn/Bin/perl

open(DMP,"dump");
open(DEL856,">delSFX856");
open(DISCARD,">setDiscard");
$firstLine = "y";
while ($line=<DMP>)
  {
  chomp($line);
  if ($line =~ /^\.001/)
    {
    if ($firstLine eq "y")
      {
      $firstLine = "n";
      }
    else
      {
      if ($foundUAL eq "y")
        {
        if ($foundOtherLib eq "y")
          {
          if ($foundNonSFX eq "y" && $foundSFX856 eq "y")
            {
            print DEL856 "$ckey\n";
            }
          elsif ($foundNonSFX eq "n" && $foundSFX856 eq "y")
            {
            print DEL856 "$ckey\n";
            print DISCARD "$itemIdUA|$t940a|\n";
            }
          }
        else
          {
          if ($foundNonSFX eq "y" && $foundSFX856 eq "y")
            {
            print DEL856 "$ckey\n";
            }
          elsif ($foundNonSFX eq "n" && $foundSFX856 eq "y")
            {
            print DEL856 "$ckey\n";
            print DISCARD "$itemIdUA|$t940a|\n";
            }
          }
        }
      else
        {
        #print "No UA - $itemIdOther\n";
        }
   
      $foundUAL = "n";
      $foundOtherLib = "n";
      $foundSFX856 = "n";
      $foundNonSFX = "n";
      }
    $line =~ s/.001. \|a//;
    $ckey = $line;
    }
  elsif ($line =~ /^\.856/)
    {
    ($t,$t3,$tu) = split/\|/,$line;
    if ($t3 =~ /University of Alberta Access/)
      {
      if ($tu =~ /resolver/)
        {
        $foundSFX856 = "y";
        }
      else
        {
        $foundNonSFX = "y";
        }
      }
    }
  elsif ($line =~ /^\.940/)
    {
    ($t,$t940a) = split/\|/,$line;
    $t940a =~ s/a//;
    }
  elsif ($line =~ /^\.999/)
    {
    (@fields) = split/\|/,$line;
    foreach $field (@fields)
      {
      if ($field =~ /^m/) #library
        {
        $field =~ s/^m//;     
        if ($field eq "UAINTERNET")
          {
          $foundUAL = "y";
          }
        else
          {
          $foundOtherLib = "y";
          }
        }
      elsif ($field =~ /^i/)
        {
        $field =~ s/^i//;
        if ($line =~ /UAINTERNET/)
          {
          $itemIdUA = $field;
          }
        else
          {
          $itemIdOther = $field;
          }
        }
      }
    }
  }

