<?php
require_once 'utils.php';

define('PRICE_IN_CHEESE_KEY', 'Price in cheese');
define('PRICE_IN_FRAISES_KEY', 'Price in fraises');

///////////////////////////////////
// #region Helpers
///////////////////////////////////

function curlWikiPageApi($page) {
	$url = "https://transformice.fandom.com/api.php?action=parse&page={$page}&format=json&prop=text&disabletoc=1";
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36');
	$response = curl_exec($ch);
	if (curl_errno($ch)) {
		setProgress('error', ['message' => 'Failed to fetch wiki data: ' . curl_error($ch)]);
		exit;
	}
	curl_close($ch);
	return $response;
}

function getHtmlXPathFromWikiResponse($response, $dom) {
	$data = json_decode($response, true);
	if (!$data || !isset($data['parse']['text']['*'])) {
		setProgress('error', ['message' => 'Invalid API response']);
		exit;
	}

	$html = $data['parse']['text']['*'];
	
	@$dom->loadHTML($html);
	return new DOMXPath($dom);
}

function getAndParseJsonFile($filePath) {
	if (!file_exists($filePath)) {
		setProgress('error', ['message' => 'JSON file not found']);
		exit;
	}

	$itemInfo = json_decode(file_get_contents($filePath), true);
	if ($itemInfo === null) {
		setProgress('error', ['message' => 'Invalid JSON file']);
		exit;
	}
	return $itemInfo;
}

function parseTable($xpath, $table) {
	$returnDataList = [];

	// Get header row (assuming first row is header)
	$headerRow = $xpath->query('.//tr[1]', $table)->item(0);
	if (!$headerRow) return $returnDataList;

	$headerCells = $xpath->query('.//th | .//td', $headerRow); // In case headers are td
	$columns = [];
	foreach ($headerCells as $cell) {
		$colspan = $cell->getAttribute('colspan') ?: 1;
		$colspan = intval($colspan);
		$text = trim($cell->textContent);
		for ($i = 0; $i < $colspan; $i++) {
			$columns[] = $text;
		}
	}

	// Parse data rows
	$rows = $xpath->query('.//tr[position() > 1]', $table);
	foreach ($rows as $row) {
		$cells = $xpath->query('.//td', $row);
		if ($cells->length == 0) continue;

		$rowData = [];
		$cellIndex = 0;
		foreach ($cells as $cell) {
			$colspan = $cell->getAttribute('colspan') ?: 1;
			$colspan = intval($colspan);
			$text = trim($cell->textContent);
			for ($i = 0; $i < $colspan; $i++) {
				if (isset($columns[$cellIndex])) {
					$rowData[$columns[$cellIndex]] = $text;
				}
				$cellIndex++;
			}
		}

		$returnDataList[] = $rowData;
		// // Use ID as key if available
		// if (isset($rowData['ID'])) {
		// 	$returnDataList[$rowData['ID']] = $rowData;
		// } else {
		// 	$returnDataList[] = $rowData; // Fallback to numeric index
		// }
	}

	return $returnDataList;
}

function &addNewArrayToAssocIfNeeded(array &$parent, $key) {
	if (!isset($parent[$key])) {
		$parent[$key] = [];
	}
	return $parent[$key];
}

function containsText($haystack, $needle) { return strpos($haystack, $needle) !== false; }
function cellToSimpleNumber($cell) { return str_replace(',', '', $cell); }

function isCheeseOnly($cheesePriceCell, $fraisePriceCell) {
	$cheesePrice = trim($cheesePriceCell);
	$strawberryPrice = trim($fraisePriceCell);
	$cheesePriceNormalized = cellToSimpleNumber($cheesePrice);
	return is_numeric($cheesePriceNormalized) && $strawberryPrice === "∅";
}
function isAlwaysInShop($cheesePriceCell, $fraisePriceCell) {
	$cheesePrice = cellToSimpleNumber(trim($cheesePriceCell));
	$fraisePrice = cellToSimpleNumber(trim($fraisePriceCell));
	return is_numeric($cheesePrice) || is_numeric($fraisePrice);
}
function coinShopType($priceText) {
	$priceText = strtolower($priceText);
	if(containsText($priceText, "from oracle")) return "starcoin-shaman";
	if(containsText($priceText, "from buffy")) return "starcoin-racing";
	if(containsText($priceText, "from von drekkemaus")) return "starcoin-survivor";
	if(containsText($priceText, "from cassidy")) return "starcoin-bootcamp";
	if(containsText($priceText, "from delphilante")) return "starcoin-defilante";
	return null;
}
function isEventReward($priceText) { $priceText = strtolower($priceText); return containsText($priceText, "event") || containsText($priceText, "japan") || containsText($priceText, "attend"); }
function isCollector($priceText) { $priceText = strtolower($priceText); return containsText($priceText, "collector"); }

