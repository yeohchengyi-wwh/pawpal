<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {

    $userId = $_GET['userid'] ?? $_GET['user_id'] ?? null;
    // search all donations, pet name, donor name, recipient name
    $sqlsearch = "
        SELECT
            d.*,
            p.pet_name,
            donor.name AS donor_name,
            recipient.name AS recipient_name
        FROM tbl_donations d
        JOIN tbl_users donor ON d.user_id = donor.user_id
        JOIN tbl_pets p ON d.pet_id = p.pet_id
        JOIN tbl_users recipient ON p.user_id = recipient.user_id
        WHERE d.user_id = '$userId' OR p.user_id = '$userId'
        ORDER BY d.donation_date DESC
        ";

    $result = $conn->query($sqlsearch);
    if ($result && $result->num_rows > 0) {
        $donationdata = array();
        while ($row = $result->fetch_assoc()) {
            if ($row['user_id'] == $userId) {
                // current user is donor then show recipient name
                $row['other_user_name'] = $row['recipient_name'];
            } else {
                // current user is recipient then show donor name
                $row['other_user_name'] = $row['donor_name'];
            }
            $donationdata[] = $row;
        }
        $response = array("success" => true, "data" => $donationdata);
    } else{
        $response = array("success" => true, "message" => "No donation history");
    }
    sendJsonResponse($response);
} else {
    $response = array("success" => false, "message" => "Invalid request method");
    sendJsonResponse($response);
    exit();
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}