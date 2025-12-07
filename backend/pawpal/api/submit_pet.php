<?php
// 允许跨域
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'dbconnect.php';

// 1. 检查请求方法
if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    http_response_code(405);
    sendJsonResponse(array('success' => false, 'message' => 'Method Not Allowed'));
    exit();
}

// 2. 检查参数是否存在
$required_params = ['userid', 'petname', 'pettype', 'category', 'description', 'latitude', 'longitude', 'images'];
foreach ($required_params as $param) {
    if (!isset($_POST[$param])) {
        http_response_code(400);
        sendJsonResponse(array("success" => false, "message" => "Missing parameter: $param"));
        exit();
    }
}

// 3. 获取数据
$userid = $_POST['userid'];
$petname = $_POST['petname'];
$pettype = $_POST['pettype'];
$category = $_POST['category'];
$description = $_POST['description'];
$latitude = $_POST['latitude'];
$longitude = $_POST['longitude'];

// 解码图片 JSON
$base64list = json_decode($_POST['images'], true);

// 记录调试信息
error_log("Received data - userid: $userid, petname: $petname, images count: " . count($base64list));

// 4. 使用 Prepared Statement 插入数据
$sqlinsertpet = "INSERT INTO `tbl_pets`(`user_id`, `pet_name`, `pet_type`, `category`, `description`, `lat`, `lng`, `image_paths`) VALUES (?, ?, ?, ?, ?, ?, ?, '')";

$stmt = $conn->prepare($sqlinsertpet);
$stmt->bind_param("sssssss", $userid, $petname, $pettype, $category, $description, $latitude, $longitude);

if ($stmt->execute()) {
    $last_id = $conn->insert_id;
    $savedImages = array();
    
    // 检查并创建 uploads 文件夹
    $uploadDir = "uploads/";  // 修改为相对路径
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }

    // 5. 处理图片
    if (is_array($base64list) && count($base64list) > 0) {
        error_log("Processing " . count($base64list) . " images");
        
        for ($i = 0; $i < count($base64list); $i++) {
            $base64image = $base64list[$i];
            
            // 验证Base64字符串
            if (empty($base64image)) {
                error_log("Image $i is empty, skipping");
                continue;
            }
            
            // 尝试解码Base64
            $decodedImage = base64_decode($base64image);
            
            if ($decodedImage === false) {
                error_log("Failed to decode image $i");
                continue; // 解码失败跳过
            }

            // 尝试获取图片类型
            $finfo = finfo_open(FILEINFO_MIME_TYPE);
            $mime_type = finfo_buffer($finfo, $decodedImage);
            finfo_close($finfo);
            
            // 根据MIME类型确定扩展名
            $extension = 'jpg';
            if (strpos($mime_type, 'png') !== false) {
                $extension = 'png';
            } elseif (strpos($mime_type, 'gif') !== false) {
                $extension = 'gif';
            } elseif (strpos($mime_type, 'jpeg') !== false) {
                $extension = 'jpg';
            }

            // 生成文件名
            $filename = "pet_" . $last_id . "_" . ($i + 1) . "." . $extension;
            $targetPath = $uploadDir . $filename;

            if (file_put_contents($targetPath, $decodedImage)) {
                error_log("Saved image $i as $filename");
                $savedImages[] = $filename; 
            } else {
                error_log("Failed to save image $i to $targetPath");
            }
        }

        // 6. 更新数据库中的 image_paths
        if (!empty($savedImages)) {
            $imageJson = json_encode($savedImages);
            $updatesql = "UPDATE tbl_pets SET `image_paths` = ? WHERE pet_id = ?";
            $stmtUpdate = $conn->prepare($updatesql);
            $stmtUpdate->bind_param("si", $imageJson, $last_id);
            if (!$stmtUpdate->execute()) {
                error_log("Failed to update image_paths: " . $stmtUpdate->error);
            }
            $stmtUpdate->close();
        }
    }

    error_log("Pet submitted successfully, ID: $last_id");
    sendJsonResponse(array('success' => true, 'message' => 'Pet submitted successfully'));

} else {
    // SQL 执行失败
    error_log("Database Error: " . $stmt->error);
    sendJsonResponse(array('success' => false, 'message' => 'Database Error: ' . $stmt->error));
}

// 关闭连接
$stmt->close();
$conn->close();

function sendJsonResponse($sentArray) {
    echo json_encode($sentArray);
}
?>