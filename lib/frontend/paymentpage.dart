import 'package:flutter/material.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/connection.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentPage extends StatefulWidget {
  final User? user;
  final double money;
  const PaymentPage({super.key, required this.user, required this.money});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {

  late WebViewController _webcontroller;
  late double screenHeight, screenWidth, resWidth;
  late String userName, userEmail, userPhone, userID;

  @override
  void initState() {
    super.initState();
    userEmail = widget.user!.userEmail.toString();
    userPhone = widget.user!.userPhone.toString();
    userName = widget.user!.userName.toString();
    userID = widget.user!.userId.toString();
    
    super.initState();
    _webcontroller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(
          '${Connection.baseUrl}/pawpal/api/payment.php?email=$userEmail&phone=$userPhone&userid=$userID&name=$userName&money=${widget.money}',
        ),
      );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: const Color(0xFF1F3C88),
      ),
      body: WebViewWidget(controller: _webcontroller),
    );
  }
}
