<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    http_response_code(405);
    echo json_encode(array('error' => 'Method Not Allowed'));
    exit();
}

if (!isset($_POST['petid']) || !isset($_POST['userid']) || !isset($_POST['petname']) || !isset($_POST['pettype']) || !isset($_POST['gender']) || !isset($_POST['age']) || !isset($_POST['category']) || !isset($_POST['health']) || !isset($_POST['description']) || !isset($_POST['latitude']) || !isset($_POST['longitude']) || !isset($_POST['images'])) {
    http_response_code(400);
    echo json_encode(array("success" => false, "message" => "Bad Request"));
    exit();
}

$petid = $_POST['petid'];
$userid = $_POST['userid'];
$petname = $_POST['petname'];
$pettype = $_POST['pettype'];
$gender = $_POST['gender'];
$age = $_POST['age'];
$category = $_POST['category'];
$health = $_POST['health'];
$description = $_POST['description'];
$latitude = $_POST['latitude'];
$longitude = $_POST['longitude'];
$base64list = json_decode($_POST['images'], true);
$savedImages = [];

try {
    // Update existing pet
    $sqlUpdatePet = "UPDATE `tbl_pets` SET 
        `pet_name` = '$petname',
        `pet_type` = '$pettype',
        `gender` = '$gender',
        `age` = '$age',
        `category` = '$category',
        `health` = '$health',
        `description` = '$description',
        `lat` = '$latitude',
        `lng` = '$longitude'
        WHERE `pet_id` = '$petid' AND `user_id` = '$userid'";

    if ($conn->query($sqlUpdatePet) === TRUE) {

        if (count($base64list) > 0) {
            for ($i = 0; $i < count($base64list); $i++) {
                $base64image = $base64list[$i];
                $decodedImage = base64_decode($base64image);
                $filename = "../uploads/pet/pet_" . $petid . "_" . ($i + 1) . ".png";
                file_put_contents($filename, $decodedImage);
                $savedImages[] = 'image'.($i+1).': '.$filename;
            }

            // save the image paths in JSON format
            $imageJson = json_encode($savedImages);
            $updateImageSql = "UPDATE tbl_pets SET `image_paths` = '$imageJson' WHERE pet_id = '$petid'";
            $conn->query($updateImageSql);
        }

        $response = array('success' => true, 'message' => 'Pet updated successfully');
        sendJsonResponse($response);

    } else {
        $response = array('success' => false, 'message' => 'Pet failed to update');
        sendJsonResponse($response);
    }

} catch (Exception $e) {
    $response = array('success' => false, 'message' => $e->getMessage());
    sendJsonResponse($response);
}

// Function to send json response
function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}