<?php
ini_set('display_errors', '1');
ini_set('display_startup_errors', '1');
error_reporting(E_ALL);

ini_set('max_execution_time', 5*60);
set_time_limit(5*60);

function setProgress($state, $data = array()) {
	$data['state'] = $state;
	$date_utc = new \DateTime("now", new \DateTimeZone("UTC"));
	$data['timestamp'] = $date_utc->format('Y-m-d\TH:i:s\Z');
	file_put_contents("progress.json", json_encode($data));
}

function getConfigJson() { return json_decode(file_get_contents("../config.json"), true); }
function saveConfigJson($json) {
	$json["cachebreaker"] = time();//md5(time(), true);
	file_put_contents("../config.json", json_encode($json)); //, JSON_PRETTY_PRINT
}

function ADD_LOG($msg) {
	$filename = "log.json";
	$json = array();
	if(is_file($filename)){
		$json = json_decode(file_get_contents($filename), true);
	}
	$json[] = $msg;
	file_put_contents($filename, json_encode($json, JSON_PRETTY_PRINT));
}
function LOG_PING($hostname='www.transformice.com') {
	function ping($host, $port, $timeout) { $tB = microtime(true); $fP = fSockOpen($host, $port, $errno, $errstr, $timeout); if (!$fP) { return "down"; } $tA = microtime(true); return round((($tA - $tB) * 1000), 0)." ms"; }
	ADD_LOG( ping($hostname, 80, 100) );
}

// function runPhpFileAsync($phpFileName, $args="") {
// 	$host = SCRIPT_HOST;
// 	$url = "$host/$phpFileName.php$args";
// 	// ADD_LOG("NEXT FILE: $url");
	
// 	// This script doesn't care about what happens in the next script, so this says for anything calling script to stop listening
// 	ignore_user_abort(true);
// 	session_write_close();
// 	// fastcgi_finish_request(); // This function flushes all response data to the client and finishes the request. This allows for time consuming tasks to be performed without leaving the connection to the client open
	
// 	// system("php $phpFileName.php &"); -- "Warning: system() has been disabled for security reasons"
	
// 	// this will set the minimum time to wait before proceed to the next line to 1 second - https://stackoverflow.com/a/64619098
// 	// Same reason as above; we don't want this script to continue running; we don't care about any response
// 	// $ctx = stream_context_create(['http'=> ['timeout' => 1]]);
// 	// file_get_contents($url, false, $ctx);
	
// 	// https://stackoverflow.com/a/64619098
// 	$curl = curl_init();
// 	//this will set the minimum time to wait before proceed to the next line to 100 milliseconds
// 	curl_setopt_array($curl,[CURLOPT_URL=>$url,CURLOPT_TIMEOUT_MS=>100,CURLOPT_RETURNTRANSFER=>TRUE]);
// 	curl_exec($curl);
// 	if (curl_errno($curl)) {
// 		$error_msg = curl_error($curl);
// 		ADD_LOG("ERROR: $error_msg");
// 	}
// 	//this line will be executed after 100 milliseconds
// 	curl_close ($curl); 
// 	// ADD_LOG("Closed; next file was: $url");
// }

