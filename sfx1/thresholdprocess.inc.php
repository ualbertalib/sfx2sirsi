<?php

/*
 * Description of thresholdprocess
 * 
 * @author Jeremy Hennig <jhennig@ualberta.ca>
 */

  $obj->setOP_ID($row2['OP_ID']);        
              
            if ($row2['LCL_Threshold']!=""){
                $threshhold = $row2['LCL_Threshold'];
            }else{
                $threshhold = $row2['Threshold'];            
            }
			
         //If the threshold has a OR statement in it
      if (strpos($threshhold, '||') !== false){
            
                if ($row2['LCL_Threshold']!=""){
                    $thresholdParts = explode("||", $row2['LCL_Threshold']);
                }else{
                    $thresholdParts = explode("||", $row2['Threshold']);            
                }
                foreach ($thresholdParts as $key=>$threshPart_val){
                   
                       $threshPart_val=cleanParen($threshPart_val);
                       $thresholdParts = explode("&&", $threshPart_val);
                    if ( isset($thresholdParts[0]) && strpos($thresholdParts[0],'parsedDate') ){
                         //The replace adds the 'part' parameter to the calling of the parsedDate function
                        $functionCall = str_ireplace(')',',0)',$thresholdParts[0]);   
						// calls $obj->parsedDate($op, $year, $vol, $issue, $part=null) 
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
                    //OR statements work differently as they are like 2 statements in 1 Object Portfolio so we need to display them here
                    $obj->timespan_merge(); 
                    $obj->removeOverlap();  
                    $obj->show();
                    $msg=$obj->translateDateRange();
                     fwrite($myFile,$msg);
                      echo $msg . "<br>";
                }
                
         }else{ 
			
                    //Allow the local threshold to override the global ONLY if the local threshold is not blank
                    if ($row2['LCL_Threshold']!=""){
                        $thresholdParts = explode("&&", $row2['LCL_Threshold']);
                    }else{
                        $thresholdParts = explode("&&", $row2['Threshold']);
                    }      
					
                    //if the function that get's called is parsedDate
                    //TODO Possible FOR loop here to loop through the operands
                    if ( isset($thresholdParts[0]) && strpos($thresholdParts[0],'parsedDate') ){
                         //The replace adds the 'part' parameter to the calling of the parsedDate function
						// echo "--Before str_ireplace" . $thresholdParts[0] . "<br>";
						 
						$functionCall = str_ireplace('))',')',$thresholdParts[0]);						
                        $functionCall = str_ireplace(')',',0)',$functionCall);
						$functionCall = str_ireplace('($obj->','$obj->',$functionCall);
                        
                      //  echo "-" . $functionCall . "is called <br>";
                        eval( $functionCall.';');
						
                         
                    }
                    if ( isset($thresholdParts[1])  ){
                         //The replace adds the 'part' parameter to the calling of the parsedDate function
                        // $functionCall = str_ireplace(')',',1)',$thresholdParts[1]);
                        $functionCall = $thresholdParts[1];
                      //  echo "--" . $functionCall . "is called <br>";
                        eval($functionCall.';');
                        
                    }else{
                       // echo "second operand is NULL";
                        $obj->setMaxDatePart();
                    }
                    $obj->timespan_merge();
                    $obj->removeOverlap();
                    $runonce=1;
                    
         } 
		
?>
