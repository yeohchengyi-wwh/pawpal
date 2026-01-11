import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pawpal/models/adoption.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/connection.dart';
import 'package:pawpal/shared/mydrawer.dart';

class AdoptionPage extends StatefulWidget {
  final User? user;
  const AdoptionPage({super.key, required this.user});

  @override
  State<AdoptionPage> createState() => _AdoptionPageState();
}

class _AdoptionPageState extends State<AdoptionPage> {
  late double width;
  List<Adoption> listAdoptions = [];
  String status = "Loading...";
  DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm a');
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadAdoptions(widget.user!.userId.toString());
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    if (width > 600) {
      width = 600;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Adoption Request')),
      body: Center(
        child: Container(
          width: width,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: listAdoptions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.request_page, size: 64),
                            Text(
                              status,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: listAdoptions.length,
                        itemBuilder: (BuildContext context, int index) {
                          final adoption = listAdoptions[index];
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Pet Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: width * 0.28,
                                      height: width * 0.26,
                                      color: Colors.grey[200],
                                      child: Image.network(
                                        '${Connection.baseUrl}/pawpal/api/uploads/pet_${adoption.petId}_1.jpg',
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.broken_image,
                                            size: 60,
                                            color: Colors.grey,
                                          );
                                        },
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Pet ID (No Name available in model)
                                        Text(
                                          "Pet ID: ${adoption.petId}",
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),

                                        // User ID (No User Name available in model)
                                        Text(
                                          adoption.userId == widget.user!.userId
                                              ? 'My Request'
                                              : 'User ID: ${adoption.userId}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),

                                        // Date
                                        if (adoption.requestDate != null)
                                          Text(
                                            formatter.format(DateTime.parse(
                                                adoption.requestDate!)),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        
                                        // Status badge removed as 'status' is not in model
                                      ],
                                    ),
                                  ),

                                  IconButton(
                                    onPressed: () {
                                      showDetailsDialog(index);
                                    },
                                    icon: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      drawer: MyDrawer(user: widget.user),
    );
  }

  void loadAdoptions(String userId) {
    setState(() {
      status = "Loading...";
    });
    http
        .get(
      Uri.parse(
        '${Connection.baseUrl}/pawpal/api/get_my_adoptions.php?userid=$userId',
      ),
    )
        .then((response) {
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] &&
            jsonResponse['data'] != null &&
            jsonResponse['data'].isNotEmpty) {
          listAdoptions.clear();
          for (var item in jsonResponse['data']) {
            listAdoptions.add(Adoption.fromJson(item));
          }

          setState(() {
            status = "";
          });
        } else if (jsonResponse['success']) {
          setState(() {
            listAdoptions.clear();
            status = jsonResponse['message'].toString();
          });
        }
      } else {
        setState(() {
          listAdoptions.clear();
          status = "Failed to load adoptions";
        });
      }
    });
  }

  void showDetailsDialog(int index) {
    final adoption = listAdoptions[index];
    String formattedDate = "-";
    if (adoption.requestDate != null) {
      formattedDate = formatter.format(DateTime.parse(adoption.requestDate!));
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6, // Adjusted size since content is less
          minChildSize: 0.4,
          maxChildSize: 0.8,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // DRAG HANDLE
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // IMAGE
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: AspectRatio(
                        aspectRatio: 5 / 3,
                        child: Image.network(
                          '${Connection.baseUrl}/pawpal/api/uploads/pet_${adoption.petId}_1.jpg',
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

                    const SizedBox(height: 16),

                    // Pet Header (Using ID)
                    Text(
                      "Pet #${adoption.petId}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),
                    const Divider(),

                    // Details Header
                    Text(
                      adoption.userId == widget.user!.userId
                          ? 'Request Details'
                          : 'Adopter Details',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // INFO SECTION
                    Column(
                      children: [
                        _infoRow("Adoption ID", adoption.adoptionId),
                        _infoRow("User ID", adoption.userId),
                        _infoRow("Contact Info", adoption.contactInfo),
                        _infoRow("Requested On", formattedDate),
                        const Divider(),
                        // Using reasonAdopt from your updated model
                        _infoRow("Reason", adoption.reasonAdopt), 
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Approve/Reject Buttons REMOVED
                    // Reason: 'status' field is not in the model, so we cannot 
                    // determine if the request is pending or process updates.
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // UI Helper
  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(child: Text(value ?? "-")),
        ],
      ),
    );
  }

  // updateAdoptionRequest removed because 'status' is not in the model.
  // stopLoading removed as it is not used.
}