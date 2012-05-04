<?php
include_once('types.php');
include_once('utils.php');

function get_year($year) 
{
   if ($year == "") { 
      return "NULL"; 
   }
   return intval($year); 
}

function update_date_ranges($arr, $var, $coll_id) {
	if(!mysql_log_query("DELETE FROM $var WHERE collection_id = $coll_id")) {
		echo mysql_error();
		return false;
	}
	$query = "INSERT INTO $var (start_year, start_month, end_year, end_month, collection_id) VALUES (";
	
	$valid = true;
	if(!$arr[$var]) return true;
	foreach ($arr[$var] as $item) {
		$new_query = $query .  " " . 
                   get_year($item['start_year']) . ", " . 
                   $item['start_month'] .  ", " .
                   get_year($item['end_year']) .  ", " .
                   $item['end_month'];
		$new_query .= ", $coll_id)";
		if(!mysql_log_query($new_query)) {
			echo mysql_error();
		}
	}

	return $valid;
}

function update_list($arr, $var, $coll_id) {
	if(!mysql_log_query("DELETE FROM $var WHERE collection_id = $coll_id")) {
		echo mysql_error();
		return false;
	}

	$valid = true;

	if(!$arr[$var]) return true;
	$query = "INSERT INTO $var (value, collection_id) VALUES (";
	if($arr[$var] != '') {
		foreach ($arr[$var] as $item) {
			if(!mysql_log_query($query . "'" . mysql_real_escape_string($item) . "', $coll_id)")) {
				echo mysql_error();
				$valid = false;
			}
		}
	}

	return $valid;
	
}

function update_format($arr, $var, $coll_id) {
	if(!mysql_log_query("DELETE FROM $var WHERE collection_id = $coll_id")) {
		echo mysql_error();
		return false;
	}

	$valid = true;

	if(!$arr[$var]) return true;
	$query = "INSERT INTO $var (first, second, other, collection_id) VALUES (";
	if($arr[$var] != '') {
		foreach ($arr[$var] as $item) {
			if(!mysql_log_query($query . "'" . mysql_real_escape_string($item['top']) . "', '"
				. mysql_real_escape_string($item['second']) . "', '" . mysql_real_escape_string($item['text_other'])
				."', $coll_id)")) {
					echo mysql_error();
					$valid = false;
			}
		}
	}

	return $valid;
}

function update_type($arr, $var, $coll_id) {
	global $types;
	if(!mysql_log_query("DELETE FROM $var WHERE collection_id = $coll_id")) {
		echo mysql_error();
		return false;
	}

	if(!$arr[$var]) return true;
	$query = "INSERT INTO $var (";
	$values = "VALUES (";

	foreach ($types as $key => $type) {
		$query .= "$key, " . $key . "_count, ";
		if(in_array($key, $arr[$var])) {
			if(is_numeric($arr[$key])) {
				$values .= "'true', " . $arr[$key] . ", ";
			} else {
				$values .= "'true', 0 , ";
			}
		} else {
			$values .= "'false', 0 , ";
		}
	}
	$query .= "collection_id) ";
	$values .= "$coll_id)";
	if(!mysql_log_query($query . $values)) {
		mysql_error();
		return false;
	}
	return true;
}

?>