/////////////////////////////
// Curl related helpers
/////////////////////////////
function downloadFileIfNewer($url, $file) { downloadFileIfHeadersAreNewer($url, $file, fetchHeadersOnly($url)); }
function downloadFileIfHeadersAreNewer($url, $file, $fancyHeaders) {
	if($fancyHeaders['exists'] && $fancyHeaders['lastModified']) {
		if(checkIfUrlLastModifiedNewerThanFile($fancyHeaders['lastModified'], $file)) {
			downloadUrlToFile($url, $file);
			return true;
		}
	}
	return false;
}
function checkIfUrlLastModifiedNewerThanFile($urlLastModified, $file) {
	if(!filesize($file)) return true; // If file we're replacing has a file size of zero just replace it, file ages don't matter
	$fileTime = getFileLastModifiedDateTime($file);
	return $fileTime ? $urlLastModified > $fileTime : true; // If file doesn't exist then url is newer
}
function getFileLastModifiedDateTime($file) {
	if(!file_exists($file)) return null;
	$timestamp = filemtime($file);
	return $timestamp ? new \DateTime("@$timestamp") : null;
}
// function downloadUrlToFile($url, $file) { file_put_contents($file, fopen($url, 'r')); }
function downloadUrlToFile($url, $file) { curlPutFileContents($url, $file); }
function curlPutFileContents($url, $file) {
	$fileTemp = "$file.temp";
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, $url); // Url to download
	$fp = fopen($fileTemp, 'w');
	curl_setopt($ch, CURLOPT_FILE, $fp); // where to save it
	curl_exec ($ch);
	if (curl_errno($ch)) {
		$error_msg = curl_error($ch);
		ADD_LOG("[curlPutFileContents] URL: $url -- $error_msg");
	} else {
		if(!!filesize($fileTemp)) {
			rename($fileTemp, $file);
		} else {
			ADD_LOG("[curlPutFileContents] URL: $url -- File size was zero!");
			unlink($fileTemp);
		}
	}
	curl_close ($ch);
	fclose($fp);
}
// Note: Status is at [0] since it has no associated header name
// HTTP/1.1 200 OK\r\nContent-Length: 1050186\r\nLast-Modified: Thu, 17 Feb 2022 11:00:04 GMT\r\n\r\n
// becomes = [ [0] => "HTTP/1.1 200 OK", ["Content-Length"] => "1050186", ["Last-Modified"] => Thu, 17 Feb 2022 11:00:04 GMT ]
function parseHeadersStringIntoAssoc($headersString) {
	$headerStrings = explode("\r\n", $headersString);
	$headers = array();
	foreach ($headerStrings as $str) {
		if(!$str) continue;
		$parts = explode(': ', $str, 2);
		if(count($parts) === 1) {
			$headers[] = $str;
		} else {
			$headers[$parts[0]] = $parts[1];
		}
	}
	return $headers;
}
/**
 * @return array{ exists:bool, statusCode:int, lastModified:DateTime|null, fileSize:int }
 */
function makeFancyHeaderAssocFromNormalHeaderAssoc($headersAssoc) {
	if(!$headersAssoc) return [ 'exists' => false, 'statusCode' => 0, 'lastModified' => null ];
	$statusStr = $headersAssoc[0] ?? null; // String in format of: "HTTP/1.1 200 OK"
	$lastModifiedStr = $headersAssoc['Last-Modified'] ?? null;
	$fileSizeStr = $headersAssoc['Content-Length'] ?? null;
	
	$statusCode = $statusStr ? (int)explode(" ", $statusStr)[1] : 0;
	return [
		'exists' => $statusCode == 200 || $statusCode == 300,
		'statusCode' => $statusCode,
		'lastModified' => $lastModifiedStr ? new \DateTime($lastModifiedStr) : null,
		'fileSize' => $fileSizeStr ? (int)$fileSizeStr : 0,
	];
}
function fetchHeadersOnly($url) {
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_FILETIME, true);
	curl_setopt($ch, CURLOPT_NOBODY, true);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_HEADER, true);
	$header = curl_exec($ch);
	// $info = curl_getinfo($ch);
	if (curl_errno($ch)) {
		$error_msg = curl_error($ch);
		ADD_LOG("[fetchHeadersOnly] URL: $url -- $error_msg");
	}
	curl_close($ch);
	return makeFancyHeaderAssocFromNormalHeaderAssoc( parseHeadersStringIntoAssoc($header) );
}
function fetchHeadersOnlyMulti($urls) {
	$mh = curl_multi_init(); // build the multi-curl handle
	$handles = array();
	foreach($urls as $url) {
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, $url);
		curl_setopt($ch, CURLOPT_FILETIME, true);
		curl_setopt($ch, CURLOPT_NOBODY, true);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_HEADER, true);
		$handles[] = $ch;
		curl_multi_add_handle($mh, $ch); // Add all $ch to the multi handle
	}
	
	// execute all queries simultaneously, and continue when all are complete
	$running = null;
	do {
		curl_multi_exec($mh, $running);
	} while ($running);

	//close the handles
	$headersMulti = array();
	foreach ($handles as $ch) {
		$response = curl_multi_getcontent($ch);
		if($response) {
			$headersMulti[] = makeFancyHeaderAssocFromNormalHeaderAssoc( parseHeadersStringIntoAssoc($response) );
		} else {
			$headersMulti[] = null;
		}
		curl_multi_remove_handle($mh, $ch);
	}
	curl_multi_close($mh);
	return $headersMulti;
}
/**
 * While not the most efficient, this works by passing in a list off url data in the full range we want to check, even if most at the end are duds.
 * However, since this checks them in chunks, any extras in the later chunks will be ignored
 * @param array{ url:string, ... } $listOfUrlsWithData
 * @return array{ array{ url:string, headers:FancyHeaders, ... } }
 */
