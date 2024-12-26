<?php
include 'WAF.php';
if ( isset($_REQUEST['name'])) {
    $name = ($_REQUEST['name']); // Sanitize the input
    $message = "Hello, " . $name . "!";
} else {
    $message = "Please input your name:";
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to My Webpage</title>
</head>
<body>
    <h1>Welcome to My xxxx!</h1>
    <p><?php echo $message; ?></p>
    <form action='/index.php' method='POST'>
            <label for='name'>Your Name:</label><br>
            <input type='text' id='name' name='name' required><br><br>
            <input type='submit' value='Submit'>
        </form>
</body>
</html>
