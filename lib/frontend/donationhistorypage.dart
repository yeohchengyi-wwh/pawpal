import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pawpal/models/donation.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/connection.dart';
import 'package:pawpal/shared/mydrawer.dart';

class DonationHistoryPage extends StatefulWidget {
  final User? user;
  const DonationHistoryPage({super.key, required this.user});

  @override
  State<DonationHistoryPage> createState() => _DonationHistoryPageState();
}

class _DonationHistoryPageState extends State<DonationHistoryPage> {
  late double width;
  List<Donation> listDonations = [];
  String status = "Loading...";
  DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm a');

  @override
  void initState() {
    super.initState();
    loadDonationHistory();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    if (width > 600) {
      width = 600;
    } else {
      width = width;
    }
    return Scaffold(
      appBar: AppBar(title: Text('Donation History')),
      body: Center(
        child: Container(
          width: width,
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: listDonations.isEmpty
                    // show no donation history if empty list
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.history, size: 64),
                            Text(
                              status,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    // show the list of donations
                    : ListView.builder(
                        itemCount: listDonations.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 10,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // First image as thumbnail
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: width * 0.22, // more responsive
                                        height:
                                            width *
                                            0.2, // balanced aspect ratio
                                        color: Colors.grey[200],
                                        child: Image.network(
                                          '${Connection.baseUrl}/pawpal/api/uploads/pet_${listDonations[index].petId}_1.jpg',
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
                                          // Pet Name
                                          Text(
                                            listDonations[index].petName
                                                .toString(),
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),

                                          // Recipient name or Donor name
                                          Text(
                                            listDonations[index].userId ==
                                                    widget.user!.userId
                                                ? 'Recipient: ${listDonations[index].otherUserName}'
                                                : 'Donor: ${listDonations[index].otherUserName}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),

                                          // Description
                                          Text(
                                            listDonations[index].description
                                                .toString(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),

                                          // Date
                                          Text(
                                            formatter.format(
                                              DateTime.parse(
                                                listDonations[index]
                                                    .donationDate
                                                    .toString(),
                                              ),
                                            ),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Amount minus or add
                                    listDonations[index].amount != '0.00'
                                        ? Text(
                                            listDonations[index].userId ==
                                                    widget.user!.userId
                                                ? '- RM ${double.tryParse(listDonations[index].amount.toString())?.toStringAsFixed(2) ?? '0.00'}'
                                                : '+ RM ${double.tryParse(listDonations[index].amount.toString())?.toStringAsFixed(2) ?? '0.00'}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  listDonations[index].userId ==
                                                      widget.user!.userId
                                                  ? Colors.red
                                                  : Colors.green,
                                            ),
                                          )
                                        : SizedBox(), // null
                                  ],
                                ),
                              ),
                              const Divider(height: 10),
                            ],
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

  // load donation history
  void loadDonationHistory() {
    setState(() {
      status = "Loading...";
    });
    http
        .get(
          Uri.parse(
            '${Connection.baseUrl}/pawpal/api/get_my_donations.php?userid=${widget.user!.userId}',
          ),
        )
        .then((response) {
          if (response.statusCode == 200) {
            var jsonResponse = jsonDecode(response.body);

            if (jsonResponse['success'] &&
                jsonResponse['data'] != null &&
                jsonResponse['data'].isNotEmpty) {
              // has data → load to list
              listDonations.clear();
              for (var item in jsonResponse['data']) {
                listDonations.add(Donation.fromJson(item));
              }

              setState(() {
                status = "";
              });
            } else if (jsonResponse['success']) {
              // success but EMPTY data
              setState(() {
                listDonations.clear();
                status = jsonResponse['message'].toString();
              });
            }
          } else {
            // request failed
            setState(() {
              listDonations.clear();
              status = "Failed to load donations";
            });
          }
        });
  }
}