<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {

    // join query
    $baseQuery = "
     SELECT 
        p.pet_id,
        p.user_id,
        p.pet_name,
        p.pet_type,
        p.gender,
        p.age,
        p.category,
        p.health,
        p.description,
        p.lat,
        p.lng,
        p.created_at,
        u.name,
        u.email,
        u.phone
    FROM tbl_pets p
    JOIN tbl_users u ON p.user_id = u.user_id
    ";

    // Specific content search
    if (isset($_GET['search']) && !empty($_GET['search']) && isset($_GET['filter']) && !empty($_GET['filter'])) {
        $search = $conn->real_escape_string($_GET['search']);
        $filter = $conn->real_escape_string($_GET['filter']);
        $sqlsearch = $baseQuery . " 
            WHERE p.pet_name LIKE '%$search%' 
                AND p.pet_type = '$filter' 
                AND p.is_adopted = 0
            ORDER BY p.pet_id DESC";
    } else if (isset($_GET['search']) && !empty($_GET['search'])) {
        $search = $conn->real_escape_string($_GET['search']);
        $sqlsearch = $baseQuery . " 
        WHERE p.pet_name LIKE '%$search%' 
            AND p.is_adopted = 0
        ORDER BY p.pet_id DESC";
    } else if (isset($_GET['filter']) && !empty($_GET['filter'])) {
        $filter = $conn->real_escape_string($_GET['filter']);
        $sqlsearch = $baseQuery . " 
        WHERE p.pet_type = '$filter' 
            AND p.is_adopted = 0
        ORDER BY p.pet_id DESC";
    } else {
        // Search all
        $sqlsearch = $baseQuery . " WHERE p.is_adopted = 0 ORDER BY p.pet_id DESC";
    }

    $result = $conn->query($sqlsearch);
    if ($result && $result->num_rows > 0) {
        $petdata = array();
        while ($row = $result->fetch_assoc()) {
            $petdata[] = $row;
        }
        $response = array("success" => true, "data" => $petdata);
        sendJsonResponse($response);
    } else{
        $response = array("success" => true, "message" => "No result");
        sendJsonResponse($response);
    }
} else {
    $response = array("success" => false, "message" => "No submission yet");
    sendJsonResponse($response);
    exit();
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}