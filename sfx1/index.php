<?php

 ini_set('display_errors',1);
 error_reporting(E_ALL);

 include_once('config.inc.php');
 include_once ('Threshold2.class.php');
 include_once('objectForm.inc.php');

 if (!isset($_POST['object_id'])){
     exit();
 }
 $object_id = trim($_POST['object_id']);

$sfx_query = "SELECT DISTINCT KB_T.Target_id, KB_OP.OP_ID, KB_TS.TARGET_SERVICE_ID, KB_T.Target_Name, 
KB_T.TARGET_PUBLIC_NAME, KB_TS.SERVICE_TYPE, 
 L_OPI.LAST_UPDATE_DATE,
L_OPI.Activation_Status, KB_OP.Threshold Threshold, L_OPLI.Threshold LCL_Threshold
  FROM  sfxglb41.KB_TARGETS KB_T, 
	sfxglb41.KB_TARGET_SERVICES KB_TS , 
	sfxglb41.KB_OBJECT_PORTFOLIOS KB_OP,
	sfxlcl41.LCL_OBJECT_PORTFOLIO_INVENTORY L_OPI
	LEFT JOIN sfxlcl41.LCL_OBJECT_PORTFOLIO_LINKING_INFO L_OPLI ON 
	L_OPI.OP_ID = L_OPLI.OP_ID
	
WHERE KB_TS.TARGET_ID=KB_T.TARGET_ID AND 
 	( KB_T.TARGET_ID IN (SELECT TARGET_ID FROM sfxglb41.KB_OBJECT_PORTFOLIOS KB_OP WHERE OBJECT_ID='" . mysql_real_escape_string($object_id)  . "') 	
		AND L_OPI.OP_ID IN (SELECT OP_ID FROM sfxglb41.KB_OBJECT_PORTFOLIOS KB_OP WHERE OBJECT_ID='". mysql_real_escape_string($object_id) . "')
		AND L_OPI.OP_ID = KB_OP.OP_ID
		AND KB_OP.TARGET_ID=KB_T.TARGET_ID
	  ) AND L_OPI.Activation_Status = 'ACTIVE' AND KB_TS.SERVICE_TYPE!='getTOC' 
          AND KB_TS.SERVICE_TYPE !='getMessageNoFullTxt' AND SERVICE_TYPE!='getAbstract'
          
ORDER BY KB_T.TARGET_NAME
LIMIT 100";


function cleanParen($value){
     $value=ltrim(trim($value),'(');
     $value=str_replace("))", ")", trim($value));
     return $value;
}


$result = mysql_query($sfx_query,$SFX_link) or die('error:' . mysql_error()) ;

$obj = new Threshold2();

// if the threshold parts contain        
    
while ($row= mysql_fetch_assoc($result)){    
    
            //$title = $row['Target_Name'];
             $obj->setOP_ID($row['OP_ID']);        
             
            if ($row['LCL_Threshold']!=""){
                $threshhold = $row['LCL_Threshold'];
            }else{
                $threshhold = $row['Threshold'];            
            }
         
      if (strpos($threshhold, '||') !== false){
             
                if ($row['LCL_Threshold']!=""){
                    $thresholdParts = explode("||", $row['LCL_Threshold']);
                }else{
                    $thresholdParts = explode("||", $row['Threshold']);            
                }
                foreach ($thresholdParts as $key=>$threshPart_val){
                   
                       $threshPart_val=cleanParen($threshPart_val);
                       $thresholdParts = explode("&&", $threshPart_val);
                    if ( isset($thresholdParts[0]) && strpos($thresholdParts[0],'parsedDate') ){
                         //The replace adds the 'part' parameter to the calling of the parsedDate function
                        $functionCall = str_ireplace(')',',0)',$thresholdParts[0]);                        
                        eval( $functionCall.';');
                    }
                    if ( isset($thresholdParts[1])  ){
                         // The replace adds the 'part' parameter to the calling of the parsedDate function 
                         // $functionCall = str_ireplace(')',',1)',$thresholdParts[1]); 
                        $functionCall = $thresholdParts[1]; 
                        eval($functionCall.';'); 
                      
                    }else{
                        $obj->setMaxDatePart();
                    }
                    
                    $obj->timespan_merge(); 
                    $obj->removeOverlap();  
                    $obj->show();           
                    $obj->translateDateRange();
                }
                
         }else{ 
                    //Allow the local threshold to override the global ONLY if the local threshold is not blank
                    if ($row['LCL_Threshold']!=""){
                        $thresholdParts = explode("&&", $row['LCL_Threshold']);
                    }else{
                        $thresholdParts = explode("&&", $row['Threshold']);
                    }
                    // if the threshold parts contain        
                    // if (strpos($a, '||') !== false)
                    // echo 'true';
                   /* echo "<strong>";
                    print_r($thresholdParts);
                    echo "</strong><br>"; */
                    //if the function that get's called is parsedDate
                    //TODO Possible FOR loop here to loop through the operands
                    if ( isset($thresholdParts[0]) && strpos($thresholdParts[0],'parsedDate') ){
                         //The replace adds the 'part' parameter to the calling of the parsedDate function
                        $functionCall = str_ireplace(')',',0)',$thresholdParts[0]);
                        
                        eval( $functionCall.';');
                    }
                    if ( isset($thresholdParts[1])  ){
                         //The replace adds the 'part' parameter to the calling of the parsedDate function
                        // $functionCall = str_ireplace(')',',1)',$thresholdParts[1]);
                        $functionCall = $thresholdParts[1];
                        eval($functionCall.';');
                      //  echo "--" . $functionCall . "is called <br>";
                    }else{
                       // echo "second operand is NULL";
                        $obj->setMaxDatePart();
                    }
                    $obj->timespan_merge();
                   
                    $obj->removeOverlap();
                    
                    $runonce=1;
                    
         } 
}

 //echo "<br>Title: <strong>" . $title . "</strong><br>";

if (isset($runonce)){
        $obj->show();
        $obj->translateDateRange();
}        
            
?>