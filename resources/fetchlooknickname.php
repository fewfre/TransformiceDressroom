<?php
header('Content-Type: application/json; charset=utf-8');

$nickname = $_GET["nickname"] ?? "";
$nickname = str_replace("#", "%23", $nickname);
$fetch = json_decode(get_content("https://cheese.formice.com/api/players/$nickname"), true);
if($fetch==null || isset($fetch["error"]) || !isset($fetch["shop"])) {
	die(json_encode([ 'error' => ($fetch["message"] ?? "##loading_error") ]));
}

$shop = $fetch["shop"];
$mouseColorHex = str_pad(dechex($shop["mouse_color"]), 6, "0", STR_PAD_LEFT);
$shamanColorHex = str_pad(dechex($shop["shaman_color"]), 6, "0", STR_PAD_LEFT);
// Setup data
$return = [
	'looks' => array_merge(
		["{$shop["look"]};$mouseColorHex;$shamanColorHex"],
		$shop["outfits"]
	)
];

// Return Data
echo json_encode($return);

function get_content($URL){
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($ch, CURLOPT_URL, $URL);
	$data = curl_exec($ch);
	curl_close($ch);
	return $data;
}