import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/connection.dart';
import 'package:pawpal/shared/mydrawer.dart';
import 'package:pawpal/frontend/paymentpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfilePage extends StatefulWidget {
  User user;
  UserProfilePage({super.key, required this.user});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late double width;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  File? image;
  Uint8List? webImage, savedAvatar;
  String? nameError, phoneError;
  bool isLoading = false;
  DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  final Color primaryColor = const Color(0xFFFA6650);
  final Color backgroundColor = const Color(0xFFF9F9F9);
  
  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
    loadProfile();
  }

  void _loadUserPreferences() {
    SharedPreferences.getInstance().then((prefs) {
      String? base64image = prefs.getString('user_image');
      String? name = prefs.getString('name');
      String? phone = prefs.getString('phone');
      if (base64image != null && base64image.isNotEmpty) {
        savedAvatar = base64Decode(base64image);
      }
      nameController.text = name ?? widget.user.userName.toString();
      phoneController.text = phone ?? widget.user.userPhone.toString();
      setState(() {});
    });
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 16,

        title: const Text(
          "My Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            onPressed: () {
              loadProfile();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // 1. HEADER SECTION (User Image + Email)
                  _buildProfileHeader(),

                  const SizedBox(height: 25),

                  Container(
                    width: width,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // 2. WALLET CARD
                        _buildWalletCard(),

                        const SizedBox(height: 25),

                        // 3. EDIT FORM SECTION
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Personal Information",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        _buildTextField(
                          controller: nameController,
                          label: "Full Name",
                          icon: Icons.person_outline,
                          error: nameError,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: phoneController,
                          label: "Phone Number",
                          icon: Icons.phone_outlined,
                          error: phoneError,
                          keyboard: TextInputType.phone,
                        ),

                        const SizedBox(height: 30),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _updateProfile,
                            child: const Text(
                              "Save Changes",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Footer Info
                        Text(
                          "Member since ${dateFormat.format(DateTime.parse(widget.user.userRegdate ?? DateTime.now().toString()))}",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // LOADING OVERLAY
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
      drawer: MyDrawer(user: widget.user),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildProfileHeader() {
    ImageProvider? backgroundImage;

    // Logic to determine image source
    if (savedAvatar != null) {
      backgroundImage = MemoryImage(savedAvatar!);
    } else if (kIsWeb && webImage != null) {
      backgroundImage = MemoryImage(webImage!);
    } else if (image != null) {
      backgroundImage = FileImage(image!);
    } else if (widget.user.userImage != null) {
      backgroundImage = NetworkImage(
        '${Connection.baseUrl}/pawpal/server/uploads/profile/user_${widget.user.userId}.png',
      );
    }

    return Column(
      children: [
        GestureDetector(
          onTap: pickimagedialog,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: backgroundImage,
                  child: backgroundImage == null
                      ? Text(
                          widget.user.userName?.substring(0, 1).toUpperCase() ??
                              "U",
                          style: TextStyle(
                            fontSize: 40,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
              // Camera Badge
              Positioned(
                bottom: 0,
                right: 4,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Text(
          widget.user.userEmail ?? "No Email",
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildWalletCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: primaryColor,
                        size: 20,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "My Wallet",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'RM ${double.parse(widget.user.userWallet.toString()).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: showTopUpDialog,
                child: Text("Top Up"),
              ),
            ],
          ),
          SizedBox(height: 15),
          Divider(color: Colors.grey[100]),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.grey[400]),
              SizedBox(width: 5),
              Text(
                "Funds are used for donations",
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? error,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: TextStyle(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          errorText: error,
          prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryColor, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  // ================= HELPERS & LOGIC =================

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
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                "Top Up Wallet",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select amount",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<double>(
                    value: selectedTopUp,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: topUpPriceMap.map((double money) {
                      return DropdownMenuItem<double>(
                        value: money,
                        child: Text(
                          "RM ${money.toStringAsFixed(2)}",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setDialogState(() => selectedTopUp = value!),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.all(16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                    }
                    loadProfile();
                  },
                  child: const Text(
                    "Proceed",
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

  void loadProfile() {
    http
        .get(
          Uri.parse(
            '${Connection.baseUrl}/pawpal/api/get_user_details.php?userid=${widget.user.userId}',
          ),
        )
        .then((response) {
          if (response.statusCode == 200) {
            var jsonResponse = response.body;
            var resarray = jsonDecode(jsonResponse);
            if (resarray['success']) {
              User user = User.fromJson(resarray['data'][0]);
              widget.user = user;
              setState(() {});
            }
          }
        });
  }

  // choose image source
  void pickimagedialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: 160,
          child: Column(
            children: [
              Text(
                "Change Profile Photo",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSourceOption(Icons.camera_alt, "Camera", () {
                    Navigator.pop(context);
                    openCamera();
                  }),
                  _buildSourceOption(Icons.photo_library, "Gallery", () {
                    Navigator.pop(context);
                    openGallery();
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSourceOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[100],
            child: Icon(icon, color: primaryColor),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // open camera to get image
  Future<void> openCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      if (kIsWeb) {
        webImage = await pickedFile.readAsBytes();
        setState(() {});
      } else {
        image = File(pickedFile.path);
        cropImage();
      }
    }
  }

  // open gallery to get image
  Future<void> openGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        webImage = await pickedFile.readAsBytes();
        setState(() {});
      } else {
        image = File(pickedFile.path);
        cropImage(); // only for mobile
      }
    }
  }

  // crop the selected image
  Future<void> cropImage() async {
    if (kIsWeb) return; // skip cropping on web
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image!.path,
      aspectRatio: CropAspectRatio(
        ratioX: 1,
        ratioY: 1,
      ), // Profile should be square
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Edit Photo',
          toolbarColor: primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(title: 'Cropper'),
      ],
    );
    if (croppedFile != null) {
      image = File(croppedFile.path);
      setState(() {});
    }
  }

  // update profile
  Future<void> _updateProfile() async {
    String base64image = "";
    if (kIsWeb) {
      base64image = base64Encode(webImage!);
    } else if (image != null) {
      base64image = base64Encode(image!.readAsBytesSync());
    }
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();

    setState(() {
      nameError = null;
      phoneError = null;
    });

    if (name.isEmpty) {
      setState(() => nameError = 'Name is required');
      return;
    }
    if (phone.isEmpty) {
      setState(() => phoneError = 'Phone is required');
      return;
    }

    setState(() => isLoading = true);

    await http
        .post(
          Uri.parse('${Connection.baseUrl}/pawpal/api/update_userprofile.php'),
          body: {
            'userid': widget.user.userId,
            'user_image': base64image,
            'username': name,
            'userphone': phone,
          },
        )
        .then((response) {
          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);
            if (data['success']) {
              savePreferences(base64image);
              loadProfile();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Profile updated successfully"),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(data['message'] ?? "Update failed"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        })
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Request timed out. Please try again.'),
              ),
            );
          },
        );

    loadProfile();
    setState(() => isLoading = false);
  }

  void savePreferences(String base64image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (base64image.isNotEmpty) prefs.setString('user_image', base64image);
    prefs.setString('name', nameController.text.trim());
    prefs.setString('phone', phoneController.text.trim());
  }
}
