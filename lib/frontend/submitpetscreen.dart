import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pawpal/models/user.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:pawpal/connection.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/frontend/homepage.dart';

class SubmitPetScreen extends StatefulWidget {
  final User? user;
  const SubmitPetScreen({super.key, required this.user});

  @override
  State<SubmitPetScreen> createState() => _SubmitPetScreenState();
}

class _SubmitPetScreenState extends State<SubmitPetScreen> {
  late double width;
  TextEditingController petNameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  List<String> petTypes = ["Cat", "Dog", "Rabbit", "Other"];
  List<String> gender = ["Male", "Female", "Both"];
  List<String> categories = ["Adoption", "Donation Request", "Help/Rescue"];
  List<String> health = ["Healthy", "Critical", "Unknown"];
  String selectedPetType = "Other",
      selectedGender = "Male",
      selectedCategory = "Adoption",
      selectedHealth = "Healthy";
  late Position position;
  double? lat, lng;
  List<Uint8List?> webImages = [null, null, null];
  List<File?> images = [null, null, null];
  String? petNameError, ageError, descriptionError, locationError, imageError;
  bool isLoading = false;

  // New Design Colors
  final Color primaryColor = const Color(0xFFFA6650);
  final Color backgroundColor = const Color(0xFFF9F9F9);
  final Color labelColor = Colors.grey[700]!;

