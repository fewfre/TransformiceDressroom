<?php
if($_SERVER['REQUEST_METHOD'] === 'GET') {
?>

<form method="POST" onsubmit="(function(){ document.querySelector('button').disabled = true; document.querySelector('input').readonly = true; })()">
	<h2>Block people looking up my username!</h2>
	<input name="username" placeholder="TFM username here" />
	<button>Snooper no snooping!!</button>
	<p>Is your name in here by accident, or you want it removed? PM/ping fewfre (anyone in TFM discord can PM me).</p>
</form>

<?php
}
else if($_SERVER['REQUEST_METHOD'] === 'POST') {
	$username = $_POST["username"] ?? "";
	$username = strtolower($username);
	$username = trim($username);
	$goback = "<form method='GET'><button>Go Back</button></form>";
	if($username && preg_match("/^([a-z\d#+_])+$/i", $username)) {
		if(strpos($username, '#') === FALSE) { $username = "$username#0000"; }
		
		$blacklist = json_decode(file_get_contents("fetchlooknickname_blacklist.json"), true);
		
		if(in_array($username, $blacklist["list"])) {
			echo "User <code>$username</code> already in blacklist!$goback";
			exit;
		}
		
		$blacklist["list"][] = $username;
		file_put_contents("fetchlooknickname_blacklist.json", json_encode($blacklist));
		echo "User <code>$username</code> added to blacklist! You are safe from snoopers!$goback";
		exit;
	} else {
		echo "Please enter a valid username.$goback";
		exit;
	}
}