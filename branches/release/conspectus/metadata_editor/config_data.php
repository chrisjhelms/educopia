<?php
header("Content-type: text/plain");

include_once('types.php');
include_once('fetch_data.php');
include_once("mysql_includes.php");

mysql_connect(dbhost, dbuser, dbpass);
mysql_select_db(dbname);

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


function generate_config_data(&$collections) {
echo <<<END
<if group="metaarchive">
<property name="titleSet">
<property name="alltitles">
<property name="class" value="alltitles" />
</property>
<property name="activeaus">
<property name="class" value="activeaus" />
</property>
<property name="inactiveaus">
<property name="class" value="inactiveaus" />
</property>

END;

$pubs = array(	"Emory" => array(), "Louisville" => array(), "FSU" => array(),
		"Auburn" => array(), "VATech" => array(), "GATech" => array());

foreach($collections as $coll) {
	$pub = $coll['publisher'][0];
	$plug = $coll['plugin'][0];
	$pubs[$pub][] = $plug;
}

foreach($pubs as $key => $value) {
	if(sizeof($value) > 0) {
		echo "<property name=\"$key\">\n";
		echo "<property name=\"name\" value=\"All $key Titles\" />\n";
		echo '<property name="class" value="xpath" />';
		echo "\n<property name=\"xpath\" value=\"[pluginName='" .
			$value[0] . "'";
		$temp_arr = array_slice($value,1);
		foreach($temp_arr as $plugin) {
		echo " or pluginName='$plugin'";
		}
		echo "]\" />\n</property>\n";
	}
}	

echo <<<END

</property>
</if>

<property name="title">
END;

generate_aus($collections); 

echo <<<END

</property>
END;
}

function generate_aus(&$collections) {
  $v3AUs = array(18,95);
  foreach ($collections as $coll) {
	$params = parse_extra_parameters($coll['parameters']);
	$au=0;
	if(!$params) {
		echo "<property name=\"metaarchive" . 
			htmlspecialchars($coll['ma_collection_id']) . "\">\n";
		echo "<property name=\"title\" value=\"" . 
			htmlspecialchars($coll['collection_title']) . "\" />\n";
		echo "<property name=\"journalTitle\" value=\"" .
			htmlspecialchars($coll['collection_title']) . "\" />\n";
		echo "<property name=\"plugin\" value=\"" . 
			htmlspecialchars($coll['plugin'][0]) . "\" />\n";
		echo "<property name=\"param.1\">\n";
		echo "<property name=\"key\" value=\"base_url\" />\n";
		echo "<property name=\"value\" value=\"" .
			htmlspecialchars($coll['about']) . "\" />\n";
		echo "</property>\n";
		if(in_array($coll['ma_collection_id'],$v3AUs)) {
		   echo "<property name=\"param.2\">\n";
		   echo "<property name=\"key\" value=\"protocol_version\" />\n";
		   echo "<property name=\"value\" value=\"3\" />\n";
		   echo "</property>\n";
		}
		echo "</property>\n";
	} else foreach ($params as $param_list) {
      $ps = ""; 
      if (sizeof($param_list > 0)) { 
   		foreach($param_list as $param_item) {
             if ($param_item[0] != "base_url2") { 
                $ps .= " $param_item[0]=$param_item[1]";
             } 
         }
         if ($ps != "") { 
             $ps = ":$ps";
         } 
      } 

		echo "<property name=\"metaarchive" . 
			htmlspecialchars($coll['ma_collection_id']) . "-$au" . "\">\n";
		echo "   <property name=\"title\" value=\"" . 
			htmlspecialchars($coll['collection_title']) . "$ps\" />\n";
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
}

$result = mysql_log_query("SELECT id FROM collection WHERE public = 'true' ORDER BY id ASC");

$collections = array();

while ($coll_data = mysql_fetch_assoc($result)) {
	$collections[] = fetch_collection($coll_data['id']);
}

if (array_key_exists('au_only', $_GET)) {
   generate_aus($collections);
} else { 
   generate_config_data($collections);
}

?>
