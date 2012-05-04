<?php
include_once('types.php');

function unescape_sequence($str) {
	$str = stripslashes($str);
	return $str;
}

function fetch_date_ranges($var, $coll_id) {
	$query = "SELECT start_year, start_month, end_year, end_month FROM $var WHERE collection_id = $coll_id";

	$r_value = array();

	$result = mysql_log_query($query);
	while($item = mysql_fetch_assoc($result)) {
		$r_value[] = array('start_year' => $item['start_year'],
			'start_month' => $item['start_month'],
			'end_year' => $item['end_year'],
			'end_month' => $item['end_month']);
	}

	return $r_value;
}

function fetch_list($var, $coll_id) {
	$query = "SELECT value FROM $var WHERE collection_id = $coll_id";

	$r_value = array();

	$result = mysql_log_query($query);
	while($item = mysql_fetch_assoc($result)) {
		$r_value[] = unescape_sequence($item['value']);
	}

	return $r_value;
}

function fetch_format($var, $coll_id) {
	$query = "SELECT first, second, other FROM $var WHERE collection_id = $coll_id";

	$r_value = array();

	$result = mysql_log_query($query);
	while($item = mysql_fetch_assoc($result)) {
		$r_value[] = array('top' => unescape_sequence($item['first']),
			'second' => unescape_sequence($item['second']),
			'text_other' => unescape_sequence($item['other']));
	}

	return $r_value;

}

function fetch_type($var, $coll_id) {
	global $types;
	
	$query = "SELECT * from $var WHERE collection_id = $coll_id"; 
	$result = mysql_log_query($query);
	$arr = mysql_fetch_assoc($result);
	$my_types = array();
	$values = array();
	foreach ($types as $key => $type) {
		if($arr[$key] == 'true') {
			$my_types[] = $key;
			$values[$key] = $arr[$key . "_count"];
		} else {
			$values[$key] = 0;
		}
	}

	return array('types' => $my_types, 'values' => $values);
}

?>
