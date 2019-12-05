<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
 

error_reporting(E_ALL);
ini_set('display_errors',1);
$myPath = dirname(__FILE__);
$include_Path="/var/www/sites/www.library.ualberta.ca/docroot/phpincludes";
set_include_path(get_include_path() . PATH_SEPARATOR . $include_Path);

require_once('Connect.class.php');

$connRes = new Connect('SFX_Resolver');
$SFX_link = $connRes->getDBConnect();

//done so errors don't come from a threshold where undef is in the string
define('undef','undef');



?>