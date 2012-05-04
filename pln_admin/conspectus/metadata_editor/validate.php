<?php
include("validate_item.php");
function validate($arr) {
	$valid = true;
	$r_value = "<missing>\n";

	
	$r_value .= "\n<!--Descriptive Data-->\n";
	
	$test = validate_single_text($arr,'collection_title','Collection Title');
	$r_value .= $test;
	if($test != '') $valid = false;

	$test = validate_single_text($arr,'collection_desc','Description');
	$r_value .= $test;
	if($test != '') $valid = false;

	$test = validate_list($arr,'esc_subject','ESC Subjects');
	$r_value .= $test;
	if($test != '') $valid = false;

	$r_value .= "\n<!--URIs-->\n";
	
	$r_value .= "\n<!--Coverage-->\n";
	
	$r_value .= "\n<!--Accrual Information-->\n";
	
	$r_value .= "\n<!--Data Description-->\n";
	
	$test = validate_format($arr,'format','Format');
	$r_value .= $test;
	if($test != '') $valid = false;

	$test = validate_single_text($arr,'extent','Extent');
	$r_value .= $test;
	if($test != '') $valid = false;

	$r_value .= "\n<!--Rights and Ownership-->\n";
	
	$test = validate_list($arr,'creator','Creator');
	$r_value .= $test;
	if($test != '') $valid = false;

	$test = validate_list($arr,'publisher','Publisher');
	$r_value .= $test;
	if($test != '') $valid = false;

	$test = validate_list($arr,'rights','Rights');
	$r_value .= $test;
	if($test != '') $valid = false;

	$test = validate_single_text($arr,'accessrights','Access Rights');
	$r_value .= $test;
	if($test != '') $valid = false;

	$r_value .= "\n<!--Related Resources-->\n";
	
	$test = validate_catalogued_status($arr,'catalogued_status','Catalogued Status');
	$r_value .= $test;
	if($test != '') $valid = false;

	$r_value .= "\n<!--Harvesting Information-->\n";
	
	$test = validate_single_text($arr,'harvestproc','Harvest Procedure');
	$r_value .= $test;
	if($test != '') $valid = false;

	$test = validate_list($arr,'plugin','Plugin Identifier');
	$r_value .= $test;
	if($test != '') $valid = false;

	$test = validate_single_text($arr,'riskrank','Risk Rank');
	$r_value .= $test;
	if($test != '') $valid = false;


	$r_value .= "</missing>\n";
	if($valid) return "<valid />\n";
	return $r_value;
}

function is_valid($arr) {
	return validate($arr) == "<valid />\n";
}
