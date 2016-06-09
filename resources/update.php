<?php
file_put_contents("x_meli_costumes.swf", fopen("http://www.transformice.com/images/x_bibliotheques/x_meli_costumes.swf", 'r'));
file_put_contents("x_fourrures.swf", fopen("http://www.transformice.com/images/x_bibliotheques/x_fourrures.swf", 'r'));
file_put_contents("x_fourrures2.swf", fopen("http://www.transformice.com/images/x_bibliotheques/x_fourrures2.swf", 'r'));
echo "Update Successful! Redirecting...";
echo '<script>window.setTimeout(function(){ window.location = "../"; },1000);</script>'
?>