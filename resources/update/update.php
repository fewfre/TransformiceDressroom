<?php
require_once 'utils.php';

ini_set('display_errors', '1');
ini_set('display_startup_errors', '1');
error_reporting(E_ALL);

ini_set('max_execution_time', 3*60);
set_time_limit(3*60);

setProgress('starting');

// file_put_contents("testing.json", json_encode(array()));
// function ADD_LOG($msg) {
// 	$json = json_decode(file_get_contents("testing.json"), true);
// 	$json[] = $msg;
// 	file_put_contents("testing.json", json_encode($json, JSON_PRETTY_PRINT));
// }
// // Ping to confirm if server is booting us
// function ping($host, $port, $timeout) { $tB = microtime(true); $fP = fSockOpen($host, $port, $errno, $errstr, $timeout); if (!$fP) { return "down"; } $tA = microtime(true); return round((($tA - $tB) * 1000), 0)." ms"; }
// ADD_LOG( "PING: " . ping('www.transformice.com', 80, 100) );

// Check if Atelier801 server can be accessed
$isA801ServerOnline = fetchUrlMetaData("http://www.transformice.com/images/x_bibliotheques/x_meli_costumes.swf");
if(!$isA801ServerOnline['exists']) {
	setProgress('error', [ 'message' => "Update script cannot currently access the Atelier 801 servers - it may either be down, or script might be blocked/timed out" ]);
	exit;
}

$resources = array();
$external = array();

// Normal resources
$resources_base = array("x_meli_costumes", "costume", "x_fourrures");
foreach ($resources_base as $filebase) {
	for ($i = 1; $i <= 8; $i++) {
		setProgress('updating', [ 'message'=>"Resource: $filebase", 'value'=>$i, 'max'=>8 ]);
		
		$filename = $i==1 && $filebase != "costume" ? "{$filebase}.swf" : "{$filebase}{$i}.swf";
		$url = "http://www.transformice.com/images/x_bibliotheques/$filename";
		$file = "../$filename";
		downloadFileIfNewer($url, $file);
		
		// Check local file so that if there's a load issue the update script still uses the current saved version
		if(file_exists($file)) {
			$resources[] = $filename;
			$external[] = $url;
		}
	}
}

// Individual resources
$breakCount = 0; // quit early if enough 404s in a row
$start = 218; $max = 600;
for ($i = $start; $i <= $max; $i++) {
	setProgress('updating', [ 'message'=>'Fur Files', 'value'=>$i-$start+1, 'max'=>$max-$start ]);
	
	$filename = "f{$i}.swf";
	$url = "http://www.transformice.com/images/x_bibliotheques/fourrures/$filename";
	$filenameLocal = "furs/$filename";
	$file = "../$filenameLocal";
	downloadFileIfNewer($url, $file);
	
	// Check local file so that if there's a load issue the update script still uses the current saved version
	if(file_exists($file)) {
		$resources[] = $filenameLocal;
		$external[] = $url;
		$breakCount = 0;
	} else {
		$breakCount++;
		if($breakCount > 5) { break; }
	}
}

//
// Emoji Loading
//
$emojis = array();
// [prefix, pad]
$emojiPrefixes = array(
	["", 0],
	["1", 2], ["2", 2], ["3", 2], ["4", 2],
	["1", 4], ["2", 4], ["3", 4]
);
foreach ($emojiPrefixes as $prefixData) {
	list($prefix, $pad) = $prefixData;
	$start = 0;
	$max = $start + pow(10, $pad ?: 2); // ?: 2 is for the default "0" case
	$breakCount = 0; // quit early if enough 404s in a row
	
	for ($i = $start; $i <= $max; $i++) {
		$id = $prefix.str_pad($i, $pad, "0", STR_PAD_LEFT);
		setProgress('updating', [ 'message'=>"Emoji ($prefix:$pad): $id", 'value'=>$i-$start+1, 'max'=>$max-$start ]);
		$filename = "$id.png";
		$url = "https://www.transformice.com/images/x_transformice/x_smiley/$filename";
		$filenameLocal = "emojis/$filename";
		$file = "../$filenameLocal";
		downloadFileIfNewer($url, $file);
	
		// Check local file so that if there's a load issue the update script still uses the current saved version
		if(file_exists($file)) {
			$emojis[] = $filenameLocal;
			$breakCount = 0;
		} else {
			$breakCount++;
			if($breakCount > 5) { break; }
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
$json["emojis"] = $emojis;
$json["cachebreaker"] = time();//md5(time(), true);
file_put_contents($json_path, json_encode($json));//, JSON_PRETTY_PRINT

setProgress('completed');
echo "Update Successful!";

sleep(10);
setProgress('idle');
// echo "Update Successful! Redirecting...";
// echo '<script>window.setTimeout(function(){ window.location = "../"; },1000);</script>';