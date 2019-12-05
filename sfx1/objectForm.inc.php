<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
?>

<form method="post">
    
    <div>
        Object ID:  <input type="text" name="object_id" value="<?php echo @ $_POST['object_id']; ?>">
        <input type="submit" value="Get Threshold">
    </div>
</form>