<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
	http_response_code(405);
	echo json_encode(array('error' => 'Method Not Allowed'));
	exit();
}

if (!isset($_POST['petid']) || !isset($_POST['userid']) || !isset($_POST['contact_info']) || !isset($_POST['reason_adopt'])) {
	http_response_code(400);
	echo json_encode(array("success" => false, "message" => "Bad Request: Missing required fields"));
	exit();
}

$petid = $_POST['petid'];
$userid = $_POST['userid'];
$contact_info = $_POST['contact_info'];
$reason = $_POST['reason_adopt'];

$sqlinsertadoption = "INSERT INTO `tbl_adoptions`(`pet_id`, `user_id`, `contact_info`, `reason_adopt`) 
	VALUES ('$petid','$userid','$contact_info','$reason')";

try {
	if ($conn->query($sqlinsertadoption) === TRUE) {
	   $response = array('success' => true, 'message' => 'Adoption request successful');
	} else {
		$response = array('success' => false, 'message' => 'Adoption request failed');
	}
	sendJsonResponse($response);
} catch (Exception $e) {
	$response = array('success' => false, 'message' => $e->getMessage());
	sendJsonResponse($response);
}

//	function to send json response	
function sendJsonResponse($sentArray)
{
	header('Content-Type: application/json');
	echo json_encode($sentArray);
}
?>