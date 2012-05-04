<?php
include_once("mysql_includes.php");
include_once("insert_item.php");
include_once("subjects.php");
include_once("utils.php");

function insert_collection($arr) {
	global $subjects;

        log_msg("insert_collection"); 
	mysql_connect(dbhost, dbuser, dbpass);
	mysql_select_db(dbname);

	$query = "INSERT INTO collection ";
	$items = "(";
	$values = "VALUES (";


	$items .= "collection_title, ";
	$values .= "'" . mysql_real_escape_string($arr['collection_title']) . "', ";

	$items .= "about, ";
	$values .= "'" . mysql_real_escape_string($arr['about']) . "', ";

	$items .= "accrualpolicy, ";
	$values .= "'" . mysql_real_escape_string($arr['accrualpolicy']) . "', ";

	if($arr['extent']) {
		$items .= "extent, ";
		$values .= preg_replace("(\D)", "", $arr['extent']) . ", ";
	}

	if($arr['collection_desc']) {
		$items .= "collection_desc, ";
		$values .= "'" . mysql_real_escape_string($arr['collection_desc']) . "', ";
	}

	if($arr['provenance']) {
		$items .= "provenance, ";
		$values .= "'" . mysql_real_escape_string($arr['provenance']) . "', ";
	}

	if($arr['risk_factors']) {
		$items .= "risk_factors, ";
		$values .= "'" . mysql_real_escape_string($arr['risk_factors']) . "', ";
	}

	if($arr['accrualperiodicity']) {
		$items .= "accrualperiodicity, ";
		$values .= "'" . $arr['accrualperiodicity'] . "', ";
	}

	if($arr['accessrights']) {
		$items .= "accessrights, ";
		$values .= "'" . $arr['accessrights'] . "', ";
	}

	if($arr['harvestproc']) {
		$items .= "harvestproc, ";
		$values .= "'" . $arr['harvestproc'] . "', ";
	}

	if($arr['riskrank']) {
		$items .= "riskrank, ";
		$values .= "'" . $arr['riskrank'] . "', ";
	}

	if($arr['manifestation']) {
	
		$value = "'false', ";
		$items .= "manifestation_access, ";
		foreach($arr['manifestation'] as $box) {
			if ($box == 'access') $value = "'true', ";
		}
		$values .= $value;
	
		$value = "'false', ";
		$items .= "manifestation_preservation, ";
		foreach($arr['manifestation'] as $box) {
			if ($box == 'preservation') $value = "'true', ";
		}
		$values .= $value;
	
		$value = "'false', ";
		$items .= "manifestation_replacement, ";
		foreach($arr['manifestation'] as $box) {
			if ($box == 'replacement') $value = "'true', ";
		}
		$values .= $value;
	
	}

	$items .= "catalogued_status_radio, catalogued_status_text, ";
	$values .= "'" . $arr['catalogued_status_radio'] . "', ";
	$values .= "'" . mysql_real_escape_string($arr['catalogued_status_text']) . "', ";


	$items .= "id) ";
	$values .= "0) ";
	$query .= $items . $values;

	log_msg("insert_data: extent: " . $values); 
	$valid = true;

	mysql_log_query("BEGIN WORK");

	if(!mysql_log_query($query)) {
		$valid = false;
		echo mysql_error();
	}
	$coll_id = mysql_insert_id();
	

	if(!insert_list($arr, 'alternative_title', $coll_id)) {
		$valid = false;
	}

	if(!insert_list($arr, 'identifier', $coll_id)) {
		$valid = false;
	}

	if(!insert_list($arr, 'isavailablevia', $coll_id)) {
		$valid = false;
	}

	if(!insert_list($arr, 'spatialcoverage', $coll_id)) {
		$valid = false;
	}

	if(!insert_list($arr, 'temporalcoverage', $coll_id)) {
		$valid = false;
	}

	if(!insert_list($arr, 'creator', $coll_id)) {
		$valid = false;
	}

	if(!insert_list($arr, 'rights', $coll_id)) {
		$valid = false;
	}

	if(!insert_list($arr, 'isreferencedby', $coll_id)) {
		$valid = false;
	}

	if(!insert_list($arr, 'haspart', $coll_id)) {
		$valid = false;
	}

	if(!insert_list($arr, 'ispartof', $coll_id)) {
		$valid = false;
	}

	if(!insert_list($arr, 'catalogueor', $coll_id)) {
		$valid = false;
	}

	if(!insert_list($arr, 'relation', $coll_id)) {
		$valid = false;
	}

	if(!insert_list($arr, 'plugin', $coll_id)) {
		$valid = false;
	}

	if(!insert_list($arr, 'parameters', $coll_id)) {
		$valid = false;
	}

	if(!insert_list($arr, 'manifest', $coll_id)) {
		$valid = false;
	}

	if(!insert_list($arr, 'oai_provider', $coll_id)) {
		$valid = false;
	}

	if(!insert_list($arr, 'esc_subject', $coll_id)) {
		$valid = false;
	}

	if(!insert_list($arr, 'lcsh_subject', $coll_id)) {
		$valid = false;
	}

	if(!insert_list($arr, 'mesh_subject', $coll_id)) {
		$valid = false;
	}

	if(!insert_list($arr, 'publisher', $coll_id)) {
		$valid = false;
	}

	if(!insert_list($arr, 'language', $coll_id)) {
		$valid = false;
	}

	if(!insert_date_ranges($arr, 'created', $coll_id)) {
		$valid = false;
	}

	if(!insert_date_ranges($arr, 'date_contents_created', $coll_id)) {
		$valid = false;
	}

	if(!insert_format($arr, 'format', $coll_id)) {
		$valid = false;
	}

	if(!insert_type($arr, 'type', $coll_id)) {
		$valid = false;
	}


	if(!$valid) {
		echo "<b>Something went wrong.  Data not submitted</b>";
		mysql_log_query("ROLLBACK");
	} else {
		mysql_log_query("COMMIT");
	}
	
	return $coll_id;
}

?>
