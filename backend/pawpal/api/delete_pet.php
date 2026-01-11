<?php
	header("Access-Control-Allow-Origin: *");
	include 'dbconnect.php';

	if ($_SERVER['REQUEST_METHOD'] != 'POST') {
		http_response_code(405);
		echo json_encode(array('error' => 'Method Not Allowed'));
		exit();
	}
	$userid = $_POST['userid'];
	$petid = $_POST['petid'];
	
	// Delete pet from database
	$deletepet = "DELETE FROM `tbl_pets` WHERE `pet_id` = '$petid' AND `user_id` = '$userid'"; 
	try{
		if ($conn->query($deletepet) === TRUE){
			$response = array('success' => true, 'message' => 'Pet delete successfully');
			sendJsonResponse($response);
		}else{
			$response = array('success' => false, 'message' => 'Pet not deleted');
			sendJsonResponse($response);
		}
	}catch(Exception $e){
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