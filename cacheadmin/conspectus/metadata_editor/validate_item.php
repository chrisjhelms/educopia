<?php
include_once('types.php');
include_once('subjects.php');

function validate_date_ranges($arr, $var, $title) {
	if(!$arr[$var]) return "<item type=\"date_range\" name=\"$var\" title=\"$title\"/>\n";
	return "";
}

function validate_single_text($arr, $var, $title) {
	if(!$arr[$var]) return "<item type=\"text\" name=\"$var\" title=\"$title\"/>\n";
	return "";
}

function validate_catalogued_status($arr, $var, $title) {
	if($arr[$var . "_radio"] == '') {
		return "<item type=\"catalogued_status\" name=\"$var\" title=\"$title\">Must Select Catalogued Status</item>\n";
	} /*else if ($arr[$var . "_text"] == '') {
		return "<item type=\"catalogued_status\" name=\"$var\" title=\"$title\">Must Describe Catalogued Status</item>\n";
	} */

	return "";
}

function validate_list($arr, $var, $title) {
	if(!$arr[$var]) return "<item type=\"list\" name=\"$var\" title=\"$title\"/>\n";
	return "";
}

function validate_format($arr, $var, $title) {
	if(!$arr[$var]) return "<item type=\"format\" name=\"$var\" title=\"$title\"/>\n";
	return "";
}

?>

