<?php
$resources_base = array("x_meli_costumes", "x_fourrures");

$resources = array();
foreach ($resources_base as $filebase) {
	for ($i = 1; $i <= 5; $i++) {
		$filename = $i==1 ? "{$filebase}.swf" : "{$filebase}{$i}.swf";
		$url = "http://www.transformice.com/images/x_bibliotheques/$filename";
		$code = checkExternalFile($url);
		if($code == 200 || $code == 300) {
			file_put_contents($filename, fopen($url, 'r'));
			$resources[] = $filename;
		}
	}
}

$json = json_decode(file_get_contents("config.json"), true);
$json["packs"]["items"] = $resources;
$json["cachebreaker"] = time();//md5(time(), true);
file_put_contents("config.json", json_encode($json));//, JSON_PRETTY_PRINT

echo "Update Successful! Redirecting...";
echo '<script>window.setTimeout(function(){ window.location = "../"; },1000);</script>';

function checkExternalFile($url)
{
	$ch = curl_init($url);
	curl_setopt($ch, CURLOPT_NOBODY, true);
	curl_exec($ch);
	$retCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
	curl_close($ch);

	return $retCode;
}
?>
