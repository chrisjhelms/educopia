<?php
include("language_list.php");
include("subjects.php");
include("edit_item.php");
include("config.php");

function edit_rdf($arr, $title) {
	
global $languages;
global $subjects;
global $caches;
$r_value = "";
$r_value .= '<div class="form">';
$r_value .= '<form name="mainform" action="edit.php" method="post" id="mainform">';
	
$coll_id = $arr['ma_collection_id'];  
$r_value .= '<input type="hidden" name="coll_id" value="' . $arr["ma_collection_id"] . '" />';
$r_value .= '<input type="hidden" name="title" value="' . $title . '" />';

$r_value .= "<input type='hidden' name='coll_id' value=\"$coll_id\" />\n";
$r_value .= <<< END
<div class="section">
<div class="section_header">
<a class="plus" href="javascript:show_content('collection');" 
	id="collection-link" name="collection-link">+</a>
<span class="section_title">Descriptive Data</span>
<a href="javascript:unhidediv('collection-summary');">Summary</a>
</div>
<div id="collection-summary" class="summary" style="display:none;">
Details explaining the digital collection to be preserved.

</div>
<div id="collection-content" class="content" style="display:none;">
END;


$r_value .= <<< END
<table id="table_alternative_title" style="width:100%;">
<tr>
<td class="fieldname">Alternative Title
</td>
<td class="fielddata">
END;

	$r_value .= edit_multi_text($arr, "alternative_title");
	
$r_value .= <<< END
</td>
<td class="fielddescription">Other names of this collection
</td>
</tr>
</table>
END;

$r_value .= <<< END
<table id="table_esc_subject" style="width:100%;">
<tr>
<td class="fieldname">ESC Subjects
<br /><span class="required">Required</span>

</td>
<td class="fielddata">
END;

	$field_count = 0;
	$temp_text = "";
	$field_names = "";
	foreach($arr["esc_subject"] as $field_value) {
		$temp_text .= '<div class="type_selector" id="esc_subject' . $field_count . '_div">';
		$temp_text .= '<select name="esc_subject' . $field_count . '" id="esc_subject' . 
			$field_count . '">';
		foreach($subjects as $sub_name => $sub_title) {
			if($sub_name == $field_value) {
				$temp_text .= '<option value="' . $sub_name . '" selected="selected">';
			} else {
				$temp_text .= '<option value="' . $sub_name . '">';
			}
			$temp_text .= $sub_title . '</option>';
		}
		$temp_text .= "</select>\n";
		$temp_text .= '<a href="javascript: remove_elem_div(\'esc_subject\', \'esc_subject' . $field_count
			. '\');">Remove</a>';
		$temp_text .= "</div>\n";
		if($field_count == 0) {
			$field_names .= 'esc_subject' . $field_count;
		} else {
			$field_names .= ',esc_subject' . $field_count;
		}
		$field_count++;
	}
	$r_value .= '<a id="esc_subject-add" href="javascript:initiate_esc_field(\'esc_subject\',' . $field_count . ');">Add</a>';
	$r_value .= '<input type="hidden" name="esc_subject" id="esc_subject" value ="' . $field_names
		. '" />' . $temp_text;
	
$r_value .= <<< END
</td>
<td class="fielddescription">Describe this collection using terms from the Encyclopedia of Southern Culture
</td>
</tr>
</table>
END;


$r_value .= <<< END
<table id="table_lcsh_subject" style="width:100%;">
<tr>
<td class="fieldname">LCSH Subjects
</td>
<td class="fielddata">
END;

	$r_value .= edit_multi_text($arr, "lcsh_subject");
	
$r_value .= <<< END
</td>
<td class="fielddescription">Describe this collection using terms from the Library of Congress Subject Headings
</td>
</tr>
</table>
END;


$r_value .= <<< END
<table id="table_mesh_subject" style="width:100%;">
<tr>
<td class="fieldname">MESH Subjects
</td>
<td class="fielddata">
END;

	$r_value .= edit_multi_text($arr, "mesh_subject");
	
$r_value .= <<< END
</td>
<td class="fielddescription">Describe this collection using terms from the Medical Subject Headings
</td>
</tr>
</table>
END;


$r_value .= <<< END
</div>
</div>
END;

$r_value .= <<< END
<div class="section">
<div class="section_header">
<a class="plus" href="javascript:show_content('uris');" 
	id="uris-link" name="uris-link">+</a>
<span class="section_title">URIs</span>
<a href="javascript:unhidediv('uris-summary');">Summary</a>
</div>
<div id="uris-summary" class="summary" style="display:none;">
Uniform Resource Identifier--usually a locator (URL) or a name (URN).
</div>
<div id="uris-content" class="content" style="display:none;">
END;

$r_value .= <<< END
<table id="table_identifier" style="width:100%;">
<tr>
<td class="fieldname">Identifier
</td>
<td class="fielddata">
END;

	$r_value .= edit_multi_text($arr, "identifier");
	
$r_value .= <<< END
</td>
<td class="fielddescription">Institution assigned name and/or number for the digital collection
</td>
</tr>
</table>
END;


$r_value .= <<< END
<table id="table_isavailablevia" style="width:100%;">
<tr>
<td class="fieldname">Is available via
</td>
<td class="fielddata">
END;

	$r_value .= edit_multi_text($arr, "isavailablevia");
	
$r_value .= <<< END
</td>
<td class="fielddescription">URL where the collection is publicly available
</td>
</tr>
</table>
END;


$r_value .= <<< END
</div>
</div>
END;

$r_value .= <<< END
<div class="section">
<div class="section_header">
<a class="plus" href="javascript:show_content('coverage');" 
	id="coverage-link" name="coverage-link">+</a>
<span class="section_title">Coverage</span>
<a href="javascript:unhidediv('coverage-summary');">Summary</a>
</div>
<div id="coverage-summary" class="summary" style="display:none;">
Describe the collection in space and time

</div>
<div id="coverage-content" class="content" style="display:none;">
END;


$r_value .= <<< END
<table id="table_spatialcoverage" style="width:100%;">
<tr>
<td class="fieldname">Spatial Coverage
</td>
<td class="fielddata">
END;

	$r_value .= edit_multi_text($arr, "spatialcoverage");
	
$r_value .= <<< END
</td>
<td class="fielddescription">Place or areas associated with the contents of the digital collection
</td>
</tr>
</table>
END;


$r_value .= <<< END
<table id="table_temporalcoverage" style="width:100%;">
<tr>
<td class="fieldname">Temporal Coverage
</td>
<td class="fielddata">
END;

	$r_value .= edit_multi_text($arr, "temporalcoverage");
	
$r_value .= <<< END
</td>
<td class="fielddescription">Time periods associated with the contents of the digital
collection
</td>
</tr>
</table>
END;


$r_value .= <<< END
<table id="table_created" style="width:100%;">
<tr>
<td class="fieldname">Accumulation Date Range
</td>
<td class="fielddata">
END;

	$r_value .= edit_date_ranges($arr, "created");
	
$r_value .= <<< END
</td>
<td class="fielddescription">Span of dates during which the collection was assembled
</td>
</tr>
</table>
END;


$r_value .= <<< END
<table id="table_date_contents_created" style="width:100%;">
<tr>
<td class="fieldname">Contents Date Range
</td>
<td class="fielddata">
END;

	$r_value .= edit_date_ranges($arr, "date_contents_created");
	
$r_value .= <<< END
</td>
<td class="fielddescription">Dates of creation of the digital collection
</td>
</tr>
</table>
END;


$r_value .= <<< END
</div>
</div>
END;

$r_value .= <<< END
<div class="section">
<div class="section_header">
<a class="plus" href="javascript:show_content('accrual');" 
	id="accrual-link" name="accrual-link">+</a>
<span class="section_title">Accrual Information</span>
<a href="javascript:unhidediv('accrual-summary');">Summary</a>
</div>
<div id="accrual-summary" class="summary" style="display:none;">
Information relating to the accumulation of the collection
</div>
<div id="accrual-content" class="content" style="display:none;">
END;


$r_value .= <<< END
<table id="table_accrualperiodicity" style="width:100%;">
<tr>
<td class="fieldname">Accrual Periodicity
</td>
<td class="fielddata">
END;

	if($arr["accrualperiodicity"] == "no longer") {
		$r_value .= '<input type="radio" name="accrualperiodicity" value="no longer" checked="checked"/>';
	} else {
		$r_value .= '<input type="radio" name="accrualperiodicity" value="no longer" />';
	}
		
			$r_value .= 'No Longer Adding<br />';
		
	if($arr["accrualperiodicity"] == "daily") {
		$r_value .= '<input type="radio" name="accrualperiodicity" value="daily" checked="checked"/>';
	} else {
		$r_value .= '<input type="radio" name="accrualperiodicity" value="daily" />';
	}
		
			$r_value .= 'Daily<br />';
		
	if($arr["accrualperiodicity"] == "weekly") {
		$r_value .= '<input type="radio" name="accrualperiodicity" value="weekly" checked="checked"/>';
	} else {
		$r_value .= '<input type="radio" name="accrualperiodicity" value="weekly" />';
	}
		
			$r_value .= 'Weekly<br />';
		
	if($arr["accrualperiodicity"] == "monthly") {
		$r_value .= '<input type="radio" name="accrualperiodicity" value="monthly" checked="checked"/>';
	} else {
		$r_value .= '<input type="radio" name="accrualperiodicity" value="monthly" />';
	}
		
			$r_value .= 'Monthly<br />';
		
	if($arr["accrualperiodicity"] == "quarterly") {
		$r_value .= '<input type="radio" name="accrualperiodicity" value="quarterly" checked="checked"/>';
	} else {
		$r_value .= '<input type="radio" name="accrualperiodicity" value="quarterly" />';
	}
		
			$r_value .= 'Quarterly<br />';
		
	if($arr["accrualperiodicity"] == "semi-annually") {
		$r_value .= '<input type="radio" name="accrualperiodicity" value="semi-annually" checked="checked"/>';
	} else {
		$r_value .= '<input type="radio" name="accrualperiodicity" value="semi-annually" />';
	}
		
			$r_value .= 'Semi-annually<br />';

	if($arr["accrualperiodicity"] == "yearly") {
		$r_value .= '<input type="radio" name="accrualperiodicity" value="yearly" checked="checked"/>';
	} else {
		$r_value .= '<input type="radio" name="accrualperiodicity" value="yearly" />';
	}
		
			$r_value .= 'Yearly<br />';
		
	if($arr["accrualperiodicity"] == "occasionally") {
		$r_value .= '<input type="radio" name="accrualperiodicity" value="occasionally" checked="checked"/>';
	} else {
		$r_value .= '<input type="radio" name="accrualperiodicity" value="occasionally" />';
	}
		
			$r_value .= 'Occasionally<br />';

$r_value .= <<< END
</td>
<td class="fielddescription">Frequency with which items are added to a collection.
</td>
</tr>
</table>
END;


$r_value .= <<< END
<table id="table_accrualpolicy" style="width:100%;">
<tr>
<td class="fieldname">Accrual Policy
</td>
<td class="fielddata">
END;

	$r_value .= edit_single_text($arr, "accrualpolicy");
	
$r_value .= <<< END
</td>
<td class="fielddescription">Approach adopted to add items to the collection or a statement
about the anticipated growth of the collection.</td>
</tr>
</table>
END;


$r_value .= <<< END
</div>
</div>
END;

$r_value .= <<< END
<div class="section">
<div class="section_header">
<a class="plus" href="javascript:show_content('formatting_info');" 
	id="formatting_info-link" name="formatting_info-link">+</a>
<span class="section_title">Data Description</span>
<a href="javascript:unhidediv('formatting_info-summary');">Summary</a>
</div>
<div id="formatting_info-summary" class="summary" style="display:none;">
Formatting, size, and language information associated with the collection

</div>
<div id="formatting_info-content" class="content" style="display:none;">
END;


$r_value .= <<< END
<table id="table_format" style="width:100%;">
<tr>
<td class="fieldname">Format
<br /><span class="required">Required</span>

</td>
<td class="fielddata">
END;

	$r_value .= edit_format($arr, "format");
	
$r_value .= <<< END
</td>
<td class="fielddescription">Physical or digital characteristics of the files in the collection
</td>
</tr>
</table>
END;


$r_value .= <<< END
<table id="table_language" style="width:100%;">
<tr>
<td class="fieldname">Language
</td>
<td class="fielddata">
END;

	$r_value .= '<select id="language" name="language[]" size="10" multiple="multiple">';
	foreach($languages as $code => $lang) {
		if(in_array($code, $arr["language"])) {
			$r_value .= '<option value="' . $code . '" selected="selected">' . $lang . '</option>';
		} else {
			$r_value .= '<option value="' . $code . '">' . $lang . '</option>';
		}
	}
	$r_value .= '</select>';
	$r_value .= "<p>Hold down control to select multiple options</p>\n";
	
$r_value .= <<< END
</td>
<td class="fielddescription">Language of the content of the items in the collection
</td>
</tr>
</table>
END;


$r_value .= <<< END
<table id="table_type" style="width:100%;">
<tr>
<td class="fieldname">Type
</td>
<td class="fielddata">
END;

	$r_value .= edit_type_block($arr, "type");
	
$r_value .= <<< END
</td>
<td class="fielddescription">Nature or genre of the content in the collection
</td>
</tr>
</table>
END;


$r_value .= <<< END
<table id="table_extent" style="width:100%;">
<tr>
<td class="fieldname">Extent
<br /><span class="required">Required</span>

</td>
<td class="fielddata">
END;

	$r_value .= edit_single_text($arr, "extent");
	
$r_value .= <<< END
</td>
<td class="fielddescription"> Size  (as integer value) of the entire digital collection expressed in bytes
</td>
</tr>
</table>
END;


$r_value .= <<< END
</div>
</div>
END;

$r_value .= <<< END
<div class="section">
<div class="section_header">
<a class="plus" href="javascript:show_content('ownership');" 
	id="ownership-link" name="ownership-link">+</a>
<span class="section_title">Rights and Ownership</span>
<a href="javascript:unhidediv('ownership-summary');">Summary</a>
</div>
<div id="ownership-summary" class="summary" style="display:none;">
Description of the collections intellectual property and/or copyright
</div>
<div id="ownership-content" class="content" style="display:none;">
END;


$r_value .= <<< END
<table id="table_creator" style="width:100%;">
<tr>
<td class="fieldname">Creator
<br /><span class="required">Required</span>

</td>
<td class="fielddata">
END;

	$r_value .= edit_multi_text($arr, "creator");
	
$r_value .= <<< END
</td>
<td class="fielddescription">Originator of the content in the digital collection
</td>
</tr>
</table>
END;


$r_value .= <<< END
<table id="table_publisher" style="width:100%;">
<tr>
<td class="fieldname">Publisher
<br /><span class="required">Required</span>

</td>
<td class="fielddata">
END;

	$r_value .= '<select id="publisher" name="publisher[]" size="6" multiple="multiple">';
	
	if(in_array("Auburn", $arr["publisher"])) {
		$r_value .= '<option value="Auburn" selected="selected">';
	} else {
		$r_value .= '<option value="Auburn" >';
	}
	$r_value .= 'Auburn University</option>';

	if(in_array("Boston", $arr["publisher"])) {
		$r_value .= '<option value="Boston" selected="selected">';
	} else {
		$r_value .= '<option value="Boston" >';
	}
	$r_value .= 'Boston College</option>';
	
	if(in_array("Clemson", $arr["publisher"])) {
		$r_value .= '<option value="Clemson" selected="selected">';
	} else {
		$r_value .= '<option value="Clemson" >';
	}
	$r_value .= 'Clemson University</option>';
	
	if (in_array("CUBC", $arr["publisher"]))  {
		$r_value .= '<option value="CUBC" selected="selected">';
	 } else {
		$r_value .= '<option value="CUBC" >';
	}
	$r_value .= 'Consorci de Biblioteques Universitaries de Catalunya</option>';

	if (in_array("HBCU", $arr["publisher"]))  {
		$r_value .= '<option value="HBCU" selected="selected">';
	 } else {
		$r_value .= '<option value="HBCU" >';
	}
	$r_value .= 'Historically Black Colleges &amp; Universities</option>';

	if(in_array("Emory", $arr["publisher"])) {
		$r_value .= '<option value="Emory" selected="selected">';
	} else {
		$r_value .= '<option value="Emory" >';
	}
	$r_value .= 'Emory University</option>';
	
	if (in_array("HULL", $arr["publisher"]))  {
		$r_value .= '<option value="HULL" selected="selected">';
	 } else {
		$r_value .= '<option value="HULL" >';
	}
	$r_value .= 'Hull University</option>';
	if (in_array("OS", $arr["publisher"]))  {
		$r_value .= '<option value="OS" selected="selected">';
	 } else {
		$r_value .= '<option value="OS" >';
	}
	$r_value .= 'Oregon State University</option>';
	if (in_array("PSU", $arr["publisher"]))  {
		$r_value .= '<option value="PSU" selected="selected">';
	 } else {
		$r_value .= '<option value="PSU" >';
	}
	$r_value .= 'Penn State University</option>';
	if (in_array("PUC", $arr["publisher"]))  {
		$r_value .= '<option value="PUC" selected="selected">';
	 } else {
		$r_value .= '<option value="PUC" >';
	}
	$r_value .= 'Pontif&#xED;cia Universidade Cat&#xF3;lica</option>';
	if (in_array("HULL", $arr["publisher"]))  {
		$r_value .= '<option value="HULL" selected="selected">';
	 } else {
		$r_value .= '<option value="HULL" >';
	}
	$r_value .= 'University of Hull</option>';
	if (in_array("UNT", $arr["publisher"]))  {
		$r_value .= '<option value="UNT" selected="selected">';
	 } else {
		$r_value .= '<option value="UNT" >';
	}
	$r_value .= 'University of North Texas</option>';

	if(in_array("FSU", $arr["publisher"])) {
		$r_value .= '<option value="FSU" selected="selected">';
	} else {
		$r_value .= '<option value="FSU" >';
	}
	$r_value .= 'Florida State University</option>';

	if(in_array("GATech", $arr["publisher"])) {
		$r_value .= '<option value="GATech" selected="selected">';
	} else {
		$r_value .= '<option value="GATech" >';
	}
	$r_value .= 'Georgia Institute of Technology</option>';

	if(in_array("IndState", $arr["publisher"])) {
		$r_value .= '<option value="IndState" selected="selected">';
	} else {
		$r_value .= '<option value="IndState" >';
	}
	$r_value .= 'Indiana State University</option>';

	if(in_array("Folger", $arr["publisher"])) {
		$r_value .= '<option value="Folger" selected="selected">';
	} else {
		$r_value .= '<option value="Folger" >';
	}
	$r_value .= 'The Folger Library</option>';

	if(in_array("Hull", $arr["publisher"])) {
		$r_value .= '<option value="Hull" selected="selected">';
	} else {
		$r_value .= '<option value="Hull" >';
	}
	$r_value .= 'University of Hull</option>';
	
	if(in_array("Louisville", $arr["publisher"])) {
		$r_value .= '<option value="Louisville" selected="selected">';
	} else {
		$r_value .= '<option value="Louisville" >';
	}
	$r_value .= 'University of Louisville</option>';
	
	if(in_array("SCarolina", $arr["publisher"])) {
		$r_value .= '<option value="SCarolina" selected="selected">';
	} else {
		$r_value .= '<option value="SCarolina" >';
	}
	$r_value .= 'University of South Carolina</option>';
	
	if(in_array("Rice", $arr["publisher"])) {
		$r_value .= '<option value="Rice" selected="selected">';
	} else {
		$r_value .= '<option value="Rice" >';
	}
	$r_value .= 'Rice University</option>';

	
	if(in_array("VATech", $arr["publisher"])) {
		$r_value .= '<option value="VATech" selected="selected">';
	} else {
		$r_value .= '<option value="VATech" >';
	}
	$r_value .= 'Virginia Tech</option>';
	
	$r_value .= '</select>';
	$r_value .= "<p>Hold down control to select multiple options</p>\n";
	
$r_value .= <<< END
</td>
<td class="fielddescription">Entity responsible for making the resource available
</td>
</tr>
</table>
END;


$r_value .= <<< END
<table id="table_rights" style="width:100%;">
<tr>
<td class="fieldname">Rights
<br /><span class="required">Required</span>

</td>
<td class="fielddata">
END;

	$r_value .= edit_multi_text($arr, "rights");
	
$r_value .= <<< END
</td>
<td class="fielddescription">Statement of moral or legal entitlement to the digital collection
</td>
</tr>
</table>
END;


$r_value .= <<< END
<table id="table_accessrights" style="width:100%;">
<tr>
<td class="fieldname">Access Rights
<br /><span class="required">Required</span>

</td>
<td class="fielddata">
END;

	if($arr["accessrights"] == "unrestricted") {
		$r_value .= '<input type="radio" name="accessrights" value="unrestricted" checked="checked"/>';
	} else {
		$r_value .= '<input type="radio" name="accessrights" value="unrestricted" />';
	}
		
			$r_value .= 'Unrestricted<br />';
		
	if($arr["accessrights"] == "restricted") {
		$r_value .= '<input type="radio" name="accessrights" value="restricted" checked="checked"/>';
	} else {
		$r_value .= '<input type="radio" name="accessrights" value="restricted" />';
	}
		
			$r_value .= 'Restricted<br />';
		
$r_value .= <<< END
</td>
<td class="fielddescription">Statement of any restrictions on the collection, including allowed users, charges, etc.
</td>
</tr>
</table>
END;


$r_value .= <<< END
<table id="table_provenance" style="width:100%;">
<tr>
<td class="fieldname">Custodial History
</td>
<td class="fielddata">
END;

	$r_value .= edit_text_area($arr, "provenance");
	
$r_value .= <<< END
</td>
<td class="fielddescription">Provenance: statement about changes in ownership
and custody of the digital collection that are significant for its authenticity, integrity and interpretation
</td>
</tr>
</table>
END;


$r_value .= <<< END
<table id="table_manifestation" style="width:100%;">
<tr>
<td class="fieldname">Manifestation
</td>
<td class="fielddata">
END;

	if(in_array("access",$arr["manifestation"])) {
		$r_value .= '<input type="checkbox" name="manifestation[]" value="access" id="manifestation_access" checked="checked"/>';
	} else {
		$r_value .= '<input type="checkbox" name="manifestation[]" value="access" id="manifestation_access" />';
	}
	$r_value .= 'Access<br />';
	
	if(in_array("preservation",$arr["manifestation"])) {
		$r_value .= '<input type="checkbox" name="manifestation[]" value="preservation" id="manifestation_preservation" checked="checked"/>';
	} else {
		$r_value .= '<input type="checkbox" name="manifestation[]" value="preservation" id="manifestation_preservation" />';
	}
	$r_value .= 'Preservation<br />';
	
	if(in_array("replacement",$arr["manifestation"])) {
		$r_value .= '<input type="checkbox" name="manifestation[]" value="replacement" id="manifestation_replacement" checked="checked"/>';
	} else {
		$r_value .= '<input type="checkbox" name="manifestation[]" value="replacement" id="manifestation_replacement" />';
	}
	$r_value .= 'Replacement<br />';
	
$r_value .= <<< END
</td>
<td class="fielddescription">Indicate role of individual files within collection--reformatting quality attribute.
</td>
</tr>
</table>
END;


$r_value .= <<< END
</div>
</div>
END;

$r_value .= <<< END
<div class="section">
<div class="section_header">
<a class="plus" href="javascript:show_content('other_collections');" 
	id="other_collections-link" name="other_collections-link">+</a>
<span class="section_title">Related Resources</span>
<a href="javascript:unhidediv('other_collections-summary');">Summary</a>
</div>
<div id="other_collections-summary" class="summary" style="display:none;">
Data concerning the use and references of the collection

</div>
<div id="other_collections-content" class="content" style="display:none;">
END;


$r_value .= <<< END
<table id="table_isreferencedby" style="width:100%;">
<tr>
<td class="fieldname">Associated Publications
</td>
<td class="fielddata">
END;

	$r_value .= edit_multi_text($arr, "isreferencedby");
	
$r_value .= <<< END
</td>
<td class="fielddescription">Bibliographic citation (and URL if appropriate) of publications
based on use, study, or analysis of the collection
</td>
</tr>
</table>
END;


$r_value .= <<< END
<table id="table_haspart" style="width:100%;">
<tr>
<td class="fieldname">Subcollection
</td>
<td class="fielddata">
END;

	$r_value .= edit_multi_text($arr, "haspart");
	
$r_value .= <<< END
</td>
<td class="fielddescription">Name of collection (and URL if appropriate) that is contained within this digital collection
</td>
</tr>
</table>
END;


$r_value .= <<< END
<table id="table_ispartof" style="width:100%;">
<tr>
<td class="fieldname">Supercollection
</td>
<td class="fielddata">
END;

	$r_value .= edit_multi_text($arr, "ispartof");
	
$r_value .= <<< END
</td>
<td class="fielddescription">Name of collection (and URL if appropriate) that contains this digital collection
</td>
</tr>
</table>
END;


$r_value .= <<< END
<table id="table_catalogueor" style="width:100%;">
<tr>
<td class="fieldname">Catalog or Description
</td>
<td class="fielddata">
END;

	$r_value .= edit_multi_text($arr, "catalogueor");
	
$r_value .= <<< END
</td>
<td class="fielddescription">Finding aid or other publication which describes or provides intellectual access to this digital collection.
</td>
</tr>
</table>
END;


$r_value .= <<< END
<table id="table_catalogued_status" style="width:100%;">
<tr>
<td class="fieldname">Cataloged Status
<br /><span class="required">Required</span>

</td>
<td class="fielddata">
END;

		if($arr["catalogued_status_radio"] == 
			"catalogued") {
			$r_value .= '<input type="radio" name="' .
				'catalogued_status_radio" value="'.
				'cataloged" checked="checked" />';
		} else {
			$r_value .= '<input type="radio" name="' .
				'catalogued_status_radio" value="'.
				'cataloged" />';
		}
		$r_value .= "Cataloged<br />\n";
	
		if($arr["catalogued_status_radio"] == 
			"partial") {
			$r_value .= '<input type="radio" name="' .
				'catalogued_status_radio" value="'.
				'partial" checked="checked" />';
		} else {
			$r_value .= '<input type="radio" name="' .
				'catalogued_status_radio" value="'.
				'partial" />';
		}
		$r_value .= "Partially Cataloged<br />\n";
	
		if($arr["catalogued_status_radio"] == 
			"none") {
			$r_value .= '<input type="radio" name="' .
				'catalogued_status_radio" value="'.
				'none" checked="checked" />';
		} else {
			$r_value .= '<input type="radio" name="' .
				'catalogued_status_radio" value="'.
				'none" />';
		}
		$r_value .= "Not Cataloged<br />\n";
	
		$r_value .= '<textarea cols="50" rows="6" id="catalogued_status" name="catalogued_status_text" >';
		$r_value .= htmlspecialchars($arr["catalogued_status_text"]);
		$r_value .= "</textarea>\n";
	
$r_value .= <<< END
</td>
<td class="fielddescription">Detailed description of the cataloging or other metadata available
for items in the collection.
</td>
</tr>
</table>
END;


$r_value .= <<< END
<table id="table_relation" style="width:100%;">
<tr>
<td class="fieldname">Associated Collection
</td>
<td class="fielddata">
END;

	$r_value .= edit_multi_text($arr, "relation");
	
$r_value .= <<< END
</td>
<td class="fielddescription">Name(s) of collection(s) associated by content or provenance
</td>
</tr>
</table>
END;


$r_value .= <<< END
</div>
</div>
END;

$r_value .= <<< END
<div class="section">
<div class="section_header">
<a class="plus" href="javascript:show_content('lockss_stuff');" 
	id="lockss_stuff-link" name="lockss_stuff-link">+</a>
<span class="section_title">Harvesting Information</span>
<a href="javascript:unhidediv('lockss_stuff-summary');">Summary</a>
</div>
<div id="lockss_stuff-summary" class="summary" style="display:none;">
Information about the web crawl that will gather the files for archiving
</div>
<div id="lockss_stuff-content" class="content" style="display:none;">
END;

$r_value .= <<< END
<table id="table_cache_assignments" style="width:100%;">
<tr>
<td class="fieldname">Cache Assignment </td>
<td class="fielddata">
END;

foreach ($caches as $name => $dns) {
	$sel = ''; 
	if (in_array($name, array_values($arr['cache_assignments']))) { 
	    $sel= 'checked'; 
	}
	$r_value .= "\n<input type='checkbox' name='cache_assignments[]' $sel value='" . $name  . "' /> $name <font size=-1> ($dns) </font> <br/>";
}
$r_value .= <<< END
</td>
<td class="fielddescription">Designates Caches for Presercvation of this Collection
</td>
</tr>
</table>
END;

$r_value .= <<< END
<table id="table_riskrank" style="width:100%;">
<tr>
<td class="fieldname">Risk Rank
<br /><span class="required">Required</span>

</td>
<td class="fielddata">
END;

	if($arr["riskrank"] == "5") {
		$r_value .= '<input type="radio" name="riskrank" value="5" checked="checked"/>';
	} else {
		$r_value .= '<input type="radio" name="riskrank" value="5" />';
	}
		
			$r_value .= "<a href=\"javascript:unhidediv('riskrank";
			$r_value .= "_summary_5')\">";
			$r_value .= 'Extreme Risk</a><br />';
			$r_value .= "<div class=\"radio_summary\" id=\"riskrank";
			$r_value .= "_summary_5\" style=\"display:none;\">";
			$r_value .= <<< END
			
No one is responsible for preservation.  No other copies of the digital content 
are preserved beyond the available copy under consideration.  No regular
backups or data migration.

			</div>
END;
		
	if($arr["riskrank"] == "4") {
		$r_value .= '<input type="radio" name="riskrank" value="4" checked="checked"/>';
	} else {
		$r_value .= '<input type="radio" name="riskrank" value="4" />';
	}
		
			$r_value .= "<a href=\"javascript:unhidediv('riskrank";
			$r_value .= "_summary_4')\">";
			$r_value .= 'Significant Risk</a><br />';
			$r_value .= "<div class=\"radio_summary\" id=\"riskrank";
			$r_value .= "_summary_4\" style=\"display:none;\">";
			$r_value .= <<< END
			
Responsibility under discussion.  Curators fretting about who will take 
responsibility for preservation.

			</div>
END;
		
	if($arr["riskrank"] == "3") {
		$r_value .= '<input type="radio" name="riskrank" value="3" checked="checked"/>';
	} else {
		$r_value .= '<input type="radio" name="riskrank" value="3" />';
	}
		
			$r_value .= "<a href=\"javascript:unhidediv('riskrank";
			$r_value .= "_summary_3')\">";
			$r_value .= 'High Risk</a><br />';
			$r_value .= "<div class=\"radio_summary\" id=\"riskrank";
			$r_value .= "_summary_3\" style=\"display:none;\">";
			$r_value .= <<< END
			
Only one backup of digital masters on CD-ROM, no regular backups or data
migration.

			</div>
END;
		
	if($arr["riskrank"] == "2") {
		$r_value .= '<input type="radio" name="riskrank" value="2" checked="checked"/>';
	} else {
		$r_value .= '<input type="radio" name="riskrank" value="2" />';
	}
		
			$r_value .= "<a href=\"javascript:unhidediv('riskrank";
			$r_value .= "_summary_2')\">";
			$r_value .= 'Moderate Risk</a><br />';
			$r_value .= "<div class=\"radio_summary\" id=\"riskrank";
			$r_value .= "_summary_2\" style=\"display:none;\">";
			$r_value .= <<< END
			
Some danger that collection backups might be lost in the future.

			</div>
END;
		
	if($arr["riskrank"] == "1") {
		$r_value .= '<input type="radio" name="riskrank" value="1" checked="checked"/>';
	} else {
		$r_value .= '<input type="radio" name="riskrank" value="1" />';
	}
		
			$r_value .= "<a href=\"javascript:unhidediv('riskrank";
			$r_value .= "_summary_1')\">";
			$r_value .= 'Low Risk</a><br />';
			$r_value .= "<div class=\"radio_summary\" id=\"riskrank";
			$r_value .= "_summary_1\" style=\"display:none;\">";
			$r_value .= <<< END
			
Copies are backed up regularly with a long term maintenance plan in some other
trusted digital archive.

			</div>
END;
		
$r_value .= <<< END
</td>
<td class="fielddescription">Designates the degree to which the collection is in jeopardy
</td>
</tr>
</table>
END;


$r_value .= <<< END
<table id="table_risk_factors" style="width:100%;">
<tr>
<td class="fieldname">Risk Factors
</td>
<td class="fielddata">
END;

	$r_value .= edit_text_area($arr, "risk_factors");
	
$r_value .= <<< END
</td>
<td class="fielddescription">Describes in a clear way the factors that endanger the preservation of this collection.
</td>
</tr>
</table>
END;


$r_value .= <<< END
</div>
</div>
&nbsp; <br/>
END;

	$r_value .= '<input type="submit" name="submit" class="button" value="Submit Metadata" />';
	$r_value .= '</form></div>';
	return $r_value;
}
?>

