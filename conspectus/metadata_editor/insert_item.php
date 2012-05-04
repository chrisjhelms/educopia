<?php
include_once('types.php');

function insert_date_ranges($arr, $var, $coll_id) {
	$query = "INSERT INTO $var (start_year, start_month, end_year, end_month, collection_id) VALUES (";
	
	$valid = true;
	if(!$arr[$var]) return true;
	foreach ($arr[$var] as $item) {
		$new_query = $query . 
			preg_replace("(\D)", "", $item['start_year'])
			. ", " .
			preg_replace("(\D)", "", $item['start_month'])
			. ", ";
		if($item['end_year'] != '') {
			$new_query .= 
				preg_replace("(\D)", "", $item['end_year'])
				. ", " .
				preg_replace("(\D)", "", $item['end_month']);
		} else {
			$new_query .= "NULL, NULL";
		}
		$new_query .= ", $coll_id)";
		if(!mysql_log_query($new_query)) {
			echo "<!-- insert date range: \n";
			print_r($arr[$var]);
			echo $new_query . "\n";
			echo mysql_error();
			echo "\n-->\n";
			$valid = false;
		}
	}

	return $valid;
}

function insert_list($arr, $var, $coll_id) {

	$valid = true;

	if(!$arr[$var]) return true;
	$query = "INSERT INTO $var (value, collection_id) VALUES (";
	if($arr[$var] != '') {
		foreach ($arr[$var] as $item) {
			$new_query = $query . "'" . mysql_real_escape_string($item) . "', $coll_id)";
			if(!mysql_log_query($new_query)) {
				echo "<!-- insert list: \n";
				print_r($arr[$var]);
				echo $new_query . "\n";
				echo mysql_error();
				echo "\n-->\n";
				$valid = false;
			}
		}
	}

	return $valid;
	
}

function insert_format($arr, $var, $coll_id) {
	$valid = true;

	if(!$arr[$var]) return true;
	$query = "INSERT INTO $var (first, second, other, collection_id) VALUES (";
	if($arr[$var] != '') {
		foreach ($arr[$var] as $item) {
			$new_query = $query . "'" . mysql_real_escape_string($item['top']) . "', '"
				. mysql_real_escape_string($item['second']) . "', '" . mysql_real_escape_string($item['text_other'])
			    ."', $coll_id)";
			if(!mysql_log_query($new_query)) {
					echo "<!-- insert format: \n";
					print_r($arr[$var]);
					echo $new_query . "\n";
					echo mysql_error();
					$valid = false;
					echo "\n-->\n";
			}
		}
	}

	return $valid;
}

function insert_type($arr, $var, $coll_id) {
	global $types;

	if(!$arr[$var]) return true;
	$query = "INSERT INTO $var (";
	$values = "VALUES (";

	foreach ($types as $key => $type) {
		$query .= "$key, " . $key . "_count, ";
		if(in_array($key, $arr[$var])) {
			if($arr[$key] && is_numeric($arr[$key])) {
				$values .= "'true', " . $arr[$key] . ", ";
			} else {
				$values .= "'true', 0 , ";
			}
		} else {
			$values .= "'false', " . 0 . ", ";
		}
	}
	$query .= "collection_id) ";
	$values .= "$coll_id)";
	if(!mysql_log_query($query . $values)) {
		echo "<!-- insert type: \n";
		print_r($arr[$var]);
		echo $query . $values . "\n";
		mysql_error();
		echo "\n-->\n";
		return false;
	}
	return true;
}

?>

