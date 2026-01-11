<?php
error_reporting(E_ALL);
ini_set('display_errors', 0);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    http_response_code(405);
    echo json_encode(array('success' => false, 'message' => 'Method Not Allowed'));
    exit();
}

if (!isset($_POST['adoption_id'])) {
    http_response_code(400);
    echo json_encode(array("success" => false, "message" => "Bad Request: Missing adoption_id"));
    exit();
}

$adoptionid = $_POST['adoption_id'];

$sqldelete = "DELETE FROM `tbl_adoptions` WHERE `id` = ?";

try {
    $stmt = $conn->prepare($sqldelete);
    $stmt->bind_param("s", $adoptionid);

    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode(array('success' => true, 'message' => 'Adoption request cancelled/deleted successfully'));
        } else {
            echo json_encode(array('success' => false, 'message' => 'Adoption request not found'));
        }
    } else {
        echo json_encode(array('success' => false, 'message' => 'Failed to delete request'));
    }
} catch (Exception $e) {
    echo json_encode(array('success' => false, 'message' => 'Error: ' . $e->getMessage()));
}
?>