function applyPriceFlags(&$data, $cheesePriceCell, $fraisePriceCell) {
	$ptype = isCheeseOnly($cheesePriceCell, $fraisePriceCell) ? "cheeseOnly" :
	        (isAlwaysInShop($cheesePriceCell, $fraisePriceCell) ? "alwaysInShop" :
	        (isCollector($cheesePriceCell) ? "collector" :
	        (isEventReward($cheesePriceCell) ? "eventReward" : null)));
	if(coinShopType($cheesePriceCell)) $ptype = coinShopType($cheesePriceCell);
	if($ptype) $data['ptype'] = $ptype;
}

///////////////////////////////////
// #region Pages
///////////////////////////////////

function doFurs($dom, &$itemInfoFileJson) {
	$pageName = 'Shop/Fur';
	$itemCategoryName = 'Fur';
	$itemInfoKey = 'skin';
	setProgress('updating', [ 'message'=>"Fetching and parsing: $itemCategoryName data" ]);
	// Fetch the costume data from the wiki
	$response = curlWikiPageApi($pageName);
	$xpath = getHtmlXPathFromWikiResponse($response, $dom);

	// Find the table with costume data
	$fursTable = parseTable($xpath, $xpath->query("//table[contains(@class, 'wikitable') and contains(@class, 'sortable')]")->item(0));
	$costumesTable = parseTable($xpath, $xpath->query("//table[contains(@id, 'costumes-table')]")->item(0));
	$purchasableCostumesTable = parseTable($xpath, $xpath->query("//table[contains(@id, 'costumes-also-purchasable-table')]")->item(0));

	if (empty($fursTable) || empty($costumesTable) || empty($purchasableCostumesTable)) {
		setProgress('error', ['message' => "No $itemCategoryName data found on wiki"]);
		exit;
	}

	if (empty($fursTable[1]['ID'])) {
		setProgress('error', ['message' => "IDs not found on wiki $itemCategoryName page - main furs table"]);
		exit;
	}
	if (empty($costumesTable[1]['ID']) && empty($costumesTable[1]['Fur ID'])) {
		setProgress('error', ['message' => "IDs not found on wiki $itemCategoryName page - costumes tables"]);
		exit;
	}
	if (empty($purchasableCostumesTable[1]['ID']) && empty($purchasableCostumesTable[1]['Fur ID'])) {
		setProgress('error', ['message' => "IDs not found on wiki $itemCategoryName page - purchasable costumes table"]);
		exit;
	}
	
	$infoDb =& addNewArrayToAssocIfNeeded($itemInfoFileJson, $itemInfoKey);
	
	// Loop through and remove existing flags since we want them to be up-to-date and should be reset below
	foreach ($infoDb as &$data) {
		unset($data['isCostume']);
		unset($data['ptype']);
	}
	
	// Loop through normal furs first
	foreach ($fursTable as $row) {
		if ($id = $row['ID'] ?? null) {
			$data =& addNewArrayToAssocIfNeeded($infoDb, $id); // Ensure the fur entry exists and keep reference
			applyPriceFlags($data, $row[PRICE_IN_CHEESE_KEY], $row[PRICE_IN_FRAISES_KEY]);
		}
	}
	
	// Shop fur colors a bit of special case
	for($i = 0; $i <= 6; $i++) {
		$id = "color$i";
		$data =& addNewArrayToAssocIfNeeded($infoDb, $id); // Ensure the costume entry exists and keep reference
		$data['ptype'] = "alwaysInShop"; // All fur colors are are buyable in shop
	}
	
	foreach ($costumesTable as $row) {
		if ($id = $row['ID'] ?? $row['Fur ID'] ?? null) {
			$data =& addNewArrayToAssocIfNeeded($infoDb, $id); // Ensure the costume entry exists and keep reference
			if (!isset($data['isCostume'])) {
				$data['isCostume'] = true;
			}
		}
	}
	
	foreach ($purchasableCostumesTable as $row) {
		if ($id = $row['ID'] ?? $row['Fur ID'] ?? null) {
			$data =& addNewArrayToAssocIfNeeded($infoDb, $id); // Ensure the costume entry exists and keep reference
			if (!isset($data['isCostume'])) {
				$data['isCostume'] = "both";
			}
		}
	}
}

