<?php
$id = $_GET['hdlid'];
$title = $_GET['title'];
$subtitle = $_GET['subtitle'];
$manifest = $_GET['manifest'];

include "genPage.php";
genItemListPage($title, $subtitle, $manifest, $id);
 
?>
