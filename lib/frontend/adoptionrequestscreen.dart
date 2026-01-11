import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/models/pet.dart';
import 'package:pawpal/connection.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/frontend/homepage.dart';

class AdoptionRequestScreen extends StatefulWidget {
  final User? user;
  final Pet? pet;
  const AdoptionRequestScreen({
    super.key,
    required this.user,
    required this.pet,
  });

  @override
  State<AdoptionRequestScreen> createState() => _AdoptionRequestScreenState();
}

class _AdoptionRequestScreenState extends State<AdoptionRequestScreen> {
  late double width;
  
  TextEditingController reasonController = TextEditingController();
  TextEditingController contactInfoController = TextEditingController(); //Contact Info
  
  String? reasonError;
  String? contactInfoError; 
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    if (width > 600) {
      width = 600;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Adoption Application')),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: width,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pet Image Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      '${Connection.baseUrl}/pawpal/api/uploads/pet_${widget.pet!.petId}_1.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.pets, size: 50, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text("No Image Available",
                                style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Owner Info Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue.shade200,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pet Owner',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.pet?.userName ?? 'Unknown',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                widget.pet?.userEmail ?? '-',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  "Your Application",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Contact Info Input
                TextField(
                  controller: contactInfoController,
                  decoration: InputDecoration(
                    labelText: 'Contact Information',
                    hintText: 'Phone number or Email for owner to reach you',
                    errorText: contactInfoError,
                    prefixIcon: const Icon(Icons.contact_phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),

                const SizedBox(height: 16),

                // Reason Input
                TextField(
                  controller: reasonController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Why do you want to adopt?',
                    hintText: 'Tell us about yourself and your home...',
                    errorText: reasonError,
                    prefixIcon: const Icon(Icons.edit_note),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: showRequestDialog,
                    child: const Text(
                      'Submit Request',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showRequestDialog() {
    String petId = widget.pet!.petId.toString();
    String userId = widget.user!.userId.toString();
    String contactInfo = contactInfoController.text.trim();
    String reason = reasonController.text.trim();

    setState(() {
      reasonError = null;
      contactInfoError = null;
    });

    bool isValid = true;

    if (contactInfo.isEmpty) {
      setState(() {
        contactInfoError = "Required field";
      });
      isValid = false;
    }

    if (reason.isEmpty) {
      setState(() {
        reasonError = "Required field";
      });
      isValid = false;
    } else if (reason.length < 5) {
      setState(() {
        reasonError = "Reason must be at least 5 characters";
      });
      isValid = false;
    }

    if (!isValid) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Confirm Submission'),
          content: const Text('Are you sure you want to send this adoption request?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(context);
                // Call submit with correct parameters
                submitRequest(petId, userId, contactInfo, reason);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void submitRequest(
    String petId,
    String userId,
    String contactInfo,
    String reason,
  ) {
    setState(() {
      isLoading = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Submitting...'),
            ],
          ),
        );
      },
    );

    http
        .post(
      Uri.parse(
        '${Connection.baseUrl}/pawpal/api/submit_adoption_request.php',
      ),
      body: {
        'petid': petId,
        'userid': userId,
        'contact_info': contactInfo,
        'reason_adopt': reason,
      },
    )
        .then((response) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
      }

      if (response.statusCode == 200) {
        try {
          var jsonResponse = response.body;
          var resarray = jsonDecode(jsonResponse);
          if (resarray['success']) {
            if (!mounted) return;
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("${resarray['message']}"),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(user: widget.user),
              ),
            );
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Submit failed: ${resarray['message']}"),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Error parsing response"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Server error: ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }).catchError((error) {
       if (mounted) {
        Navigator.pop(context); // Close loading dialog
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Network Error. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }
}