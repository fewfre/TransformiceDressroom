<?php
// Client ID of Imgur App 
$IMGUR_CLIENT_ID = "c62a11c2af9173b"; 
 
ini_set('display_errors', '1');
ini_set('display_startup_errors', '1');
error_reporting(E_ALL);

$errors = array();
if(!array_key_exists('base64', $_POST)) {
	$errors[] = "Missing image base64 data";
}

if (count($errors) > 0) {
	http_response_code(400);
	echo implode(', ', $errors);
	return;
}
 
// Post image to Imgur via API
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'https://api.imgur.com/3/image');
curl_setopt($ch, CURLOPT_POST, TRUE);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
curl_setopt($ch, CURLOPT_HTTPHEADER, array('Authorization: Client-ID ' . $IMGUR_CLIENT_ID));
curl_setopt($ch, CURLOPT_POSTFIELDS, array('image' => $_POST['base64']));
$response = curl_exec($ch);
curl_close($ch);

// JSON string response: https://apidocs.imgur.com/#c85c9dfc-7487-4de2-9ecd-66f727cf3139
echo $response;