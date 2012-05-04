<?php
include("multi_to_array.php");
function format_input($arr) {

	multi_to_array($arr, "alternative_title");

	multi_to_array($arr, "identifier");

	multi_to_array($arr, "isavailablevia");

	multi_to_array($arr, "spatialcoverage");

	multi_to_array($arr, "temporalcoverage");

	multi_to_array($arr, "creator");

	multi_to_array($arr, "rights");

	multi_to_array($arr, "isreferencedby");

	multi_to_array($arr, "haspart");

	multi_to_array($arr, "ispartof");

	multi_to_array($arr, "catalogueor");

	multi_to_array($arr, "relation");

	multi_to_array($arr, "plugin");

	multi_to_array($arr, "parameters");

	multi_to_array($arr, "oai_provider");

	multi_to_array($arr, "esc_subject");

	multi_to_array($arr, "lcsh_subject");

	multi_to_array($arr, "mesh_subject");

	dates_to_array($arr, "created");

	dates_to_array($arr, "date_contents_created");

	format_to_array($arr, "format");


	if($arr['coll_id']) {
		$arr['ma_collection_id'] = $arr['coll_id'];
	}

	return $arr;
}
?>
