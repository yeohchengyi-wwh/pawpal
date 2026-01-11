<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
	http_response_code(405);
	echo json_encode(array('error' => 'Method Not Allowed'));
	exit();
}

if (!isset($_POST['petid']) || !isset($_POST['userid']) || !isset($_POST['donationType']) || !isset($_POST['amount']) || !isset($_POST['description'])) {
	http_response_code(400);
	echo json_encode(array("success" => false, "message" => "Bad Request"));
	exit();
}

$petid = $_POST['petid'];
$userid = $_POST['userid'];
$donationtype = $_POST['donationType'];
$amount = isset($_POST['amount']) ? floatval($_POST['amount']) : 0.0;
$description = $_POST['description'];

// Insert donation request into database
$sqlinsertdonation = "INSERT INTO `tbl_donations`(`pet_id`, `user_id`, `donation_type`, `amount`, `description`) 
	VALUES ('$petid','$userid','$donationtype','$amount','$description')";
try {
	if ($conn->query($sqlinsertdonation) === TRUE) {
		// Search pet owner
		$sqlsearchpetowner = "SELECT user_id FROM `tbl_pets` WHERE `pet_id` = '$petid'";
		$result = $conn->query($sqlsearchpetowner);
		if($result->num_rows != 0){
		    // Add amount to pet owner's wallet
		    $petOwnerId = $result->fetch_assoc()['user_id'];
		    $sqlWalletPetOwner = "UPDATE `tbl_users` SET `wallet` = `wallet` + $amount WHERE `user_id` = '$petOwnerId'";
		    if($conn->query($sqlWalletPetOwner) === TRUE){
		        // Deduct amount from donor's wallet
		        $sqlWalletDonor = "UPDATE `tbl_users` SET `wallet` = `wallet` - $amount WHERE `user_id` = '$userid'";
		        if($conn->query($sqlWalletDonor) === TRUE){
		            $response = array('success' => true, 'message' => 'Donation success');
		        }else{
		            $response = array('success' => false, 'message' => 'Donation failed');
		        }
		    }else{
		        $response = array('success' => false, 'message' => 'Donation failed');
		    }
		}else{
		    $response = array('success' => false, 'message' => 'Donation failed');
		}
		sendJsonResponse($response);
	} else {
		$response = array('success' => false, 'message' => 'Donation failed');
		sendJsonResponse($response);
	}
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