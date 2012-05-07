<?php
header("Content-type: text/xml");
echo "<?xml version=\"1.0\"?>\n";
echo "<?xml-stylesheet href=\"show_all.xsl\" type=\"text/xsl\" ?>\n";

include_once('types.php');
include_once('generate_rdf.php');
include_once('fetch_data.php');
include_once("mysql_includes.php");

mysql_connect(dbhost, dbuser, dbpass);
mysql_select_db(dbname);

$result = mysql_query("SELECT id FROM collection WHERE public = 'false' ORDER BY id ASC");

$collections = array();

while ($coll_data = mysql_fetch_assoc($result)) {
	$collections[] = fetch_collection($coll_data['id']);
}

echo generate_rdf_multiple($collections);

?>