function doStandardItemType($dom, $pageName, $itemCategoryName, &$itemInfoFileJson, $itemInfoKey, $tableSelector = "//table[contains(@class, 'wikitable') and contains(@class, 'sortable')]") {
	setProgress('updating', [ 'message'=>"Fetching and parsing: $itemCategoryName data" ]);
	// Fetch the data from the wiki
	$response = curlWikiPageApi($pageName);
	$xpath = getHtmlXPathFromWikiResponse($response, $dom);
	
	$itemsTable = parseTable($xpath, $xpath->query($tableSelector)->item(0));

	if (empty($itemsTable)) {
		setProgress('error', ['message' => "No $itemCategoryName data found on wiki"]);
		exit;
	}

	if (empty($itemsTable[1]['ID'])) {
		setProgress('error', ['message' => "IDs not found on wiki $itemCategoryName page"]);
		exit;
	}
	
	$infoDb =& addNewArrayToAssocIfNeeded($itemInfoFileJson, $itemInfoKey);
	
	// Loop through and remove existing flags since we want them to be up-to-date and should be reset below
	foreach ($infoDb as &$data) {
		unset($data['ptype']);
	}
	
	// Loop through wiki data
	foreach ($itemsTable as $row) {
		if ($id = $row['ID'] ?? null) {
			$data =& addNewArrayToAssocIfNeeded($infoDb, $id); // Ensure the costume entry exists and keep reference
			applyPriceFlags($data, $row[PRICE_IN_CHEESE_KEY], $row[PRICE_IN_FRAISES_KEY]);
		}
	}
}

///////////////////////////////////
// #region Main Script
///////////////////////////////////

$itemInfoUpdate_skipStartAndEndProgressUpdates = isset($itemInfoUpdate_skipStartAndEndProgressUpdates) ? $itemInfoUpdate_skipStartAndEndProgressUpdates : false;

if(!$itemInfoUpdate_skipStartAndEndProgressUpdates) {
	setProgress('starting');
}

$dom = new DOMDocument();
$itemInfoPath = '../item-info.json';
$itemInfo = getAndParseJsonFile($itemInfoPath);

// Handle individual pages
doFurs($dom, $itemInfo);
doStandardItemType($dom, 'Shop/Head', 'Head', $itemInfo, 'head');
doStandardItemType($dom, 'Shop/Ears', 'Ears', $itemInfo, 'ears');
doStandardItemType($dom, 'Shop/Eyes', 'Eyes', $itemInfo, 'eyes');
doStandardItemType($dom, 'Shop/Mouth', 'Mouth', $itemInfo, 'mouth');
doStandardItemType($dom, 'Shop/Neck', 'Neck', $itemInfo, 'neck');
doStandardItemType($dom, 'Shop/Tail', 'Tail', $itemInfo, 'tail');
doStandardItemType($dom, 'Shop/Hair_style', 'Hair Style', $itemInfo, 'hair');
doStandardItemType($dom, 'Shop/Contact_lenses', 'Contact Lenses', $itemInfo, 'contacts');
doStandardItemType($dom, 'Shop/Tattoo', 'Tattoo', $itemInfo, 'tattoo');
doStandardItemType($dom, 'Shop/Hands', 'Hands', $itemInfo, 'hands');
doStandardItemType($dom, 'Emoji', 'Emoji', $itemInfo, 'emoji', "//table[contains(@id, 'emoji-shop-table')]");

// Special cases
addNewArrayToAssocIfNeeded($itemInfo['head'], '198')['ptype'] = "collector";
addNewArrayToAssocIfNeeded($itemInfo['head'], '95')['ptype'] = "freeish";
addNewArrayToAssocIfNeeded($itemInfo['ears'], '9')['ptype'] = "freeish";
addNewArrayToAssocIfNeeded($itemInfo['mouth'], '19')['ptype'] = "freeish";

foreach ($itemInfo as $type => &$itemTypeMap) {
	$itemTypeMap = array_filter($itemTypeMap, function($value) { return !empty($value); });
}

// Save updated item-info.json
file_put_contents($itemInfoPath, json_encode($itemInfo));

if(!$itemInfoUpdate_skipStartAndEndProgressUpdates) {
	setProgress('completed');
	echo "Item info updated successfully!";

	sleep(10);
	setProgress('idle');
}