function fetchHeadersOnlyMulti_inChunksWithDataList($listOfUrlsWithData, $progressTopic, $chunkSize=32, $breakMax=5) {
	$chunksOfUrlData = array_chunk($listOfUrlsWithData, $chunkSize); $chunksOfUrlDataLength = count($chunksOfUrlData);
	
	$dataList = array();
	$breakCount = 0; // quit early if enough 404s in a row
	for ($coudI=0; $coudI < $chunksOfUrlDataLength; $coudI++) { 
		setProgress('updating', [ 'message'=>"Fetching file headers for $progressTopic: [Chunk] $coudI, [Chunk Size] $chunkSize", "value" => $coudI+1, "max" => $chunksOfUrlDataLength ]);
		$chunkedDataList = $chunksOfUrlData[$coudI];
		
		$urls = array_map(fn($data) => $data['url'], $chunkedDataList);
		$chunkHeadersList = fetchHeadersOnlyMulti($urls);
		
		$len = min(count($chunkedDataList), count($chunkHeadersList));
		for ($i = 0; $i < $len; $i++) {
			$data = $chunkedDataList[$i];
			$data['headers'] = $chunkHeadersList[$i];
			
			if($chunkHeadersList[$i] && $chunkHeadersList[$i]['exists']) {
				$dataList[] = $data;
				$breakCount = 0;
			} else {
				$breakCount++;
				if($breakCount > $breakMax) { break; }
			}
		}
		if($breakCount > $breakMax) { break; }
	}
	
	return $dataList;
}
/**
 * While not the most efficient, this works by passing in a list off url data in the full range we want to check, even if most at the end are duds.
 * However, since this checks them in chunks, any extras in the later chunks will be ignored
 * @param array{ url:string, filename:string, localFilePath:string, ... } $listOfUrlsWithData
 * @return array{ array{ url:string, filename:string, localFilePath:string, headers:FancyHeaders, ... } }
 */
function fetchHeadersOnlyMulti_inChunksWithDataList_downloadIfNeeded($listOfUrlsWithData, $progressTopic, $chunkSize=32, $breakMax=5) {
	$dataList = fetchHeadersOnlyMulti_inChunksWithDataList($listOfUrlsWithData, $progressTopic, $chunkSize, $breakMax);
	// loop through returned headers and download the missing ones / ones that have been updated
	foreach ($dataList as $data) {
		setProgress('updating', [ 'message'=>"Downloading $progressTopic file if needed: {$data['filename']}" ]);
		downloadFileIfHeadersAreNewer($data['url'], $data['localFilePath'], $data['headers']);
	}
	return $dataList;
}