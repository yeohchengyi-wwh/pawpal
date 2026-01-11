<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

$email = $_GET['email'] ?? '';
$phone = $_GET['phone'] ?? $_GET['mobile'] ?? '';
$name  = $_GET['name'] ?? 'User';
$userid = $_GET['userid'] ?? '';

if (isset($_GET['money'])) {
    $amount = floatval($_GET['money']);
} elseif (isset($_GET['amount'])) {
    $amount = floatval($_GET['amount']);
} else {
    $amount = 0;
}

if ($amount < 1) {
    echo "<center><h3>Error: Amount too low</h3>";
    echo "<p>Received amount: RM $amount</p>";
    echo "<p>Minimum amount required is RM 1.00</p>";
    echo "<p>Please check your URL parameters (e.g. ?money=10.00)</p></center>";
    exit();
}

//Billplz
$api_key = '4af7c95a-1f80-4c0c-8b0c-e4b87e9e5e74';
$collection_id = 'xambw74_';
$host = 'https://www.billplz-sandbox.com/api/v3/bills';

$data = array(
    'collection_id' => $collection_id,
    'email' => $email,
    'mobile' => $phone,
    'name' => $name,
    'amount' => $amount * 100, // 
    'description' => 'Payment for User ' . $userid,
    'callback_url' => "https://youcanyouup.com.my/pawpal_yeoh/pawpal/api/return_url",
    'redirect_url' => "https://youcanyouup.com.my/pawpal_yeoh/pawpal/api/payment_update.php?userid=$userid&email=$email&name=$name&phone=$phone&money=$amount"
);

$process = curl_init($host);
curl_setopt($process, CURLOPT_HEADER, 0);
curl_setopt($process, CURLOPT_USERPWD, $api_key . ":");
curl_setopt($process, CURLOPT_TIMEOUT, 30);
curl_setopt($process, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($process, CURLOPT_SSL_VERIFYHOST, 0);
curl_setopt($process, CURLOPT_SSL_VERIFYPEER, 0);
curl_setopt($process, CURLOPT_POSTFIELDS, http_build_query($data)); 

$return = curl_exec($process);
curl_close($process);

$bill = json_decode($return, true);

if (isset($bill['error'])) {
    echo "<center><h3>Billplz Error</h3>";
    echo "<p>Type: " . ($bill['error']['type'] ?? 'Unknown') . "</p>";
    $msg = $bill['error']['message'];
    echo "<p>Message: " . (is_array($msg) ? implode(", ", $msg) : $msg) . "</p>";
    echo "<hr><p>Debug Info:</p><pre>";
    print_r($data);
    echo "</pre></center>";
} else if (isset($bill['url'])) {
    header("Location: {$bill['url']}");
    exit();
} else {
    echo "Unknown Error. Response: " . $return;
}
?>