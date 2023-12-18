<?php 
//ini_set('display_errors', 1);
//ini_set('display_startup_errors', 1);
//error_reporting(E_ALL);
?>
<!DOCTYPE html>
<html lang="en">
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
body, html {
  height: 100%;
  margin: 0;
} 
.bg {
  /* The image used */
  background-image: url("plane2.jpg");
  /* Full height */
  height: 100%; 
  /* Center and scale the image nicely */
  background-position: center;
  background-repeat: no-repeat;
  background-size: cover;
}
</style>
<head>
  <title>Aishwarya Dresses</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
</head>
<body>
<div class="bg">
<?php
$servername = "localhost";
$username = "johndoe"; 
$password = "Your@Password"; 
$dbname = "mysql";
$guestname = $_POST["guestname"];
$comment = $_POST["comment"];
 
// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
 
// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}
 

if ($_SERVER["REQUEST_METHOD"] == "POST") {  
    
    $guestname = trim($guestname);
    $comment = trim($comment);
     // Avoid null inserts with space
      if ($guestname != '' OR $comment != '')
      {
      	$sqlIns = "INSERT INTO guests (guestname, comment) VALUES ('$guestname',  '$comment')";
      	if ($conn->query($sqlIns) === TRUE) {
      	echo "New record created successfully";
  	  } 
    	else 
    	{
        		echo "Error: " . $sql . "<br>" . $conn->error;
    	}
    }
}
else 
{
    ?>
    <div class="container">
    <form method="post">  
        <div class="form-group">
            <label for="Name">Name:</label>
            <input type="text" class="form-control" id="guestname" placeholder="Enter Name" name="guestname" value="<?php echo $guestname;?>" required=true>
        </div>
        <div class="form-group">
            <label for="pwd">Comment:</label>
            <input type="text" class="form-control" id="comment" placeholder="Enter Comment" name="comment" value="<?php echo $comment;?>" required=true>
        </div>
        <button type="submit" class="btn btn-default">Submit</button>  
    </form>
    </div>
    <?php
}
?>
 

    <div class="container">
    <br/><br/><br/></br/><br/>
    <br/><br/><br/></br/><br/>
    <br/><br/><br/></br/><br/>
    <h2 style="color:white">Comments</h2> 
    <table class="table" style="background-color:#F4F5F9">
        <thead>
        <tr>
            <th>Name</th>
            <th>Comments</th> 
        </tr>
        </thead>
        <tbody>
            <?php 
            $sql = "SELECT gid, guestname, comment FROM guests order by gid desc limit 10";
            $result = $conn->query($sql);
            if ($result->num_rows > 0) { 
                while($row = $result->fetch_assoc()) {
                echo "<tr> <td>  " . $row["guestname"]. "</td><td> " . $row["comment"]. "</td> </tr>";
                } 
            } 
            $conn->close();
            ?>
        </tbody>
    </table>
    </div>
 
 </div> 
