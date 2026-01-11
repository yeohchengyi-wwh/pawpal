import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pawpal/models/pet.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/connection.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pawpal/frontend/adoptionrequestscreen.dart';
import 'package:pawpal/shared/mydrawer.dart';
import 'package:pawpal/frontend/donationpage.dart';
import 'package:pawpal/frontend/submitpetscreen.dart';
import 'package:pawpal/frontend/editpetpage.dart';

class HomePage extends StatefulWidget {
  final User? user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late double width;
  TextEditingController searchController = TextEditingController();
  String selectedPetType = 'All';
  // Note: Removed "All" from the list effectively to manage logic manually in UI
  List<String> petTypes = ["All", "Cat", "Dog", "Rabbit", "Other"];
  List<Pet> listPets = [];
  String status = "Loading...";
  DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm a');
  bool isLoading = false;

  // Design Constants
  final Color primaryColor = const Color(0xFFFA6650); // A warm pet-friendly color
  final Color backgroundColor = const Color(0xFFF9F9F9);

  @override
  void initState() {
    super.initState();
    loadPets('', '');
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    if (width > 600) width = 600;

    return Scaffold(
      backgroundColor: backgroundColor, // Softer background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find your new friend',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
              'Pet Adoption',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              loadPets('', '');
              searchController.clear();
              setState(() => selectedPetType = 'All');
            },
            icon: Icon(Icons.refresh, color: Colors.black87),
          ),
        ],
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: MyDrawer(user: widget.user),
      body: Center(
        child: Container(
          width: width,
          child: Column(
            children: [
              // 1. Header Section (Search & Filter)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  children: [
                    // Modern Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search pets...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                        ),
                        onChanged: (value) {
                          String filter = selectedPetType;
                          if (filter != 'All') {
                            loadPets(value, selectedPetType);
                          } else if (value.isEmpty) {
                            loadPets('', '');
                          } else {
                            loadPets(value, '');
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 15),
                    // Modern Choice Chips (Horizontal Scroll)
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: petTypes.length,
                        itemBuilder: (context, index) {
                          final type = petTypes[index];
                          final isSelected = selectedPetType == type;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedPetType = type;
                                  String search = searchController.text.trim();
                                  if (type == 'All') {
                                    loadPets('', '');
                                  } else {
                                    loadPets(search, type);
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primaryColor
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? primaryColor
                                        : Colors.grey[300]!,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: primaryColor.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          )
                                        ]
                                      : [],
                                ),
                                child: Center(
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Pet List
              Expanded(
                child: listPets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pets,
                                size: 80, color: Colors.grey[300]),
                            SizedBox(height: 16),
                            Text(
                              status == "Loading..." ? "Finding pets..." : "No pets found",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        itemCount: listPets.length,
                        itemBuilder: (context, index) {
                          return _buildPetCard(listPets[index], index);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        elevation: 4,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubmitPetScreen(user: widget.user),
            ),
          );
        },
        icon: Icon(Icons.add, color: Colors.white),
        label: Text("Post Pet", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- NEW: Custom Pet Card Widget ---
  Widget _buildPetCard(Pet pet, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => showDetailsDialog(index),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Image with Hero Animation feel
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: 110,
                        height: 110,
                        child: Image.network(
                          '${Connection.baseUrl}/pawpal/api/uploads/pet_${pet.petId}_1.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[100],
                              child: Icon(Icons.pets, color: Colors.grey[300]),
                            );
                          },
                        ),
                      ),
                    ),
                    // Status Badge (Adoption/Donation)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          pet.category == 'Adoption' ? 'Adopt' : 'Donate',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(width: 16),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              pet.petName.toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            pet.gender == 'Male' ? Icons.male : Icons.female,
                            color: pet.gender == 'Male' ? Colors.blue : Colors.pink,
                            size: 20,
                          )
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pet.petType.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Tags Row
                      Row(
                        children: [
                          _buildTag(pet.age.toString(), Colors.orange.withOpacity(0.1), Colors.orange),
                          SizedBox(width: 8),
                          // Truncate health status if too long
                          Flexible(child: _buildTag(pet.health.toString(), Colors.green.withOpacity(0.1), Colors.green)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[300]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }


  // --- KEEPING EXISTING LOGIC BELOW ---
  // load all pets
  void loadPets(String searchQuery, String filterQuery) {
    setState(() {
      status = "Loading...";
    });
    http
        .get(
          Uri.parse(
            '${Connection.baseUrl}/pawpal/api/get_my_pets.php?search=$searchQuery&filter=$filterQuery',
          ),
        )
        .then((response) {
          if (response.statusCode == 200) {
            var jsonResponse = jsonDecode(response.body);

            if (jsonResponse['success'] &&
                jsonResponse['data'] != null &&
                jsonResponse['data'].isNotEmpty) {
              listPets.clear();
              for (var item in jsonResponse['data']) {
                listPets.add(Pet.fromJson(item));
              }
              setState(() {
                status = "";
              });
            } else if (jsonResponse['success']) {
              setState(() {
                listPets.clear();
                status = "No pets found.";
              });
            }
          } else {
            setState(() {
              listPets.clear();
              status = "Failed to load pets";
            });
          }
        });
  }

  // show all details in dialog
  void showDetailsDialog(int index) {
    final pet = listPets[index];
    final formattedDate = formatter.format(
      DateTime.parse(pet.createdDate.toString()),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: controller,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 50,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: Image.network(
                              '${Connection.baseUrl}/pawpal/api/uploads/pet_${pet.petId}_1.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: Colors.grey[100], child: Icon(Icons.image, size: 50, color: Colors.grey)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pet.petName.toString(),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87
                                  ),
                                ),
                                Text(
                                  pet.category.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600
                                  ),
                                ),
                              ],
                            ),
                            Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    shape: BoxShape.circle
                                ),
                                child: Icon(pet.gender == 'Male' ? Icons.male : Icons.female, color: pet.gender == 'Male' ? Colors.blue : Colors.pink)
                            )
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildAttributeBox("Age", pet.age.toString()),
                            _buildAttributeBox("Health", pet.health.toString()),
                            _buildAttributeBox("Type", pet.petType.toString()),
                          ],
                        ),

                        const SizedBox(height: 24),
                        Text(
                          "About ${pet.petName}",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          pet.description.toString(),
                          style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.5),
                        ),

                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 10),

                        // Owner Info
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueGrey[100],
                            child: Text(pet.userName![0].toUpperCase()),
                          ),
                          title: Text(pet.userName.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Posted on $formattedDate"),
                        ),
                        
                        SizedBox(height: 100), // 底部留白给按钮
                      ],
                    ),
                  ),

                  // Bottom Action Section
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: widget.user!.userId != pet.userId
                        ? SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: pet.category == 'Adoption' ? primaryColor : Color(0xFFFFD700),
                                foregroundColor: Colors.white,
                                elevation: 5,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                if (pet.category == 'Adoption') {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => AdoptionRequestScreen(user: widget.user, pet: pet)));
                                } else {
                                     Navigator.push(context, MaterialPageRoute(builder: (context) => DonationPage(user: widget.user!, pet: pet)));
                                }
                              },
                              child: Text(
                                pet.category == 'Adoption' ? 'Request to Adopt' : 'Donate Now',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center, 
                            children: [
                              // Edit Icon Button
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => UpdatePetScreen(user: widget.user, pet: listPets[index])));
                                },
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50], // 淡蓝色背景
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.edit, color: Colors.blue, size: 28),
                                ),
                              ),
                              
                              SizedBox(width: 40), // 两个图标之间的间距
                              
                              // Delete Icon Button
                              InkWell(
                                onTap: () => showDeleteDialog(index),
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50], // 淡红色背景
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.delete, color: Colors.red, size: 28),
                                ),
                              ),
                            ],
                          ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildAttributeBox(String label, String value) {
    return Container(
      width: width * 0.25,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  // ... keep existing UI Helper methods like showDeleteDialog, deletePet, etc. ...
   void showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this request?"),
          actions: [
            TextButton(
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                deletePet(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void deletePet(int index) {
    setState(() {
      isLoading = true;
    });
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: primaryColor),
                SizedBox(height: 20),
                Text('Processing...', style: TextStyle(decoration: TextDecoration.none, color: Colors.black, fontSize: 14)),
              ],
            ),
          ),
        );
      },
      barrierDismissible: false,
    );
    http
        .post(
          Uri.parse('${Connection.baseUrl}/pawpal/api/delete_pet.php'),
          body: {
            'userid': widget.user!.userId.toString(),
            'petid': listPets[index].petId.toString(),
          },
        )
        .then((response) {
          if (response.statusCode == 200) {
            var jsonResponse = response.body;
            var resarray = jsonDecode(jsonResponse);
            if (resarray['success']) {
              loadPets('', '');
              if (!mounted) return;
              stopLoading();
              Navigator.pop(context); // close DraggableScrollableShee
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Pet deleted successfully"),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating, // Floating snackbar
                ),
              );
            } else {
              if (!mounted) return;
              stopLoading();
              Navigator.pop(context); // close DraggableScrollableShee
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Pet deletion failed"),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            setState(() {});
          }
        })
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            if (!mounted) return;
            stopLoading();
            Navigator.pop(context); // close DraggableScrollableShee
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Request timed out. Please try again.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
  }

  // close the status of loading on screen
  void stopLoading() {
    if (isLoading) {
      Navigator.pop(context); // Close the loading dialog
      setState(() {
        isLoading = false;
      });
    }
  }
}