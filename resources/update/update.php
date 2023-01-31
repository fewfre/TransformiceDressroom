<?php
set_time_limit(3*60);

$resources = array();
$external = array();

setProgress('starting');

// Normal resources
$resources_base = array("x_meli_costumes", "costume", "x_fourrures");
foreach ($resources_base as $filebase) {
	for ($i = 1; $i <= 8; $i++) {
		setProgress('updating', [ 'message'=>"Resource: $filebase", 'value'=>$i, 'max'=>8 ]);
		
		$filename = $i==1 && $filebase != "costume" ? "{$filebase}.swf" : "{$filebase}{$i}.swf";
		$url = "http://www.transformice.com/images/x_bibliotheques/$filename";
		if(checkExternalFileExists($url)) {
			file_put_contents("../$filename", fopen($url, 'r'));
			$resources[] = $filename;
			$external[] = $url;
		}
	}
}

// Individual resources
$breakCount = 0; // quit early if enough 404s in a row
for ($i = 218; $i <= 500; $i++) {
	setProgress('updating', [ 'message'=>'Fur Files', 'value'=>$i-218+1, 'max'=>500-218 ]);
	
	$filename = "f{$i}.swf";
	$url = "http://www.transformice.com/images/x_bibliotheques/fourrures/$filename";
	if(checkExternalFileExists($url)) {
		file_put_contents("../$filename", fopen($url, 'r'));
		$resources[] = $filename;
		$external[] = $url;
		$breakCount = 0;
	} else {
		$breakCount++;
		if($breakCount > 5) {
			break;
		}
	}
}

setProgress('updating');

// Finally include poses
$external[] = "https://projects.fewfre.com/a801/transformice/dressroom/resources/poses.swf";

$json_path = "../config.json";
$json = json_decode(file_get_contents($json_path), true);
$json["packs"]["items"] = $resources;
$json["packs_external"] = $external;
$json["cachebreaker"] = time();//md5(time(), true);
file_put_contents($json_path, json_encode($json));//, JSON_PRETTY_PRINT

setProgress('completed');
echo "Update Successful!";

sleep(10);
setProgress('idle');
// echo "Update Successful! Redirecting...";
// echo '<script>window.setTimeout(function(){ window.location = "../"; },1000);</script>';

function checkExternalFileExists($url) {
	$ch = curl_init($url);
	curl_setopt($ch, CURLOPT_NOBODY, true);
	curl_exec($ch);
	$retCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
	curl_close($ch);

	return $retCode == 200 || $retCode == 300;
}

function setProgress($state, $data = array()) {
	$data['state'] = $state;
	$date_utc = new \DateTime("now", new \DateTimeZone("UTC"));
	$data['timestamp'] = $date_utc->format('Y-m-d\TH:i:s\Z');
	file_put_contents("progress.json", json_encode($data));
}
?>
