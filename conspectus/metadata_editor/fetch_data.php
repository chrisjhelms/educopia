<?php
include_once("mysql_includes.php");
include_once("fetch_item.php");
include_once("subjects.php");

function fetch_collection($coll_id) {
	global $subjects;
	
	$r_value = array();

	mysql_connect(dbhost, dbuser, dbpass);
	mysql_select_db(dbname);

	$query = "SELECT * FROM collection WHERE id = $coll_id";
	$result = mysql_log_query($query);
	if(mysql_num_rows($result) == 0) {
		echo "<error code=\"2\">Could not find collection $coll_id.</error>";
		die();
	}
	$arr = mysql_fetch_assoc($result);
	
	$r_value["ma_collection_id"] = $coll_id;


	$r_value["collection_title"] = 
		stripslashes($arr["collection_title"]);

	$r_value["about"] = 
		stripslashes($arr["about"]);

	$r_value["accrualpolicy"] = 
		stripslashes($arr["accrualpolicy"]);

	$r_value["extent"] = 
		$arr["extent"];

	$r_value["collection_desc"] = 
		stripslashes($arr["collection_desc"]);

	$r_value["provenance"] = 
		stripslashes($arr["provenance"]);

	$r_value["risk_factors"] = 
		stripslashes($arr["risk_factors"]);

	$r_value["accrualperiodicity"] = 
		$arr["accrualperiodicity"];

	$r_value["accessrights"] = 
		$arr["accessrights"];

	$r_value["harvestproc"] = 
		$arr["harvestproc"];

	$r_value["riskrank"] = 
		$arr["riskrank"];

	$check_array = array();
	
	if($arr["manifestation_access"] == 'true') {
		$check_array[] = "access";
	}
	
	if($arr["manifestation_preservation"] == 'true') {
		$check_array[] = "preservation";
	}
	
	if($arr["manifestation_replacement"] == 'true') {
		$check_array[] = "replacement";
	}
	
	$r_value["manifestation"] = $check_array;

	$r_value["catalogued_status_radio"] = 
		$arr["catalogued_status_radio"];
	$r_value["catalogued_status_text"] = 
		stripslashes($arr["catalogued_status_text"]);

	$r_value["alternative_title"] = 
		fetch_list('alternative_title', $coll_id);

	$r_value["identifier"] = 
		fetch_list('identifier', $coll_id);

	$r_value["isavailablevia"] = 
		fetch_list('isavailablevia', $coll_id);

	$r_value["spatialcoverage"] = 
		fetch_list('spatialcoverage', $coll_id);

	$r_value["temporalcoverage"] = 
		fetch_list('temporalcoverage', $coll_id);

	$r_value["creator"] = 
		fetch_list('creator', $coll_id);

	$r_value["rights"] = 
		fetch_list('rights', $coll_id);

	$r_value["isreferencedby"] = 
		fetch_list('isreferencedby', $coll_id);

	$r_value["haspart"] = 
		fetch_list('haspart', $coll_id);

	$r_value["ispartof"] = 
		fetch_list('ispartof', $coll_id);

	$r_value["catalogueor"] = 
		fetch_list('catalogueor', $coll_id);

	$r_value["relation"] = 
		fetch_list('relation', $coll_id);

	$r_value["plugin"] = 
		fetch_list('plugin', $coll_id);

	$r_value["parameters"] = 
		fetch_list('parameters', $coll_id);

	$r_value["cache_assignments"] = 
		fetch_list('cache_assignments', $coll_id);

	$r_value["oai_provider"] = 
		fetch_list('oai_provider', $coll_id);

	$r_value["esc_subject"] =
		fetch_list('esc_subject', $coll_id);

	$r_value["lcsh_subject"] =
		fetch_list('lcsh_subject', $coll_id);

	$r_value["mesh_subject"] =
		fetch_list('mesh_subject', $coll_id);

	$r_value["publisher"] = 
		fetch_list('publisher', $coll_id);

	$r_value["language"] = 
		fetch_list('language', $coll_id);

	$r_value["created"] =
		fetch_date_ranges('created', $coll_id);

	$r_value["date_contents_created"] =
		fetch_date_ranges('date_contents_created', $coll_id);

	$r_value["format"] = 
		fetch_format('format', $coll_id);
		
	$r_value["public"] = $arr['public']; 
	
	$temp_type = fetch_type('type', $coll_id);
	$r_value["type"] = $temp_type['types'];
	$r_value = array_merge($r_value, $temp_type['values']);


	return $r_value;
}

?>

