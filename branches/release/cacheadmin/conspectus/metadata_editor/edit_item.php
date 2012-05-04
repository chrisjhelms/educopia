<?php
include_once('types.php');
include_once('months.php');
include_once('mimetypes.php');

function edit_date_ranges(&$arr, $var) {
	global $months;
	$r_value = "";

	$field_count = 0;
	$temp_text = "";
	$field_names = "";
	foreach($arr[$var] as $date_range) {
		$current_name = $var . $field_count;
		$temp_text .= '<div id="' . $current_name . '">';
		$temp_text .= 'Start:';
		$temp_text .= '<input type="text" name="' . $current_name 
			. '_start_year" size="10" value="'. 
			$date_range['start_year'] . '" />' ."\n";
		$temp_text .= '<select name="' . $current_name . '_start_month">';
		foreach($months as $value => $month) {
			$month_val = $value % 13;
			if($date_range['start_month'] == $month_val) {
				$temp_text .= '<option value="' . 
					$month_val . '" selected="selected">';
			} else {
				$temp_text .= '<option value="' . $month_val . '">';
			}
			$temp_text .= $month;
			$temp_text .= "</option>\n";
		}
		$temp_text .= "</select>";
		$temp_text .= '<br />End:';
		$temp_text .= '<input type="text" name="' . $current_name 
			. '_end_year" size="10" value="'. $date_range['end_year'] 
			. '" />' ."\n";
		$temp_text .= '<select name="' . $current_name . '_end_month">';
		foreach($months as $value => $month) {
			$month_val = $value % 13;
			if($date_range['end_month'] == $month_val) {
				$temp_text .= '<option value="' . $month_val 
					. '" selected="selected">';
			} else {
				$temp_text .= '<option value="' . $month_val . '">';
			}
			$temp_text .= $month;
			$temp_text .= "</option>\n";
		}
		$temp_text .= "</select><br />\n";
		$temp_text .= '<a href="javascript: remove_elem(\'' .
			$var . '\', \'' . $current_name
			. '\');">Remove</a>';
		$temp_text .= "</div>\n";
		if($field_count == 0) {
			$field_names .= $current_name;
		} else {
			$field_names .= ",$current_name";
		}
		$field_count++;
	}
	$r_value .= '<a id="' . $var . 
		'-add" href="javascript:initiate_date_field(\'' .
		$var . '\',' . $field_count . ');">Add</a>';
	$r_value .= '<input type="hidden" name="' .
		$var . '" id="' . $var . '" value ="' . $field_names
		. '" />' . $temp_text;

	return $r_value;
}

function edit_subject($arr, $var, $tag) {
	$r_value = '';

	foreach ($arr[$var] as $item) {
		$r_value .= "<dc:subject><$tag><rdf:value>" . $item .
			"</rdf:value></$tag></dc:subject>\n";
	}

	return $r_value;
}

function edit_single_text(&$arr, $var) {
	$r_value = '';
	$r_value .= '<input type="text" size="50" id="' . 
		$var . '" name="' . $var . '" value="' .
		htmlspecialchars($arr[$var]) . '"/>' . "\n";

	return $r_value;
}

function edit_text_area(&$arr, $var) {
	$r_value = '';
	
	$r_value .= '<textarea cols="50" rows="6" id="' . 
		$var . '" name="' . $var . '">' .
		htmlspecialchars($arr[$var]) . "</textarea>\n";

	return $r_value;
}

function edit_multi_text(&$arr, $var) {
	$r_value = '';
	
	$field_count = 0;
	$temp_text = "";
	$field_names = "";
	foreach($arr[$var] as $field_value) {
		$temp_text .= '<div id="' . $var . $field_count . "\">\n";
		$temp_text .= '<input type="text" size="50"' .
			' name="'. $var . $field_count . '" value="' .
		htmlspecialchars($field_value) . "\"/>\n";
		$temp_text .= '<a href="javascript: remove_elem(\'' . $var . 
			'\', \'' . $var . $field_count
			. '\');">Remove</a>' ."\n";
		$temp_text .= "</div>";
		if($field_count == 0) {
			$field_names .= $var . $field_count;
		} else {
			$field_names .= ',' . $var . $field_count;
		}
		$field_count++;
	}
	$r_value .= '<a id="' . $var . 
		'-add" href="javascript:initiate_multi_text_field(\'' .
		$var . '\',' . $field_count . ');">Add</a>';
	$r_value .= '<input type="hidden" name="' . $var 
		. '" id="' . $var . '" value ="' . $field_names
		. '" />' . $temp_text . "\n";

	return $r_value;
}

