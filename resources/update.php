<?php
$resources = array("x_meli_costumes.swf", "x_fourrures.swf", "x_fourrures2.swf", "x_fourrures3.swf");
foreach ($resources as $filename) {
	file_put_contents($filename, fopen("http://www.transformice.com/images/x_bibliotheques/$filename", 'r'));
}
echo "Update Successful! Redirecting...";
echo '<script>window.setTimeout(function(){ window.location = "../"; },1000);</script>';
?>
