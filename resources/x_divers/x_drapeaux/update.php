<?php
set_time_limit(3*60);

// Normal resources
foreach(range('A','Z') as $a){
	foreach(range('A','Z') as $b){
		$filename = "$a$b.png";
		$url = "http://www.transformice.com/images/x_divers/x_drapeaux/$filename";
		if(checkExternalFileExists($url)) {
			file_put_contents("$filename", fopen($url, 'r'));
		}
	}
}

function checkExternalFileExists($url) {
	$ch = curl_init($url);
	curl_setopt($ch, CURLOPT_NOBODY, true);
	curl_exec($ch);
	$retCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
	curl_close($ch);

	return $retCode == 200 || $retCode == 300;
}
