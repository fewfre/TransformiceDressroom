<?php
ini_set('display_errors', '1');
ini_set('display_startup_errors', '1');
error_reporting(E_ALL);

$errors = array();
if(!array_key_exists('sheet_base64', $_POST) && (!array_key_exists('sheet', $_FILES) || !$_FILES['sheet'] || !$_FILES['sheet']['tmp_name'])) {
	$addedWrong = array_key_exists('sheet', $_REQUEST) ? 'Yes' : 'No';
	$errors[] = "Missing sheet (detect as non-file: $addedWrong)";
}
if(!array_key_exists('width', $_POST)) {
	$errors[] = 'Missing width';
}
if(!array_key_exists('height', $_POST)) {
	$errors[] = 'Missing height';
}
if(!array_key_exists('framescount', $_POST)) {
	$errors[] = 'Missing framescount';
}
if(!array_key_exists('delay', $_POST)) {
	$errors[] = 'Missing delay';
}

// check if a file was uploaded
// NOTE: make sure form is set to: enctype="multipart/form-data"
if (count($errors) > 0) {
	http_response_code(400);
	echo implode(', ', $errors);
	return;
}

$frameWidth = $_POST['width'];
$frameHeight = $_POST['height'];
$framesCount = $_POST['framescount'];
$delay = $_POST['delay'];


$quality = 90;
$imageSheet = new Imagick();
// $imageSheet->setBackgroundColor('#6A7495'); // doesn't work
if(array_key_exists('sheet', $_FILES)) {
	$imageSheet->readImage($_FILES['sheet']['tmp_name']);
} else {
	$imageBlob = base64_decode($_POST['sheet_base64']);
	$imageSheet->readImageBlob($imageBlob);
}

// $framesCount = ceil($imageSheet->getImageWidth() / $frameWidth);
$columns = round($imageSheet->getImageWidth() / $frameWidth);
// $rows = round($imageSheet->getImageHeight() / $frameHeight);

$GIF = new Imagick();
$GIF->setFormat("gif");
$GIF->setSize($frameWidth, $frameHeight);
$GIF->setCompressionQuality($quality);

for ($i = 0; $i < $framesCount; $i++) {
	$frame = clone $imageSheet;

	// https://github.com/meiu/mpic/blob/76056767318f281c3819e5f2a70622bf44093b06/core/libs/img_engine/image_imagick.php
	$frame->cropImage($frameWidth, $frameHeight, ($i % $columns) * $frameWidth, floor($i / $columns) * $frameHeight);
	$frame->setImageDelay($delay);
	$frame->setImageCompressionQuality($quality);
	$GIF->addImage($frame);
	$GIF->setImagePage($frameWidth, $frameHeight, 0, 0);
	$GIF->setImageDispose(2);
}
// $GIF->optimizeImageLayers();
$GIF->coalesceImages();

// // https://stackoverflow.com/a/56041342
// // https://gist.github.com/thewhodidthis/ab790849666c5dc57b2d
// exec("convert {$_FILES['sheet']['tmp_name']} -crop $crop +adjoin +repage -adjoin -loop 0 -delay $delay *.png -layers OptimizePlus -layers OptimizeTransparency 2>&1", $output);

// return animated gif
header('Content-Type: image/gif');
echo $GIF->getImagesBlob();