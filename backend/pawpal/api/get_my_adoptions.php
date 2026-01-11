<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {

    $userid = $_GET['userid'];
    
    // search adoption, pet name, pet owner detail, adopter detail
    $sqlsearch = "
        SELECT 
            a.*,
            p.pet_name,
            u_pet.user_id AS pet_owner_id,
            u_pet.name AS pet_owner_name,
            u_pet.email AS pet_owner_email,
            u_pet.phone AS pet_owner_phone,
            u_adopter.user_id AS adopter_id,
            u_adopter.name AS adopter_name,
            u_adopter.email AS adopter_email,
            u_adopter.phone AS adopter_phone
        FROM tbl_adoptions a
        JOIN tbl_pets p ON a.pet_id = p.pet_id
        JOIN tbl_users u_pet ON p.user_id = u_pet.user_id
        JOIN tbl_users u_adopter ON a.user_id = u_adopter.user_id
        WHERE a.user_id = '$userid' OR p.user_id = '$userid'
        ";
    $result = $conn->query($sqlsearch);
    if ($result && $result->num_rows > 0) {
        $adoptiondata = array();
        while ($row = $result->fetch_assoc()) {
            if ($row['adopter_id'] == $userid) {
                // current user is adopter then show pet owner info
                $row['other_user_id'] = $row['pet_owner_id'];
                $row['other_user_name'] = $row['pet_owner_name'];
                $row['other_user_email'] = $row['pet_owner_email'];
                $row['other_user_phone'] = $row['pet_owner_phone'];
            } else {
                // current user is pet owner then show adopter info
                $row['other_user_id'] = $row['adopter_id'];
                $row['other_user_name'] = $row['adopter_name'];
                $row['other_user_email'] = $row['adopter_email'];
                $row['other_user_phone'] = $row['adopter_phone'];
            }
            $adoptiondata[] = $row;
        }
        $response = array("success" => true, "data" => $adoptiondata);
    }else{
        $response = array("success" => true, "message" => "No Adoption Result");
    }
    sendJsonResponse($response);
}else{
    $response = array("success" => false, "message" => "Invalid request method");
    sendJsonResponse($response);
    exit();
}
    
function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}