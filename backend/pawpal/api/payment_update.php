<?php
//error_reporting(0);
include_once("dbconnect.php");

$email = $_GET['email']; //email
$phone = $_GET['phone']; 
$name = $_GET['name']; 
$money = $_GET['money']; 
$userid = $_GET['userid'];
$xkey = '1b29e6acce9954d9a1cc25df3a3af87ec608676465e3c6d6de6be31d9fcc0d16aeb433549067cae0e0415d0dc38e44ea8a52a5f296242213042f07cb252b4982';

$data = array(
    'id' =>  $_GET['billplz']['id'],
    'paid_at' => $_GET['billplz']['paid_at'] ,
    'paid' => $_GET['billplz']['paid'],
    'x_signature' => $_GET['billplz']['x_signature']
);

$paidstatus = $_GET['billplz']['paid'];
if ($paidstatus=="true"){
    $paidstatus = "Success";
}else{
    $paidstatus = "Failed";
}
$receiptid = $_GET['billplz']['id'];
$signing = '';
foreach ($data as $key => $value) {
    $signing.= 'billplz'.$key . $value;
    if ($key === 'paid') {
        break;
    } else {
        $signing .= '|';
    }
}

$signed= hash_hmac('sha256', $signing, $xkey);
if ($signed === $data['x_signature']) {
    if ($paidstatus == "Success"){ //payment success
        //update wallet money
        $sqlupdatewallet = "UPDATE `tbl_users` SET `wallet` = `wallet` + '$money' WHERE `user_id` = '$userid'";
        if ($conn->query($sqlupdatewallet) === TRUE){
             //print receipt for success transaction
            echo "
            <html><head>
            <meta name='viewport' content='width=device-width, initial-scale=1'>
            <link rel='stylesheet' href='https://www.w3schools.com/w3css/4/w3.css'>
            <style>
                body {
                    background-color: #f0f4f8;
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                }
                .topup-card {
                    max-width: 400px;
                    margin: 40px auto;
                    padding: 25px;
                    background-color: #fff;
                    border-radius: 12px;
                    box-shadow: 0 6px 20px rgba(0,0,0,0.1);
                    text-align: center;
                }
                .success-icon {
                    font-size: 60px;
                    color: #4CAF50;
                    margin-bottom: 10px;
                }
                h2 {
                    margin: 10px 0 5px 0;
                    color: #333;
                }
                p {
                    color: #555;
                    margin: 5px 0 20px 0;
                }
                .w3-table td, .w3-table th {
                    padding: 12px;
                }
                .amount {
                    font-weight: bold;
                    color: #4CAF50;
                }
            </style></head>
            <body>
            
            <div class='topup-card'>
                <div class='success-icon'>✔</div>
                <h2>Top-Up Successful</h2>
                <p>You have successfully top up to your wallet.</p>
                
                <table class='w3-table w3-striped w3-bordered w3-small'>
                    <tr><th>Item</th><th>Details</th></tr>
                    <tr><td>Top-Up ID</td><td>$receiptid</td></tr>
                    <tr><td>Name</td><td>$name</td></tr>
                    <tr><td>Email</td><td>$email</td></tr>
                    <tr><td>Phone</td><td>$phone</td></tr>
                    <tr><td>Amount Added</td><td class='amount'>RM$money</td></tr>
                    <tr><td>Status</td><td class='amount'>$paidstatus</td></tr>
                </table>
            </div>
            
            </body></html>";
        }else{
              echo "
            <html><head>
            <meta name='viewport' content='width=device-width, initial-scale=1'>
            <link rel='stylesheet' href='https://www.w3schools.com/w3css/4/w3.css'>
            <style>
                body {
                    background-color: #f0f4f8;
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                }
                .topup-card {
                    max-width: 400px;
                    margin: 40px auto;
                    padding: 25px;
                    background-color: #fff;
                    border-radius: 12px;
                    box-shadow: 0 6px 20px rgba(0,0,0,0.1);
                    text-align: center;
                }
                .fail-icon {
                    font-size: 60px;
                    color: #f44336;
                    margin-bottom: 10px;
                }
                h2 {
                    margin: 10px 0 5px 0;
                    color: #333;
                }
                p {
                    color: #555;
                    margin: 5px 0 20px 0;
                }
                .w3-table td, .w3-table th {
                    padding: 12px;
                }
                .amount {
                    font-weight: bold;
                    color: #f44336;
                }
            </style></head>
            <body>
            
            <div class='topup-card'>
                <div class='fail-icon'>✖</div>
                <h2>Top-Up Failed</h2>
                <p>Sorry, your top-up could not be processed.</p>
                
                <table class='w3-table w3-striped w3-bordered w3-small'>
                    <tr><th>Item</th><th>Details</th></tr>
                    <tr><td>Top-Up ID</td><td>$receiptid</td></tr>
                    <tr><td>Name</td><td>$name</td></tr>
                    <tr><td>Email</td><td>$email</td></tr>
                    <tr><td>Phone</td><td>$phone</td></tr>
                    <tr><td>Amount Attempted</td><td class='amount'>RM $money</td></tr>
                    <tr><td>Status</td><td class='amount'>$paidstatus</td></tr>
                </table>
            </div>
            
            </body></html>
            ";
        }
    }
    else 
    {
        //print receipt for failed transaction
         echo "
            <html><head>
            <meta name='viewport' content='width=device-width, initial-scale=1'>
            <link rel='stylesheet' href='https://www.w3schools.com/w3css/4/w3.css'>
            <style>
                body {
                    background-color: #f0f4f8;
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                }
                .topup-card {
                    max-width: 400px;
                    margin: 40px auto;
                    padding: 25px;
                    background-color: #fff;
                    border-radius: 12px;
                    box-shadow: 0 6px 20px rgba(0,0,0,0.1);
                    text-align: center;
                }
                .fail-icon {
                    font-size: 60px;
                    color: #f44336;
                    margin-bottom: 10px;
                }
                h2 {
                    margin: 10px 0 5px 0;
                    color: #333;
                }
                p {
                    color: #555;
                    margin: 5px 0 20px 0;
                }
                .w3-table td, .w3-table th {
                    padding: 12px;
                }
                .amount {
                    font-weight: bold;
                    color: #f44336;
                }
            </style></head>
            <body>
            
            <div class='topup-card'>
                <div class='fail-icon'>✖</div>
                <h2>Top-Up Failed</h2>
                <p>Sorry, your top-up could not be processed.</p>
                
                <table class='w3-table w3-striped w3-bordered w3-small'>
                    <tr><th>Item</th><th>Details</th></tr>
                    <tr><td>Top-Up ID</td><td>$receiptid</td></tr>
                    <tr><td>Name</td><td>$name</td></tr>
                    <tr><td>Email</td><td>$email</td></tr>
                    <tr><td>Phone</td><td>$phone</td></tr>
                    <tr><td>Amount Attempted</td><td class='amount'>RM $money</td></tr>
                    <tr><td>Status</td><td class='amount'>$paidstatus</td></tr>
                </table>
            </div>
            
            </body></html>
        ";
    }
}

?>