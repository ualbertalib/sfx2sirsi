#!/u/sirsi/Unicorn/Bin/perl

system("cp n.txt new");
system("echo num=000 >>new");
open(TAG,"new") || die "Can't open new: $!";
open(RECS,">records");
open(LST,">objID940");
$firstRec = "y";

while ($line=<TAG>)
  {
  chomp($line);
  if ($line =~ /num=000/)
    {
    if ($firstRec eq "y")
      {
      $firstRec = "n";
      }
    else
      {
      if ($objectID eq "")
        {
        $objectID = "0";
        }
      print LST "$objectID\{940\}\n";
      print RECS "$objectID^$t022^@t035^$ldr17^$t856^$t245^\n";
      $objectID = "";
      $t022 = "";
      @t035 = "";
      $ldr17 = "";
      $t245 = "";
      $t856 = "";
      }
    $line =~ s/num=000   //;
    $ldr17 = substr($line,2,1); #Enc_Lvl
    }
  elsif ($line =~ /num=008/)
    {
    $line =~ s/num=008   //;
    }
  elsif ($line =~ /num=022/)
    {
    $t022 = $line;
    $t022 =~ s/num=022...//;
    $t022orig = $t022;
    if ($t022 =~ /^\|/)
      {
      $t022 = "";
      }
    elsif ($t022 !~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9,X]/)
      {
      $t022 = "";
      }
    else
      {
      ($t022a,$junk) = split/\|/,$t022;
      $t022 = $t022a;
      $t022A = $t022;
      }
    }
  elsif ($line =~ /num=035/)
    {
    $t035 = $line;
    $t035 =~ s/num=035//;
    $t035 =~ s/   \(OCoLC\)//;
    push(@t035,$t035);
    }
  elsif ($line =~ /num=245/)
    {
    $line =~ s/num=245...//;
    ($t245,$stuff) = split/\|/,$line;
    }
  elsif ($line =~ /num=776/)
    {
    $t776 = $line;
    }
  elsif ($line =~ /num=856/)
    {
    $line =~ s/num=856 40//;
    ($stuff,$sub3,$t856) = split/\|/,$line;
    $t856 =~ s/^u//;
    }
  elsif ($line =~ /num=866/)
    {
    $t866 = $line;
    $t866 =~ s/num=866   //;
    }
  elsif ($line =~ /num=922/)
    {
    $t922 = $line;
    }
  elsif ($line =~ /num=940/)
    {
    $objectID = $line;
    $objectID =~ s/num=940   //;
    }    
  elsif ($line =~ /num=941/)
    {
    $t941 = $line;
    $t941 =~ s/num=941   //;
    if ($t941 =~ /derived/)
      {
      $ldr17 = "7";
      }
    elsif ($t941 =~ /stub/)
      {
      $ldr17 = "z";
      }
    elsif ($t941 =~ /pcc/)
      {
      $ldr17 = " ";
      }

    if ($t941 eq "derived")
      {
      if ($t776 =~ /[oO]nline/)
        {
        $t976 = $t776;
        $t922 = $t022orig;
        $t935 = $t035;
        (@fields) = split/\|/,$t976;
        $w = "";
        $x = "";
        $foundx = "n";
        foreach $field (@fields)
          {
          if ($field =~ /OCoLC/)
            {
            $w = $field;
            $w =~ s/^w//;
            $t035 = $w;
            }
          elsif ($field =~ /^x/)
            {
            $foundx = "y";
            $x = $field;
            $x =~ s/^x//;
            $t022 = $x;
            $t022aa = $t022;
            }
          }
        if ($foundx eq "y")
          {
          #(@fields) = split/\|/,$t922;
          #print "$l|$one|$two\n";
          }
        else
          {
          $t022 = "";
          }
        }
      #print "$t035^^t=$t022^^$foundx^^A=$t022A\n";
      }
    }
  else
    {
    #print "unknown line\n";
    }
  }
close(RECS);
close(LST);
close(TAG);
