<?php
function downloadFileIfNewer($url, $file) {
	$resp = fetchUrlMetaData($url);
	if($resp['exists']) {
		ifUrlIsNewerThenDownloadToFile($url, $resp['lastModified'], $file);
	}
}

function ifUrlIsNewerThenDownloadToFile($url, $urlLastModified, $file) {
	if(checkIfUrlLastModifiedNewerThanFile($urlLastModified, $file)) {
		downloadUrlToFile($url, $file);
		return true;
	}
	return false;
}
function downloadUrlToFile($url, $file) { file_put_contents($file, fopen($url, 'r')); }
function checkIfUrlLastModifiedNewerThanFile($urlLastModified, $file) {
	$fileTime = getFileLastModifiedDateTime($file);
	return $fileTime ? $urlLastModified > $fileTime : true; // If file doesn't exist then url is newer
}
function getFileLastModifiedDateTime($file) {
	$timestamp = filemtime($file);
	return $timestamp ? new \DateTime("@$timestamp") : null;
}
function fetchUrlMetaData($url) {
	$h = fetchHeadersOnly($url);
	$statusCode = $h ? explode(" ", $h)[1] : 0;
	return [
		'exists' => $statusCode == 200 || $statusCode == 300,
		'statusCode' => $statusCode,
		'lastModified' => $h && isset($h['Last-Modified']) ? new \DateTime($h['Last-Modified']) : null,
	];
}
// OLD WAY - seems to be blocked for some reason
// function fetchHeadersOnly($url) {
// 	usleep(0.01 * 1000000); // hardcode a slight delay to prevent making requests to fast
// 	$context = stream_context_create([ 'http' => array('method' => 'HEAD') ]); // Fetch only head to make it faster and to be friendly to server
// 	return get_headers($url, true, $context);
// }
function fetchHeadersOnly($url) {
	$curl = curl_init();
	curl_setopt($curl, CURLOPT_URL, $url);
	curl_setopt($curl, CURLOPT_FILETIME, true);
	curl_setopt($curl, CURLOPT_NOBODY, true);
	curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($curl, CURLOPT_HEADER, true);
	$header = curl_exec($curl);
	$info = curl_getinfo($curl);
	curl_close($curl);
	return $header;
}

function setProgress($state, $data = array()) {
	$data['state'] = $state;
	$date_utc = new \DateTime("now", new \DateTimeZone("UTC"));
	$data['timestamp'] = $date_utc->format('Y-m-d\TH:i:s\Z');
	file_put_contents("progress.json", json_encode($data));
}