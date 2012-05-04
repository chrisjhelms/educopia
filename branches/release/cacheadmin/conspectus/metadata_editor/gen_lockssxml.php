<?php
header("Content-type: text/plain");

function parse_extra_parameters(&$parameters) {
   $parsed = array();
   foreach($parameters as $param) {
	   $param_list = array();
	   foreach (split(",",$param) as $param_item) {
		   $param_list[] = split("=",$param_item);
	   }
	   $parsed[] = $param_list;
   }
   return $parsed;
}


function generate_title(&$collections) {
echo "<property name=\"title\"> \n"; 
$v3AUs = array(18,95);

foreach ($collections as $coll) {
	$params = parse_extra_parameters($coll['parameters']);
	$au=0;
	if(!$params) {
		if (!$coll['plugin'][0] ) {
			$coll['plugin'][0] = "edu.orphan.plugin";
		}
		echo "<property name=\"metaarchive" . 
			htmlspecialchars($coll['ma_collection_id']) . "\">\n";
		echo "   <property name=\"title\" value=\"" . 
			htmlspecialchars($coll['collection_title']) . "\" />\n";
		echo "   <property name=\"journalTitle\" value=\"" .
			htmlspecialchars($coll['collection_title']) . "\" />\n";
		echo "   <property name=\"plugin\" value=\"" . 
			htmlspecialchars($coll['plugin'][0]) . "\" />\n";
		echo "   <property name=\"param.1\">\n";
		echo "      <property name=\"key\" value=\"base_url\" />\n";
		echo "      <property name=\"value\" value=\"" .
			htmlspecialchars($coll['about']) . "\" />\n";
		echo "   </property>\n";
		if(in_array($coll['ma_collection_id'],$v3AUs)) {
		   echo "   <property name=\"param.2\">\n";
		   echo "      <property name=\"key\" value=\"protocol_version\" />\n";
		   echo "      <property name=\"value\" value=\"3\" />\n";
		   echo "   </property>\n";
		}
		echo "</property>\n";
	} else foreach ($params as $param_list) {
		echo "<property name=\"metaarchive" . 
			htmlspecialchars($coll['ma_collection_id']) . "-$au" . "\">\n";
		echo "   <property name=\"title\" value=\"" . 
			htmlspecialchars($coll['collection_title']) . "-$au\" />\n";
		echo "   <property name=\"journalTitle\" value=\"" .
			htmlspecialchars($coll['collection_title']) . "\" />\n";
		echo "   <property name=\"plugin\" value=\"" . 
			htmlspecialchars($coll['plugin'][0]) . "\" />\n";
	
		if($param_list[0][0] != "base_url") {
			echo "   <property name=\"param.1\">\n";
			echo "      <property name=\"key\" value=\"base_url\" />\n";
			echo "      <property name=\"value\" value=\"" .
			htmlspecialchars($coll['about']) . "\" />\n";
			echo "   </property>\n";
			$i = 2;
		} else $i=1;
	
		foreach($param_list as $param_item) {
			echo "   <property name=\"param.$i\">\n";
			echo "      <property name=\"key\" value=\"" .
				htmlspecialchars($param_item[0]) . "\" />\n";
			echo "      <property name=\"value\" value=\"" .
				htmlspecialchars($param_item[1]) . "\" />\n";
			echo "   </property>\n";
			$i++;
		}
		
		if(in_array($coll['ma_collection_id'],$v3AUs)) {
			echo "   <property name=\"param.$i\">\n";
			echo "      <property name=\"key\" value=\"protocol_version\" />\n";
			echo "      <property name=\"value\" value=\"3\" />\n";
			echo "   </property>\n";
		}

		echo "</property>\n";
		$au++;
	}
}

echo "</property>\n\n\n"; 
}

include_once('trace.php');
include_once('types.php');
include_once('fetch_data.php');
include_once("mysql_includes.php");

mysql_connect(dbhost, dbuser, dbpass);
mysql_select_db(dbname);

$result = mysql_query("SELECT id FROM collection ORDER BY id ASC");

$collections = array();
$i = 0; 
while ($coll_data = mysql_fetch_assoc($result)) {
	$collections[] = fetch_collection($coll_data['id']);
   $i++; 
}


echo  "<lockss-config>"; 
generate_title($collections);
echo  "</lockss-config>"; 

?>
