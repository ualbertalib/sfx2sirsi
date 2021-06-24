#!/u/sirsi/Unicorn/Bin/perl

system("cp d.txt deleted");
system("echo num=000 >>deleted");
open(TAG,"deleted") || die "Can't open new: $!";
open(RECS,">records");
open(LST,">objID940");
$firstRec = "y";

while ($line=<TAG>)
  {
  chomp($line);
  if ($line =~ /num=000/)
    {
    #num=000   as a0n a
    #$Enc_Lvl = substr($tag000,2,1);
    if ($firstRec eq "y")
      {
      $firstRec = "n";
      }
    else
      {
      print LST "$objectID\{940\}\n";
      print RECS "$objectID^$ldr17^\n";
      $objectID = "";
      $ldr17 = "";
      }
    $line =~ s/num=000   //;
    $ldr17 = substr($line,2,1); #Enc_Lvl
    }
  elsif ($line =~ /num=940/)
    {
    #num=940   954921384850
    $objectID = $line;
    $objectID =~ s/num=940   //;
    #print "$t940\n";
    }    
  else
    {
    #print "unknown line\n";
    }
  }
close(RECS);
close(LST);
close(TAG);
