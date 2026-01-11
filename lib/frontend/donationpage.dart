import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/frontend/homepage.dart';
import 'package:pawpal/models/pet.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/connection.dart';
import 'package:pawpal/frontend/paymentpage.dart';

// ignore: must_be_immutable
class DonationPage extends StatefulWidget {
  User user;
  Pet pet;
  DonationPage({super.key, required this.user, required this.pet});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  late double width;
  List<String> donationType = ['Food', 'Medical', 'Money'];
  String selectedDonation = 'Food';
  TextEditingController descController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  String? descError, amountError;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserWallet();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    if (width > 600) {
      width = 600;
    } else {
      width = width;
    }
    
    double walletBalance = double.tryParse(widget.user.userWallet.toString()) ?? 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Donation Form')),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: width,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: const [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "My Wallet",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Wallet value
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'RM ${walletBalance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F3C88),
                            ),
                          ),
                          const Spacer(),

                          // Top Up button
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(
                              Icons.add,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Top Up",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              showTopUpDialog();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 40),

                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: width * 0.9,
                    child: AspectRatio(
                      aspectRatio: 5 / 3,
                      child: Image.network(
                        '${Connection.baseUrl}/pawpal/api/uploads/pet_${widget.pet.petId}_1.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.broken_image,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Donation Type
                DropdownButtonFormField<String>(
                  value: selectedDonation,
                  decoration: InputDecoration(
                    labelText: 'Donation Type',
                    prefixIcon: const Icon(Icons.handshake),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: donationType.map((String selectedDonation) {
                    return DropdownMenuItem<String>(
                      value: selectedDonation,
                      child: Text(selectedDonation),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDonation = newValue!;
                      amountError = null;
                      descError = null;
                    });
                  },
                ),
                const SizedBox(height: 10),

                // Amount
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  enabled: selectedDonation == 'Money',
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    hintText: 'XXX.XX',
                    prefixIcon: const Icon(Icons.money),
                    errorText: amountError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Description
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    errorText: descError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                // Donate button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      donateDialog();
                    },
                    child: const Text('Donate'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // load user wallet
  void loadUserWallet() {
    http
        .get(
          Uri.parse(
            '${Connection.baseUrl}/pawpal/api/get_user_details.php?userid=${widget.user.userId}',
          ),
        )
        .then((response) {
          if (response.statusCode == 200) {
            var jsonResponse = response.body;
            try {
              var resarray = jsonDecode(jsonResponse);
              if (resarray['success']) {
                User user = User.fromJson(resarray['data'][0]);
                setState(() {
                  widget.user = user;
                });
              }
            } catch (e) {
              print("Error parsing wallet data: $e");
            }
          }
        });
  }

  void donateDialog() {
    String donationType = selectedDonation;
    String description = descController.text.trim();
    String amountText = amountController.text.trim();
    double amount = double.tryParse(amountText) ?? 0;
    double currentWallet = double.tryParse(widget.user.userWallet.toString()) ?? 0.0;

    setState(() {
      descError = null;
      amountError = null;
    });

    // Amount validation
    if (donationType == 'Money') {
      if (amountText.isEmpty || amount <= 0) {
        setState(() {
          amountError = "Please enter a valid amount";
        });
        return;
      }

      if (amount > currentWallet) {
        setState(() {
          amountError = "Not enough amount";
        });
        return;
      }
    }

    // Description validation
    if (description.isEmpty) {
      setState(() {
        descError = "Please enter description";
      });
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Text('Are you sure you want to donate?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (donationType == 'Money') {
                  Navigator.of(context).pop();
                  submitDonate(
                    donationType,
                    amount.toStringAsFixed(2),
                    description,
                  );
                } else {
                  Navigator.of(context).pop();
                  submitDonate(donationType, '0.00', description);
                }
              },
              child: const Text('Sure'),
            ),
          ],
        );
      },
    );
  }

  void submitDonate(String donationType, String amount, String description) {
    setState(() {
      isLoading = true;
    });
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Loading...'),
            ],
          ),
        );
      },
      barrierDismissible: false,
    );

    http
        .post(
          Uri.parse('${Connection.baseUrl}/pawpal/api/submit_donations.php'),
          body: {
            'userid': widget.user.userId.toString(), 
            'petid': widget.pet.petId.toString(),    
            'donationType': donationType,
            'amount': amount,
            'description': description,
          },
        )
        .then((response) {
          if (response.statusCode == 200) {
            try {
              var jsonResponse = response.body;
              var resarray = jsonDecode(jsonResponse);
              if (resarray['success']) {
                if (!mounted) return;
                stopLoading();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(user: widget.user),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${resarray['message']}"),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                if (!mounted) return;
                stopLoading();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Donate failed: ${resarray['message']}"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } catch (e) {
              if (!mounted) return;
              stopLoading();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Error parsing response"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else {
             if (!mounted) return;
             stopLoading();
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Server error: ${response.statusCode}"),
                  backgroundColor: Colors.red,
                ),
             );
          }
        })
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            if (!mounted) return;
            stopLoading();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Request timed out. Please try again.'),
              ),
            );
          },
        );
  }

  // close the status of loading on screen
  void stopLoading() {
    if (isLoading) {
      Navigator.of(context).pop(); // Close the loading dialog
      setState(() {
        isLoading = false;
      });
    }
  }

  void showTopUpDialog() {
    double selectedTopUp = 10.00;

    List<double> topUpPriceMap = [
      5.00,
      10.00,
      15.00,
      20.00,
      30.00,
      40.00,
      50.00,
      100.00,
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: const [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 8),
                  Text("Top Up"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select a top up package",
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),

                  // DROPDOWN
                  DropdownButtonFormField<double>(
                    value: selectedTopUp,
                    decoration: InputDecoration(
                      labelText: "Top Up Amount",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: topUpPriceMap.map((double money) {
                      return DropdownMenuItem<double>(
                        value: money,
                        child: Text("RM ${money.toStringAsFixed(2)}"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedTopUp = value!;
                      });
                    },
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    if (widget.user != null) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentPage(
                            user: widget.user,
                            money: double.parse(
                              selectedTopUp.toStringAsFixed(2),
                            ),
                          ),
                        ),
                      );
                      loadUserWallet();
                    }
                  },
                  child: const Text(
                    "Next",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}