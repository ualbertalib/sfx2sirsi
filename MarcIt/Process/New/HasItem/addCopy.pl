sub addCopy
  {
  my $itemid      = $_[0];
 
  #S - start of request
  #03 - 2 digit sequence number (01 - 99)
  #FF - data code - station login user access
  #AV - cmd code - Add Item
  $req  = "^S04AVFFADMIN";
  $req .= "^FcNONE";
  $req .= "^FEUASCITECH";
  $req .= "^NQ$itemid";
  $req .= "^NRAUTO";
  $req .= "^IQInternet Access";
  $req .= "^IS1";
  $req .= "^NWCALL";
  $req .= "^NfNONE";
  $req .= "^NAInternet Access";
  $req .= "^NB1";
  $req .= "^NSUAINTERNET";
  $req .= "^IKSERIAL"; 
  $req .= "^NXE-JOURNAL"; 
  $req .= "^IGE-RESOURCE";
  $req .= "^ININTERNET";
  $req .= "^IP0.00";
  $req .= "^ITY";
  $req .= "^IXY";
  $req .= "^If0";
  $req .= "^I61";
  $req .= "^IrLCPER";
  $req .= "^JFN";
  $req .= "^JGN^^O";
  
  print ADDCOPY "$req\n";

  }
1;
