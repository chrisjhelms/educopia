<?php
include_once('types.php');
include_once('subjects.php');

function xml_escapes($str) {
	
	$str = htmlspecialchars($str);
	return $str;
}

function generate_date_ranges($arr, $var, $tag) {
	$r_value = "";
	if(!$arr[$var]) return " ";
	foreach ($arr[$var] as $date_item) {
		$r_value .= "<$tag>"; 
		$r_value .= $date_item["start_year"];
		if($date_item["start_month"]) {
			$r_value .= "-" . $date_item["start_month"];
		}
		$r_value .= "/";
		if($date_item["end_year"] != '') {
			$r_value .= $date_item["end_year"];
			if($date_item["end_month"]) {
				$r_value .= "-" . $date_item["end_month"];
			}
		}
		$r_value .= "</$tag>\n";
	}

	return $r_value;
}

function generate_subject($arr, $var, $tag) {
	$r_value = '';

	if(!$arr[$var]) return " ";
	foreach ($arr[$var] as $item) {
		$r_value .= "<dc:subject><$tag><rdf:value>" . xml_escapes($item) .
			"</rdf:value></$tag></dc:subject>\n";
	}

	return $r_value;
}

function generate_esc_subject($arr, $var, $tag) {
	global $subjects;
	$r_value = '';

	if(!$arr[$var]) return " ";
	foreach ($arr[$var] as $item) {
		$r_value .= "<dc:subject><$tag><rdf:value>" . xml_escapes($subjects[$item]) .
			"</rdf:value></$tag></dc:subject>\n";
	}

	return $r_value;
}

function generate_single_text($arr, $var, $tag) {
	$r_value = '';

	if($arr[$var] != '') {
		$r_value .= "<$tag>" . xml_escapes($arr[$var]) . "</$tag>\n";
	}

	return $r_value;
}

function generate_catalogued_status($arr, $var, $tag) {
	$r_value = '';
	
	if($arr[$var . "_radio"] != '') {
		$r_value .= "<$tag>" . $arr[$var . "_radio"] . " : " . 
			htmlspecialchars($arr[$var . "_text"]) . "</$tag>\n";
	} else if ($arr[$var . "_text"] != '') {
		$r_value .= "<$tag>not catalogued : " . 
			htmlspecialchars($arr[$var . "_text"]) . "</$tag>\n";
	}

	return $r_value;
}

function generate_list($arr, $var, $tag) {
	$r_value = '';

	if($arr[$var] != '') {
		foreach ($arr[$var] as $item) {
			$r_value .= "<$tag>" . xml_escapes($item) .
				"</$tag>\n";
		}
	}

	return $r_value;
}

function generate_format($arr, $var, $tag) {
	$r_value = '';

	if(!$arr[$var]) return " ";
	foreach ($arr[$var] as $format) {
		$r_value .= "<$tag>";
		if($format['second'] == 'Other...') {
			$r_value .= $format['top'] . "/" . xml_escapes($format["text_other"]);
		} else {
			$r_value .= $format['top'] . "/" . $format['second'];
		}
		$r_value .= "</$tag>\n";
	}

	return $r_value;
}

function generate_type($arr, $var, $tag) {
	global $types;
	$r_value = '';

	if ($arr[$var]) {
		foreach ($arr[$var] as $type) {
			$r_value .= "<$tag>" . $types[$type] . " " . $arr[$type]
				. "</$tag>\n";
		}
	}

	return $r_value;
}

?>
