<?php
include_once("mysql_includes.php");
include_once("insert_item.php");
include_once("subjects.php");

function remove_collection($coll_id) {
	global $subjects;

	mysql_connect(dbhost, dbuser, dbpass);
	mysql_select_db(dbname);
	
	$query = "DELETE FROM collection WHERE id = " . $coll_id;
	if(!mysql_log_query($query)) {
		echo "<p>could not delete table!";
		echo mysql_error();
		echo "</p>\n";
	}


	$query = "DELETE FROM alternative_title WHERE collection_id = " . $coll_id;
	mysql_log_query($query);

	$query = "DELETE FROM identifier WHERE collection_id = " . $coll_id;
	mysql_log_query($query);

	$query = "DELETE FROM isavailablevia WHERE collection_id = " . $coll_id;
	mysql_log_query($query);

	$query = "DELETE FROM spatialcoverage WHERE collection_id = " . $coll_id;
	mysql_log_query($query);

	$query = "DELETE FROM temporalcoverage WHERE collection_id = " . $coll_id;
	mysql_log_query($query);

	$query = "DELETE FROM creator WHERE collection_id = " . $coll_id;
	mysql_log_query($query);

	$query = "DELETE FROM rights WHERE collection_id = " . $coll_id;
	mysql_log_query($query);

	$query = "DELETE FROM isreferencedby WHERE collection_id = " . $coll_id;
	mysql_log_query($query);

	$query = "DELETE FROM haspart WHERE collection_id = " . $coll_id;
	mysql_log_query($query);

	$query = "DELETE FROM ispartof WHERE collection_id = " . $coll_id;
	mysql_log_query($query);

	$query = "DELETE FROM catalogueor WHERE collection_id = " . $coll_id;
	mysql_log_query($query);

	$query = "DELETE FROM relation WHERE collection_id = " . $coll_id;
	mysql_log_query($query);

	$query = "DELETE FROM plugin WHERE collection_id = " . $coll_id;
	mysql_log_query($query);

	$query = "DELETE FROM parameters WHERE collection_id = " . $coll_id;
	mysql_log_query($query);

	$query = "DELETE FROM manifest WHERE collection_id = " . $coll_id;
	mysql_log_query($query);

	$query = "DELETE FROM oai_provider WHERE collection_id = " . $coll_id;
	mysql_log_query($query);

	$query = "DELETE FROM esc_subject WHERE collection_id = " . $coll_id;
	mysql_log_query($query);

	$query = "DELETE FROM lcsh_subject WHERE collection_id = " . $coll_id;
	mysql_log_query($query);

	$query = "DELETE FROM mesh_subject WHERE collection_id = " . $coll_id;
	mysql_log_query($query);

	$query = "DELETE FROM publisher WHERE collection_id = " . $coll_id;
	mysql_log_query($query);

	$query = "DELETE FROM language WHERE collection_id = " . $coll_id;
	mysql_log_query($query);

	$query = "DELETE FROM created WHERE collection_id = " . $coll_id;
	mysql_log_query($query);

	$query = "DELETE FROM date_contents_created WHERE collection_id = " . $coll_id;
	mysql_log_query($query);

	$query = "DELETE FROM format WHERE collection_id = " . $coll_id;
	mysql_log_query($query);

	$query = "DELETE FROM type WHERE collection_id = " . $coll_id;
	mysql_log_query($query);


}

?>