function edit_catalogued_status($arr, $var, $tag) {
	$r_value = '';
	
	if($arr[$var . "_radio"] != '') {
		$r_value .= "<$tag>" . $arr[$var . "_radio"] . " : " . 
			$arr[$var . "_text"] . "</$tag>\n";
	}

	return $r_value;
}


function edit_list($arr, $var, $tag) {
	$r_value = '';

	if($arr[$var] != '') {
		foreach ($arr[$var] as $item) {
			$r_value .= "<$tag>" . $item .
				"</$tag>\n";
		}
	}

	return $r_value;
}

function edit_format(&$arr, $var) {
	global $mimetypes;
	$r_value = '';

	$field_count = 0;
	$temp_text = "";
	$field_names = "";
	foreach($arr[$var] as $format_block) {
		$current_name = $var . $field_count;
		$temp_text .= '<div id="' . $current_name . '_div">';
		$sub_selects = "";
		$temp_text .= '<select name="' . $current_name .
			'" id="' . $current_name . 
			'" onchange="javascript:changemimefield(\'' .
			$current_name . "')\">\n";
		foreach ($mimetypes as $key => $subtypes) {
			if($format_block['top'] == $key) {
				$temp_text .= "<option selected=\"selected\">$key</option>\n";
			} else {
				$temp_text .= "<option>$key</option>\n";
			}
			$sub_name = $current_name . "_" . $key;
			$sub_selects .= '<select name="' . $sub_name .
				'" id="' . $sub_name . '" ' .
				'onchange="changemimesub(\''.
				$sub_name . '\', \'' .
				$current_name . '_text_other\')" ';
			if($format_block['top'] != $key) {
				$sub_selects .= 'style="display: none;" ';
			}
			$sub_selects .= ">\n";
			foreach($subtypes as $sub_type) {
				if($format_block['second'] == $sub_type) {
					$sub_selects .= "<option selected=\"selected\">$sub_type</option>\n";
				} else {
					$sub_selects .= "<option>$sub_type</option>\n";
				}
			}
			$sub_selects .= "</select>\n";
		}
		$temp_text .= "</select>\n" . $sub_selects;
		$temp_text .= '<br /><input type="text" name="' . $current_name . 
			'_text_other" id="' . $current_name . '_text_other" size="40" ';
		if($format_block['second'] == "Other...") {
			$temp_text .= 'value="' . htmlspecialchars($format_block['text_other'])
			. '" ' . " />\n";
		} else {
			$temp_text .= 'style="display: none;"' . "/>\n";
		}
		$temp_text .= '<a href="javascript: remove_elem_div(\''
			. $var . '\', \'' . $current_name
			. '\');">Remove</a></div>';
		if($field_count == 0) {
			$field_names .= $current_name;
		} else {
			$field_names .= ",$current_name";
		}
		$field_count++;
	}
	$r_value .= '<a id="' . $var . 
		'-add" href="javascript:initiate_mime_field(\''
		. $var .'\',' . $field_count . ');">Add</a>';
	$r_value .= '<input type="hidden" name="' . $var .
		'" id="' . $var . '" value ="' . $field_names
		. '" />' . $temp_text;

	return $r_value;
}

function edit_type_block($arr, $var) {
	global $types;
	$r_value = "<table>";

	foreach ($types as $type => $type_name) {
		$temp_name = $type;
		$r_value .= '<tr><td style="width:50%;">';
		$r_value .= '<input type="checkbox" name="' . $var .
			'[]" id="' . $temp_name . '" value="' . $temp_name;
		if(in_array($type, $arr[$var])) {
			$r_value .= '" checked="checked';
		}
		$r_value .= "\" />\n" . $type_name . "</td><td>";
		$r_value .= '<input type="text" style="width:98%" name="' .
			$temp_name . '" value="' . $arr[$type] . '" />';
		$r_value .= "</td></tr>\n";
	}
	$r_value .= "</table>";

	return $r_value;
}

?>

