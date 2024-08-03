<?php
require_once '../config.php'; // contains $PASTEBIN_DEV_KEY

$errors = array();
if(!array_key_exists('paste', $_POST)) { $errors[] = "Missing image base64 data"; }
if (count($errors) > 0) { http_response_code(400); echo implode(', ', $errors); return; }

$api_dev_key           = $PASTEBIN_DEV_KEY; // your api_developer_key
$api_paste_name        = '[Fewfre-A801-Tools] Share code'; // name or title of your paste
$api_paste_code        = $_POST['paste']; // your paste text
$api_paste_private     = '1'; // 0=public 1=unlisted 2=private
$api_paste_expire_date = urlencode($_POST['expire'] ?? '10M');
$api_paste_format      = 'php';
$api_user_key          = ''; // if an invalid or expired api_user_key is used, an error will spawn. If no api_user_key is used, a guest paste will be created
$api_paste_name        = urlencode($api_paste_name);
$api_paste_code        = urlencode($api_paste_code);

$url                   = 'https://pastebin.com/api/api_post.php';
$ch                    = curl_init($url);

curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, 'api_option=paste&api_user_key='.$api_user_key.'&api_paste_private='.$api_paste_private.'&api_paste_name='.$api_paste_name.'&api_paste_expire_date='.$api_paste_expire_date.'&api_paste_format='.$api_paste_format.'&api_dev_key='.$api_dev_key.'&api_paste_code='.$api_paste_code.'');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($ch, CURLOPT_VERBOSE, 1);
curl_setopt($ch, CURLOPT_NOBODY, 0);

$response = curl_exec($ch);
echo $response;