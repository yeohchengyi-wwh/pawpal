<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method Not Allowed']);
    exit();
}

// get data
$userid       = $_POST['user_id'];
$name         = addslashes($_POST['user_name']);
$phone        = addslashes($_POST['user_phone']);
$user_image       = $_POST['user_image'];

// update query
$sqlupdateprofile = "
UPDATE tbl_users 
SET 
    name    = '$name',
    phone   = '$phone'
WHERE user_id = '$userid'
";

try {
    if ($conn->query($sqlupdateprofile) === TRUE) {
        if(!empty($user_image)){
            $encodedimage = base64_decode($user_image);
            $path = "../uploads/profile/user_".$userid.".png";
    		file_put_contents($path, $encodedimage);
    		$sqlupdateavatar = "UPDATE tbl_users SET `user_image` = '$path' WHERE user_id = '$userid'";
    		if ($conn->query($sqlupdateavatar) === TRUE){
    		    $reponse = array('success' => true, 'message' => 'Profile update successfully');
    		}else{
    		 $reponse = array('success' => false, 'message' => 'User Image update failed');   
    		}
        }
        $reponse = array('success' => true, 'message' => 'Profile update successfully');
		
    } else {
        $reponse = array('success' => false, 'message' => 'Profile update failed');
    }
    sendJsonResponse($reponse);
} catch (Exception $e) {
    sendJsonResponse([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}

function sendJsonResponse($sentArray)
{
    echo json_encode($sentArray);
}
?>