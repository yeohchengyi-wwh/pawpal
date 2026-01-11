<?php
    $servername = "localhost";
    $username = "youcapfu_youcapfu_yeoh";
    $password = "P@ssw0rd123";
    $dbname = "youcapfu_pawpaldb";
    // Create connection
    $conn = new mysqli($servername, $username, $password, $dbname);
    // Check connection
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }
?>