  // Helper for label styles
  TextStyle get _labelStyle =>
      TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: labelColor);

  // Helper for Input Decorations to keep consistent style
  InputDecoration _inputDecoration(
    String label, {
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
      errorText: errorText,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: Colors.grey[400])
          : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.grey[300]!), // Softer border
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(
          color: primaryColor,
          width: 1.5,
        ), // Highlight color
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.red, width: 1.5),
      ),
    );
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
      backgroundColor: backgroundColor, // Soft background color
      appBar: AppBar(
        title: Text(
          'Pet Submission Form',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: width,
            padding: EdgeInsets.all(15), // Increased padding slightly
            margin: EdgeInsets.all(10),
            child: Column(
              children: [
                // logo (Added rounded corners and shadow for better look)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset('assets/images/petForm.jpeg', scale: 3),
                  ),
                ),
                const SizedBox(height: 30),

                // pet name
                Row(
                  children: [
                    Text('Pet Name', style: _labelStyle),
                    SizedBox(width: 15),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: petNameController,
                        decoration: _inputDecoration(
                          'Pet Name',
                          prefixIcon: Icons.edit,
                          errorText: petNameError,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                Row(
                  children: [
                    // pet type
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedPetType,
                        decoration: _inputDecoration('Pet Type'),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey[400],
                        ),
                        items: petTypes.map((String selectedPetType) {
                          return DropdownMenuItem<String>(
                            value: selectedPetType,
                            child: Text(selectedPetType),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedPetType = newValue!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    // gender
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: selectedGender,
                        decoration: _inputDecoration('Gender'),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey[400],
                        ),
                        items: gender.map((String selectedGender) {
                          return DropdownMenuItem<String>(
                            value: selectedGender,
                            child: Text(selectedGender),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedGender = newValue!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    // age
                    Expanded(
                      child: TextField(
                        controller: ageController,
                        decoration: _inputDecoration(
                          'Age',
                          errorText: ageError,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                // category
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        decoration: _inputDecoration('Category'),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey[400],
                        ),
                        items: categories.map((String selectedCategory) {
                          return DropdownMenuItem<String>(
                            value: selectedCategory,
                            child: Text(
                              selectedCategory,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCategory = newValue!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedHealth,
                        decoration: _inputDecoration('Health'),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey[400],
                        ),
                        items: health.map((String selectedHealth) {
                          return DropdownMenuItem<String>(
                            value: selectedHealth,
                            child: Text(
                              selectedHealth,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedHealth = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                // description
                Row(
                  crossAxisAlignment: CrossAxisAlignment
                      .start, // Align label to top for multiline
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 15,
                      ), // Center label vertically roughly
                      child: Text('Description', style: _labelStyle),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: TextField(
                        maxLines: 3,
                        controller: descriptionController,
                        decoration: _inputDecoration(
                          'Description',
                          prefixIcon: Icons.description,
                          errorText: descriptionError,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                // location
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text('Location', style: _labelStyle),
                    ),
                    SizedBox(width: 26),
                    Expanded(
                      child: TextField(
                        maxLines: 3,
                        controller: locationController,
                        keyboardType:
                            TextInputType.multiline, // Changed for address
                        decoration: _inputDecoration(
                          'Location',
                          prefixIcon: Icons.location_on,
                          errorText: locationError,
                          suffixIcon: IconButton(
                            onPressed: () async {
                              // ... (keep your existing logic) ...
                              position = await _determinePosition();
                              lat = position.latitude;
                              lng = position.longitude;
                              List<Placemark> placemarks =
                                  await placemarkFromCoordinates(
                                    position.latitude,
                                    position.longitude,
                                  );
                              Placemark place = placemarks[0];
                              locationController.text =
                                  "${place.name},\n${place.postalCode},${place.locality},\n${place.administrativeArea},${place.country}";
                              setState(() {});
                            },
                            icon: Icon(
                              Icons.location_searching,
                              color: primaryColor,
                            ), // Colored icon
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                // image upload maximum up to 3
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text('Image\n(Max 3)', style: _labelStyle),
                    ),
                    SizedBox(width: 33),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _buildImageUploadBox(0)),
                          SizedBox(width: 10),
                          Expanded(child: _buildImageUploadBox(1)),
                          SizedBox(width: 10),
                          Expanded(child: _buildImageUploadBox(2)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (imageError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      imageError!,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50, // Taller button
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor, // Use theme color
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      submitValidation();
                    },
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for Image Boxes to reduce code duplication and apply new style
  Widget _buildImageUploadBox(int index) {
    bool hasImage =
        (images[index] != null && !kIsWeb) || (webImages[index] != null);
    return GestureDetector(
      onTap: () {
        // ... (keep your existing tap logic) ...
        setState(() {
          imageError = null;
        });
        if (index == 0) {
          if (kIsWeb)
            openGallery(0);
          else
            pickimagedialog(0);
        } else if (index == 1) {
          if (images[0] != null || webImages[0] != null) {
            if (kIsWeb)
              openGallery(1);
            else
              pickimagedialog(1);
          } else {
            setState(() => imageError = 'Please click on the first one');
          }
        } else if (index == 2) {
          if (images[1] != null || webImages[1] != null) {
            if (kIsWeb)
              openGallery(2);
            else
              pickimagedialog(2);
          } else if (images[0] == null && webImages[0] == null) {
            setState(() => imageError = 'Please click on the first one');
          } else {
            setState(() => imageError = 'Please click on the second one');
          }
        }
      },
      child: Container(
        height: 95,
        decoration: BoxDecoration(
          color: Colors.white, // White background for boxes
          border: Border.all(
            color:
                imageError != null &&
                    index == 0 &&
                    !hasImage // Only show red on first if error exists
                ? Colors.red
                : (hasImage
                      ? primaryColor
                      : Colors
                            .grey[300]!), // Highlight if has image, else soft grey
            width: hasImage ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
          image: hasImage
              ? DecorationImage(
                  image: (!kIsWeb)
                      ? FileImage(images[index]!) as ImageProvider
                      : MemoryImage(webImages[index]!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: !hasImage
            ? Center(
                child: Icon(
                  Icons.add_a_photo, // Changed icon
                  size: 30,
                  color: Colors.grey[400],
                ),
              )
            : null,
      ),
    );
  }

  // ... (Keep all your existing logic functions: _determinePosition, pickimagedialog, openCamera, openGallery, cropImage, submitValidation) ...

  // ... (Keep submitPet logic, but update the progress indicator color) ...
  void submitPet(
    String petName,
    String petType,
    String gender,
    String age,
    String category,
    String health,
    String description,
    String lat,
    String lng,
    List<String?> base64images,
  ) {
    setState(() {
      isLoading = true;
    });
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(
                color: primaryColor,
              ), // Use primary color
              SizedBox(width: 20),
              Text('Loading...'),
            ],
          ),
        );
      },
      barrierDismissible: false,
    );
    // ... (rest of the submitPet function) ...
    http
        .post(
          Uri.parse('${Connection.baseUrl}/pawpal/api/submit_pet.php'),
          body: {
            'userid': widget.user?.userId!,
            'petname': petName,
            'pettype': petType,
            'gender': gender,
            'age': age,
            'category': category,
            'health': health,
            'description': description,
            'latitude': lat,
            'longitude': lng,
            'images': jsonEncode(base64images),
          },
        )
        .then((response) {
          if (response.statusCode == 200) {
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
                  content: Text("Submit failed: ${resarray['message']}"),
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
            stopLoading();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Request timed out. Please try again.'),
              ),
            );
          },
        );
  }

  // auto obtain the current location of the user
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  // choose the image source
  void pickimagedialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pick Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: primaryColor),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  openCamera(index);
                },
              ),
              ListTile(
                leading: Icon(Icons.image, color: primaryColor),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  openGallery(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // open the camera to capture image
  Future<void> openCamera(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      if (kIsWeb) {
        webImages[index] = await pickedFile.readAsBytes();
        setState(() {});
      } else {
        File imageFile = File(pickedFile.path);
        cropImage(index, imageFile);
      }
    }
  }

  // open gallery to select image
  Future<void> openGallery(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        webImages[index] = await pickedFile.readAsBytes();
        setState(() {});
      } else {
        File imageFile = File(pickedFile.path);
        cropImage(index, imageFile); // only for mobile
      }
    }
  }

  // crop the image
  Future<void> cropImage(int index, File image) async {
    if (kIsWeb) return; // skip cropping on web
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: CropAspectRatio(ratioX: 3, ratioY: 3),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Please Crop Your Image',
          toolbarColor: primaryColor, // Changed color
          toolbarWidgetColor: Colors.white,
        ),
        IOSUiSettings(title: 'Cropper'),
      ],
    );

    if (croppedFile != null) {
      image = File(croppedFile.path);
      // save image in list
      if (index == 0) images[0] = image;
      if (index == 1) images[1] = image;
      if (index == 2) images[2] = image;
      imageError = null;
      setState(() {});
    }
  }

  // validate all fields for submission
  void submitValidation() {
    String petName = petNameController.text.trim();
    String petType = selectedPetType;
    String gender = selectedGender;
    String age = ageController.text.trim();
    String category = selectedCategory;
    String health = selectedHealth;
    String description = descriptionController.text.trim();
    String location = locationController.text.trim();

    List<String> base64images = [];

    setState(() {
      petNameError = null;
      ageError = null;
      descriptionError = null;
      locationError = null;
      imageError = null;
    });

    if (widget.user == null) {
      stopLoading();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("User not logged in")));
      return;
    }
    if (petName.isEmpty) {
      setState(() {
        petNameError = "Required field";
      });
      return;
    }
    if (ageController.text.trim().isEmpty) {
      setState(() {
        ageError = "Required field";
      });
      return;
    }

    if (description.isEmpty) {
      setState(() {
        descriptionError = "Required field";
      });
      return;
    }
    if (description.length < 10) {
      setState(() {
        descriptionError = "Description must be at least 10 characters";
      });
      return;
    }
    if (location.isEmpty) {
      setState(() {
        locationError = "Required field";
      });
      return;
    }
    if (lat == null || lng == null) {
      setState(() {
        locationError = "Please obtain location";
      });
      return;
    }
    if (kIsWeb) {
      for (int i = 0; i < 3 && webImages[i] != null; i++) {
        base64images.add(base64Encode(webImages[i]!));
      }
    } else {
      if (images[0] == null) {
        setState(() {
          imageError = "Please select at least one image";
        });
        return;
      }
      for (int i = 0; i < 3 && images[i] != null; i++) {
        base64images.add(base64Encode(images[i]!.readAsBytesSync()));
      }
    }

    // show submit confirmation dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Text('Are you sure you want to submit?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                submitPet(
                  petName,
                  petType,
                  gender,
                  age,
                  category,
                  health,
                  description,
                  lat.toString(),
                  lng.toString(),
                  base64images,
                );
              },
              child: Text('Submit', style: TextStyle(color: primaryColor)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
          ],
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
}
