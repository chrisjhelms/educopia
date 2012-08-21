<?php
include_once("mysql_includes.php");
include_once("update_item.php");
include_once("subjects.php");

function update_collection($arr) {	
	global $subjects;

	mysql_connect(dbhost, dbuser, dbpass);
	mysql_select_db(dbname);

	$coll_id = preg_replace("(\D)","", $arr["ma_collection_id"]);
	if (0) { 
		// print info without updating
		print_r($arr); 
	    print "coll_id `$coll_id`"; 
		// return $coll_id;
	}
		
	$query = "UPDATE collection ";
	$values = " SET ";

	$values .= " accrualpolicy = ";
	$values .= "'" . mysql_real_escape_string($arr['accrualpolicy']) . "', ";

	if($arr['extent']) {
		$values .= "extent = '";
		$values .= "" . intval($arr['extent']) . "' , ";
	}

	if($arr['provenance']) {
		$values .= "provenance = ";
		$values .= "'" . mysql_real_escape_string($arr['provenance']) . "', ";
	}

	if($arr['risk_factors']) {
		$values .= "risk_factors = ";
		$values .= "'" . mysql_real_escape_string($arr['risk_factors']) . "', ";
	}

    if (array_key_exists('accrualperiodicity', $arr) &&  $arr['accrualperiodicity']) {
		$values .= "accrualperiodicity = ";
		$values .= "'" . $arr['accrualperiodicity'] . "', ";
	}

	if($arr['accessrights']) {
		$values .= "accessrights = ";
		$values .= "'" . $arr['accessrights'] . "', ";
	}

	if($arr['riskrank']) {
		$values .= "riskrank = ";
		$values .= "'" . $arr['riskrank'] . "', ";
	}

	if($arr['manifestation']) {
	
		$value = "'false', ";
		$values .= "manifestation_access = ";
		foreach($arr['manifestation'] as $box) {
			if ($box == 'access') $value = "'true', ";
		}
		$values .= $value;
	
		$value = "'false', ";
		$values .= "manifestation_preservation = ";
		foreach($arr['manifestation'] as $box) {
			if ($box == 'preservation') $value = "'true', ";
		}
		$values .= $value;
	
		$value = "'false', ";
		$values .= "manifestation_replacement = ";
		foreach($arr['manifestation'] as $box) {
			if ($box == 'replacement') $value = "'true', ";
		}
		$values .= $value;
	
	}

	$values .= "catalogued_status_radio =";
	$values .= "'" . $arr['catalogued_status_radio'] . "', ";
	$values .= "catalogued_status_text =";
	$values .= "'" . mysql_real_escape_string($arr['catalogued_status_text']) . "', ";


	$values .= " id = " . $coll_id;
	$query .= $values . " WHERE id = " . $coll_id;

	$valid = true;

	mysql_log_query("BEGIN WORK");

	if(!mysql_log_query($query)) {
		$valid = false;
		echo mysql_error();
	}


	if(!update_list($arr, 'alternative_title', $coll_id)) {
		$valid = false;
	}

	if(!update_list($arr, 'identifier', $coll_id)) {
		$valid = false;
	}

	if(!update_list($arr, 'isavailablevia', $coll_id)) {
		$valid = false;
	}

	if(!update_list($arr, 'spatialcoverage', $coll_id)) {
		$valid = false;
	}

	if(!update_list($arr, 'temporalcoverage', $coll_id)) {
		$valid = false;
	}

	if(!update_list($arr, 'creator', $coll_id)) {
		$valid = false;
	}

	if(!update_list($arr, 'rights', $coll_id)) {
		$valid = false;
	}

	if(!update_list($arr, 'isreferencedby', $coll_id)) {
		$valid = false;
	}

	if(!update_list($arr, 'haspart', $coll_id)) {
		$valid = false;
	}

	if(!update_list($arr, 'ispartof', $coll_id)) {
		$valid = false;
	}

	if(!update_list($arr, 'catalogueor', $coll_id)) {
		$valid = false;
	}

	if(!update_list($arr, 'relation', $coll_id)) {
		$valid = false;
	}

	if(!update_list($arr, 'cache_assignments', $coll_id)) {
		$valid = false;
	}

	if(!update_list($arr, 'oai_provider', $coll_id)) {
		$valid = false;
	}

	if(!update_list($arr, 'esc_subject', $coll_id)) {
		$valid = false;
	}

	if(!update_list($arr, 'lcsh_subject', $coll_id)) {
		$valid = false;
	}

	if(!update_list($arr, 'mesh_subject', $coll_id)) {
		$valid = false;
	}

	if(!update_list($arr, 'publisher', $coll_id)) {
		$valid = false;
	}

	if(!update_list($arr, 'language', $coll_id)) {
		$valid = false;
	}

	if(!update_date_ranges($arr, 'created', $coll_id)) {
		$valid = false;
	}

	if(!update_date_ranges($arr, 'date_contents_created', $coll_id)) {
		$valid = false;
	}

	if(!update_format($arr, 'format', $coll_id)) {
		$valid = false;
	}

	if(!update_type($arr, 'type', $coll_id)) {
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
