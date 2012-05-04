<?php
function trace($str) {
	$_SESSION['trace'] .= $str; 
} 
function traceln($str) {
	$_SESSION['trace'] = $_SESSION['trace'] . ($str . "<br/>"); 
} 
function tracearr($pref, $arr) { 
    foreach($arr as $key => $value) {
       traceln($pref . ": " . $key ."='" . $value . "'"); 
    }
}

function traceflush() { 
	print "<p>" . $_SESSION['trace'] . "</p>"; 
	$_SESSION['trace'] = ''; 
   
} 
?>
