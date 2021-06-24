#!/u/sirsi/Unicorn/Bin/perl

@recs0 = `grep "0 records" ckeysID.log`;

open(NO,">no");
foreach $line2 (@recs0)
  {
  chomp($line2);
  #$line2 =~ s/0 records found for #.: "//;
  $line2 =~ s/0 records found for #.*: "//;
  $line2 =~ s/"//;
  $line2 =~ s/ //g;
#print "$line2\n";
  @lines2 = `grep $line2 records 2>>err`;
  foreach $rec (@lines2)
    {
    chomp($rec);
    print NO "$rec\n";
    }
  }
