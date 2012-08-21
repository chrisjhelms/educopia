<?php

function multi_to_array(&$arr, $var) {
	$new_array = array();

	if (! array_key_exists( $var, $arr)) return null; 
	if (!$arr[$var]) return null;
	$items = preg_split(",", $arr[$var]);
	foreach ($items as $item) {
		$new_array[] = $arr[$item];
		unset($arr[$item]);
	}

	$arr[$var] = $new_array;
}

function multi_check_to_array(&$arr, $var) {
	$new_array = array();

	if (!$arr[$var]) return null;
	$items = preg_split(",", $arr[$var]);
	foreach ($items as $item) {
		$new_array[$item] = $arr[$item];
		unset($arr[$item]);
	}
	$arr[$var] = $new_array;
	
}

function dates_to_array(&$arr, $var) {
	$new_array = array();

	if (!$arr[$var]) return null;
	$items = preg_split(",", $arr[$var]);
	foreach ($items as $item) {
		$new_array[] = array(
			'start_year' => $arr[$item . "_start_year"],
			'end_year' => $arr[$item . "_end_year"],
			'start_month' => $arr[$item . "_start_month"],
			'end_month' => $arr[$item . "_end_month"],
		);
		unset($arr[$item . "_start_year"]);
		unset($arr[$item . "_end_year"]);
		unset($arr[$item . "_start_month"]);
		unset($arr[$item . "_end_month"]);
	}

	$arr[$var] = $new_array;
}

function format_to_array(&$arr, $var) {
	$new_array = array();

	if (!$arr[$var]) return null;
	$items = preg_split(",", $arr[$var]);
	foreach ($items as $item) {
		$new_array[] = array(
			'top' => $arr[$item],
			'second' => $arr[$item . "_" . $arr[$item]],
			'text_other' => $arr[$item . "_text_other"]
		);
		unset($arr[$item]);
		unset($arr[$item . "_application"]);
		unset($arr[$item . "_audio"]);
		unset($arr[$item . "_image"]);
		unset($arr[$item . "_text"]);
		unset($arr[$item . "_video"]);
		unset($arr[$item . "_text_other"]);
	}

	$arr[$var] = $new_array;
}

?>
