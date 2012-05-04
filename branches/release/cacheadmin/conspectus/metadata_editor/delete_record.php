<?php
	session_start();
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head><title>Delete Collection</title></title>
<body>
<?php

include_once("mysql_includes.php");
include_once('types.php');
include_once('generate_rdf.php');
include_once('fetch_data.php');
include_once('remove_data.php');

if(! $_SESSION['logged_in']) {
	echo "<h2>Must Be Logged In To Delete Records</h2>\n";
	echo "<a href=\"index.php\">Log In Here</a></body></html>\n";
	die();
}

if($_GET['confirm']) {
	remove_collection($_GET['collection']);
	echo "<h2>Done</h2>\n";
	echo "<a href=\"index.php\">Click Here To Return To Index</a>\n";
}
else if($_GET['collection']) {
	echo "<h2>Are You Sure You Want To Delete This Collection?</h2><hr/><pre>\n";

	$coll_id = $_GET['collection'];

	$coll_data = fetch_collection($coll_id);
	echo htmlspecialchars(generate_rdf($coll_data));
	echo "</pre><hr/>\n";
	echo "<a href=\"delete_record.php?collection=" .$_GET['collection'] .
		"&confirm=1\">Yes</a>\n";
	echo "<a href=\"index.php\">No</a>\n";
}

?>

</body>
</html>
