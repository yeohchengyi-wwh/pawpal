<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {

    // join query
    $baseQuery = "
     SELECT 
        p.pet_id,
        p.user_id,
        p.pet_name,
        p.pet_type,
        p.category,
        p.description,
        p.image_paths,
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
    if (isset($_GET['search']) && !empty($_GET['search'])) {
        $search = $conn->real_escape_string($_GET['search']);
        $sqlsearch = $baseQuery . "
            WHERE p.pet_name LIKE '%$search%' 
               OR p.pet_type LIKE '%$search%'
               OR p.category LIKE '%$search%'
            ORDER BY p.pet_id DESC";
    } else {
        // Search all
        $sqlsearch = $baseQuery . " ORDER BY p.pet_id DESC";
    }

    $result = $conn->query($sqlsearch);
    
    if ($result) {
        if ($result->num_rows > 0) {
            $petdata = array();
            while ($row = $result->fetch_assoc()) {
                // 确保image_paths字段有默认值
                if (!isset($row['image_paths'])) {
                    $row['image_paths'] = '[]';
                }
                $petdata[] = $row;
            }
            $response = array(
                "success" => true, 
                "data" => $petdata,
                "message" => count($petdata) . " pets found"
            );
            sendJsonResponse($response);
        } else {
            // 没有找到任何记录
            $response = array(
                "success" => true, 
                "data" => array(),
                "message" => "No pets found"
            );
            sendJsonResponse($response);
        }
    } else {
        // 查询失败
        $response = array(
            "success" => false, 
            "message" => "Database query error: " . $conn->error
        );
        sendJsonResponse($response);
    }
    
    // 关闭连接
    $conn->close();
    
} else {
    $response = array(
        "success" => false, 
        "message" => "Invalid request method. Only GET is allowed."
    );
    sendJsonResponse($response);
    exit();
}

function sendJsonResponse($sentArray)
{
    echo json_encode($sentArray);
}
?>