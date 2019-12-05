<?php

/*
 * Description of batchTest
 * 
 * @author Jeremy Hennig <jhennig@ualberta.ca>
 */
set_time_limit(0);
$mtime = microtime();
$mtime = explode(" ",$mtime);
$mtime = $mtime[1] + $mtime[0];
$starttime = $mtime; 
$problemRecord="";
$myPossibleErrorObjectID="";
function handleError($errno, $errstr, $errfile, $errline, array $errcontext)
{
	global $problemRecord, $myPossibleErrorObjectID;
	//if the @ symbol was used skipp
	if (0 === error_reporting()) {
        return false;
    }
	//this is done to prevent repeated errors for the same object
	if ($problemRecord!=$myPossibleErrorObjectID){
		//echo 'Error No:' . $errno . 'ErrorStr ' . $errstr . ' ErrFile ' . $errfile .  '- errline' . $errline . "\r\n <br><br>";			
		echo "-PROBLEM RECORD-<br>";
		$problemRecord=$myPossibleErrorObjectID;
	}
    // error was suppressed with the @-operator
  

    //throw new ErrorException($errstr, 0, $errno, $errfile, $errline);
}
set_error_handler('handleError');

   
 include_once('config.inc.php');
 include_once ('Threshold2.class.php');
 
function cleanParen($value){
     $value=ltrim(trim($value),'(');
     $value=str_replace("))", ")", trim($value));
     return $value;
}

 file_put_contents('./File.txt', "");
 //Get the Objects ID's from SFX database
 $sfx_query = "SELECT distinct KB_O.OBJECT_ID 
FROM sfxglb41.KB_OBJECTS KB_O, 
sfxglb41.KB_OBJECT_PORTFOLIOS KB_OP
INNER JOIN sfxlcl41.LCL_OBJECT_PORTFOLIO_INVENTORY L_OPI ON (KB_OP.OP_ID=L_OPI.OP_ID)

WHERE KB_OP.OBJECT_ID=KB_O.OBJECT_ID 
AND L_OPI.Activation_Status = 'ACTIVE' and not KB_OP.Threshold is null 
 and KB_OP.OBJECT_ID=954925402586 
ORDER BY KB_OP.OBJECT_ID Limit 1000000";
         //AND KB_O.OBJECT_ID>'954900000000' AND KB_O.OBJECT_ID<='955991998033'  
 
$result = mysql_query($sfx_query,$SFX_link) or die('error1:' . mysql_error()) ;

echo "<b>Number of Objects: </b>" . mysql_num_rows($result)."<br>";

$counter = 0;
$obj = new Threshold2();

$myFile = fopen('./File.txt','w');


while ($row= mysql_fetch_assoc($result)){
    
    echo "<strong>" . $row['OBJECT_ID'] . "</strong> -- ";
    
    fwrite($myFile, $row['OBJECT_ID'].'-');
            $sfx_query = "SELECT DISTINCT KB_OP.OP_ID, KB_OP.Threshold Threshold, L_OPLI.Threshold LCL_Threshold , KB_TS.IS_FREE
            FROM  sfxglb41.KB_TARGET_SERVICES KB_TS , 
                    sfxglb41.KB_OBJECT_PORTFOLIOS KB_OP, 
                    sfxlcl41.LCL_OBJECT_PORTFOLIO_INVENTORY L_OPI 
                    LEFT JOIN sfxlcl41.LCL_OBJECT_PORTFOLIO_LINKING_INFO L_OPLI ON 
                    (L_OPI.OP_ID = L_OPLI.OP_ID)
            WHERE KB_TS.TARGET_ID=KB_OP.TARGET_ID AND 
                    ( KB_OP.object_id = '".$row['OBJECT_ID']."'
                            AND L_OPI.OP_ID = KB_OP.OP_ID
                      )  AND KB_TS.SERVICE_TYPE!='getTOC' 
                      AND KB_TS.SERVICE_TYPE !='getMessageNoFullTxt' AND SERVICE_TYPE!='getAbstract'
                      AND L_OPI.Activation_Status='ACTIVE' 
            ORDER BY KB_OP.object_id";
            
			
              $result2 = mysql_query($sfx_query,$SFX_link) or die('error2:' . mysql_error()) ;
              
              $runonce=0;
			  $IS_FREE=0;
               while ($row2= mysql_fetch_assoc($result2)){
			  
					if ($row2['LCL_Threshold']!=""){
								$mythreshold = $row2['LCL_Threshold'];
							}else{
								$mythreshold = $row2['Threshold'];
							}   
				 $dispThreshold[] = $mythreshold ;
					//get arround an error that's causeing problems: TODO: make sure only parseDate and timeDiff are called
                  if (strpos($mythreshold,'tiffdiff') === false) {
							if ($row2['IS_FREE']==1){
								$IS_FREE=1;
							}
						  $myPossibleErrorObjectID = $row['OBJECT_ID'];
							include('thresholdprocess.inc.php');
							
							
						   $counter +=1;
				   }else{
					$runonce=0;
				
				   }
			  }
               
           //Output the result    
         if ($runonce==1){
            $obj->show();
            $msg = $obj->translateDateRange();
            //fwrite($myFile,$msg);
			if ($IS_FREE==1){
            echo $msg . "[IS_FREE] " . "<br>";
			}else{
			echo $msg . "<br>";
			}
         }
		
         $obj->clear();
}

echo "Number of thresholds" . $counter."<br>";

$mtime = microtime();
$mtime = explode(" ",$mtime);
$mtime = $mtime[1] + $mtime[0];
$endtime = $mtime;
$totaltime = ($endtime - $starttime);
echo "This page was created in ".$totaltime." seconds"; 
fclose($myFile);
echo "<br><br>";
foreach($dispThreshold as $value){

echo $value . "<br>";

}

?>