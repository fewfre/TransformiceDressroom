<?php
require_once 'utils.php';
define('URL_TO_CHECK_IF_SCRIPT_HAS_ACCESS_TO_ASSETS', "http://www.transformice.com/images/x_bibliotheques/x_meli_costumes.swf");

setProgress('starting');

// Check if Atelier801 server can be accessed
$isA801ServerOnline = fetchHeadersOnly(URL_TO_CHECK_IF_SCRIPT_HAS_ACCESS_TO_ASSETS);
if(!$isA801ServerOnline['exists']) {
	setProgress('error', [ 'message' => "Update script cannot currently access the Atelier 801 servers - it may either be down, or script might be blocked/timed out" ]);
	exit;
}

////////////////////////////////////
// Core Logic
////////////////////////////////////

// Basic Resources

list($resourcesBasic, $externalBasic) = updateBasicResources();
list($resourcesSingles, $externalSingles) = updateFurSingleItemFiles();

// Finally include poses - only needed for external as included in a different way for non-external
$staticExternal = ["https://projects.fewfre.com/a801/transformice/dressroom/resources/poses.swf"];

setProgress('updating');
$json = getConfigJson();
$json["packs"]["items"] = array_merge($resourcesBasic, $resourcesSingles);
$json["packs_external"] = array_merge($externalBasic, $externalSingles, $staticExternal);
saveConfigJson($json);

// Emojis

$emojis = updateEmojis();

setProgress('updating');
$json = getConfigJson();
$json["emojis"] = $emojis;
saveConfigJson($json);

// Finished

setProgress('completed');
echo "Update Successful!";

sleep(10);
setProgress('idle');

////////////////////////////////////
// Update Functions
////////////////////////////////////

function updateBasicResources() {
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
	
	return [$resources, $external];
}

function updateFurSingleItemFiles() {
	$resources = array();
	$external = array();
	
	function makeDataFromFileIndex_fourrures($i) {
		$filename = "f{$i}.swf";
		$filenameLocal = "furs/$filename";
		return [
			'filename' => $filename,
			'filenameLocal' => $filenameLocal,
			'localFilePath' => "../$filenameLocal",
			'url' => "http://www.transformice.com/images/x_bibliotheques/fourrures/$filename",
		];
	}
	
	// Individual resources
	$start = 218; $max = 600;
	
	// Fetch headers and download any files that need downloading
	$headerCheckUrlDataList = array_map(fn($i) => makeDataFromFileIndex_fourrures($i), range($start, $max));
	fetchHeadersOnlyMulti_inChunksWithDataList_downloadIfNeeded($headerCheckUrlDataList, "fur");
		
	// Check local file before adding to list, so that if there's a load issue the update script still uses the current saved version
	setProgress('updating', [ 'message'=>"Generating list of all furs" ]);
	
	$breakCount = 0; // quit early if enough 404s in a row
	for ($i = $start; $i <= $max; $i++) {
		setProgress('updating', [ 'message'=>'Fur Files', 'value'=>$i-$start+1, 'max'=>$max-$start ]);
		
		list('url' => $url, 'localFilePath' => $file, 'filenameLocal' => $filenameLocal) = makeDataFromFileIndex_fourrures($i);
		
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
	
	return [$resources, $external];
}

function updateEmojis() {
	$emojis = array();
	
	function makeDataFromFileIndex_smiley($prefix, $pad, $i) {
		$id = $prefix.str_pad($i, $pad, "0", STR_PAD_LEFT);
		$filename = "$id.png";
		$filenameLocal = "emojis/$filename";
		return [
			'filename' => $filename,
			'filenameLocal' => $filenameLocal,
			'localFilePath' => "../$filenameLocal",
			'url' => "https://www.transformice.com/images/x_transformice/x_smiley/$filename",
		];
	}
	
	// [prefix, pad]
	$emojiPrefixes = array(
		["", 0],
		["1", 2], ["2", 2], ["3", 2], ["4", 2],
		["1", 4], ["2", 4], ["3", 4]
	);
	foreach ($emojiPrefixes as $prefixData) {
		list($prefix, $pad) = $prefixData;
		$typeName = "Emoji ($prefix:$pad)";
		$start = 0;
		$max = $start + pow(10, $pad ?: 2); // ?: 2 is for the default "0" case
		
		// Fetch headers and download any files that need downloading
		$headerCheckUrlDataList = array_map(fn($i) => makeDataFromFileIndex_smiley($prefix, $pad, $i), range($start, $max));
		fetchHeadersOnlyMulti_inChunksWithDataList_downloadIfNeeded($headerCheckUrlDataList, $typeName);
		
		// Check local file before adding to list, so that if there's a load issue the update script still uses the current saved version
		setProgress('updating', [ 'message'=>"Generating list of all $typeName items" ]);
		
		$breakCount = 0; // quit early if enough 404s in a row
		for ($i = $start; $i <= $max; $i++) {
			$id = $prefix.str_pad($i, $pad, "0", STR_PAD_LEFT);
			setProgress('updating', [ 'message'=>"$typeName: $id", 'value'=>$i-$start+1, 'max'=>$max-$start ]);
			
			list('localFilePath' => $file, 'filenameLocal' => $filenameLocal) = makeDataFromFileIndex_smiley($prefix, $pad, $i);
		
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
	
	return $emojis;
}