<html>
<body>

<?php 
if ($_POST) { 
echo $_POST['txt'] ;
} else { 
?>
<form action="post.php" method="post">
<textarea rows=20 cols=80 name="txt" >
sjkadghksag
</textarea> 
<input type="submit" />
</form>

<?php 
} 
?>

</body>
</html>
