import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pawpal/connection.dart';
import 'package:pawpal/models/pet.dart';
import 'package:pawpal/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MainScreen extends StatefulWidget {
  final User? user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  late double width;
  TextEditingController searchController = TextEditingController();
  List<Pet> listPets = [];
  String status = "Loading...";
  DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm a');

  @override
  void initState() {
    super.initState();
    loadPets('');
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    if (width > 400) {
      width = 400;
    } else {
      width = width;
    }
    return Scaffold(
      appBar: AppBar(title: Text('Pet Adoption & Donation')),
      body: Center(
        child: Container(
          width: width,
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // search textfield
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Search',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SizedBox(height: 10),

              // search button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    String search = searchController.text.trim();
                    if (search.isEmpty) {
                      loadPets('');
                    } else {
                      loadPets(search);
                    }
                  },
                  child: Text('Search'),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: listPets.isEmpty
                    // show no submission if empty list
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox, size: 64),
                            Text(
                              'No submissions yet.',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                    // show the list of pets
                    : ListView.builder(
                        itemCount: listPets.length,
                        itemBuilder: (BuildContext context, int index) {
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // First image as thumbnail
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: width * 0.28, // more responsive
                                      height:
                                          width * 0.3, // balanced aspect ratio
                                      color: Colors.grey[200],
                                      child: Image.network(
                                        '${Connection.baseUrl}/pawpal/uploads/pet_${listPets[index].petId}_1.jpg',
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

                                  // Space for display pet name, type, category, and description
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Pet Name
                                        Text(
                                          'Name: ${listPets[index].petName.toString()}',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        // Pet Type
                                        Text(
                                          'Type: ${listPets[index].petType.toString()}',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        // Category
                                        Text(
                                          listPets[index].category.toString(),
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        // Description
                                        Text(
                                          listPets[index].description
                                              .toString(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
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
    );
  }

  // load all pets
  void loadPets(String searchQuery) {
  listPets.clear();
  setState(() {
    status = "Loading...";
  });
  
  String url = '${Connection.baseUrl}/pawpal/api/get_my_pets.php?search=$searchQuery';
  print('🔄 Loading pets from: $url');
  
  http
      .get(
        Uri.parse(url),
      )
      .then((response) {
        print('📡 Response status: ${response.statusCode}');
        print('📡 Response body: ${response.body}');
        
        if (response.statusCode == 200) {
          try {
            var jsonResponse = jsonDecode(response.body);

            if (jsonResponse['success'] == true) {
              // 检查是否有数据
              if (jsonResponse['data'] != null) {
                // 即使数据为空数组，也要处理
                listPets.clear();
                for (var item in jsonResponse['data']) {
                  listPets.add(Pet.fromJson(item));
                }
                
                if (listPets.isEmpty) {
                  setState(() {
                    status = jsonResponse['message'] ?? "No submissions yet";
                  });
                } else {
                  setState(() {
                    status = "";
                  });
                }
              } else {
                // 数据为null
                setState(() {
                  listPets.clear();
                  status = jsonResponse['message'] ?? "No data available";
                });
              }
            } else {
              // API返回success=false
              setState(() {
                listPets.clear();
                status = jsonResponse['message'] ?? "Request failed";
              });
            }
          } catch (e) {
            print('❌ JSON decode error: $e');
            setState(() {
              listPets.clear();
              status = "Error parsing response";
            });
          }
        } else {
          // 请求失败
          setState(() {
            listPets.clear();
            status = "Failed to load pets (HTTP ${response.statusCode})";
          });
        }
      })
      .catchError((error) {
        print('❌ Network error: $error');
        setState(() {
          listPets.clear();
          status = "Network error: ${error.toString()}";
        });
      });
}

  // show all details in dialog using table
  void showDetailsDialog(int index) {
    String formattedDate = formatter.format(
      DateTime.parse(listPets[index].createdDate.toString()),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(listPets[index].petName.toString()),
          content: SizedBox(
            width: width,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    child: Image.network(
                      '${Connection.baseUrl}/pawpal/uploads/pet_${listPets[index].petId}_1.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.broken_image,
                          size: 128,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 10),
                  Table(
                    border: TableBorder.all(
                      color: Colors.grey,
                      width: 1.0,
                      style: BorderStyle.solid,
                    ),
                    columnWidths: {
                      0: FixedColumnWidth(100.0),
                      1: FlexColumnWidth(),
                    },
                    children: [
                      // table row for pet type
                      TableRow(
                        children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Pet Type'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(listPets[index].petType.toString()),
                            ),
                          ),
                        ],
                      ),
                      // table row for category
                      TableRow(
                        children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Category'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(listPets[index].category.toString()),
                            ),
                          ),
                        ],
                      ),
                      // table row for description
                      TableRow(
                        children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Description'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                listPets[index].description.toString(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // table for location with latitude and longitude
                      TableRow(
                        children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Location'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${listPets[index].latitude}, ${listPets[index].longitude}',
                              ),
                            ),
                          ),
                        ],
                      ),
                      // table for date
                      TableRow(
                        children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Date'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(formattedDate),
                            ),
                          ),
                        ],
                      ),
                      // tale for post by whom
                      TableRow(
                        children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Post by'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(listPets[index].userName.toString()),
                            ),
                          ),
                        ],
                      ),
                      // table for poster's phone
                      TableRow(
                        children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Phone'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(listPets[index].userPhone.toString()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  // the way of contact to poster
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () async {
                          await launchUrl(
                            Uri.parse(
                              'tel:${listPets[index].userPhone.toString()}',
                            ),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        icon: Icon(Icons.call),
                      ),
                      IconButton(
                        onPressed: () async {
                          await launchUrl(
                            Uri.parse(
                              'sms:${listPets[index].userPhone.toString()}',
                            ),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        icon: Icon(Icons.message),
                      ),
                      IconButton(
                        onPressed: () async {
                          await launchUrl(
                            Uri.parse(
                              'mailto:${listPets[index].userEmail.toString()}',
                            ),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        icon: Icon(Icons.email),
                      ),
                      IconButton(
                        onPressed: () async {
                          await launchUrl(
                            Uri.parse(
                              'https://wa.me/${listPets[index].userPhone.toString()}',
                            ),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        icon: Icon(Icons.wechat),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}