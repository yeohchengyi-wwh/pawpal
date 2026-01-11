import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pawpal/connection.dart';
import 'package:pawpal/frontend/homepage.dart';
import 'package:pawpal/models/pet.dart';
import 'package:pawpal/models/user.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;

class UpdatePetScreen extends StatefulWidget {
  final User? user;
  final Pet? pet;
  const UpdatePetScreen({super.key, required this.user, required this.pet});

  @override
  State<UpdatePetScreen> createState() => _UpdatePetScreenState();
}

class _UpdatePetScreenState extends State<UpdatePetScreen> {
  late double width;
  TextEditingController petNameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  List<String> petTypes = ["Cat", "Dog", "Rabbit", "Other"];
  List<String> gender = ["Male", "Female"];
  List<String> categories = ["Adoption", "Donation Request", "Help/Rescue"];
  List<String> health = ["Healthy", "Critical", "Unknown"];
  String selectedPetType = "Other",
      selectedGender = "Male",
      selectedCategory = "Adoption",
      selectedHealth = "Healthy";
  late Position position;
  late double lat, lng;
  List<Uint8List?> webImages = [null, null, null];
  List<File?> images = [null, null, null];
  String? petNameError, ageError, descriptionError, locationError, imageError;
  bool isLoading = false;

  // Theme Colors (Consistent with SubmitPetScreen)
  final Color primaryColor = const Color(0xFFFA6650);
  final Color backgroundColor = const Color(0xFFF9F9F9);
  final Color labelColor = Colors.grey[700]!;

  @override
  void initState() {
    super.initState();
    _loadPet();
  }

  // load selected pet
  void _loadPet() async {
    petNameController.text = widget.pet!.petName ?? '';
    
    // Ensure values exist in list before setting, fallback to default if not
    if (petTypes.contains(widget.pet!.petType)) {
      selectedPetType = widget.pet!.petType!;
    }
    if (gender.contains(widget.pet!.gender)) {
      selectedGender = widget.pet!.gender!;
    }
    if (categories.contains(widget.pet!.category)) {
      selectedCategory = widget.pet!.category!;
    }
    if (health.contains(widget.pet!.health)) {
      selectedHealth = widget.pet!.health!;
    }

    ageController.text = widget.pet!.age ?? '';
    descriptionController.text = widget.pet!.description ?? '';
    lat = double.tryParse(widget.pet!.latitude.toString()) ?? 0.0;
    lng = double.tryParse(widget.pet!.longitude.toString()) ?? 0.0;
    
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        locationController.text = "${place.locality}, ${place.administrativeArea}, ${place.country}";
      }
    } catch (e) {
      // Handle location error or leave empty
    }
    setState(() {});
  }

  // UI Helpers
  TextStyle get _labelStyle => TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: labelColor);

  InputDecoration _inputDecoration(String label, {IconData? prefixIcon, Widget? suffixIcon, String? errorText}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
      errorText: errorText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey[400], size: 20) : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15), // Reduced padding to prevent overflow
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
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
    if (width > 600) width = 600;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Edit Pet Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Container(
            width: width,
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                // Header Image
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))]
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset('assets/images/petForm.jpeg', scale: 3, fit: BoxFit.cover, width: double.infinity, height: 150)
                  )
                ),
                const SizedBox(height: 30),

                // Pet Name
                Row(
                  children: [
                    Text('Name', style: _labelStyle),
                    SizedBox(width: 15),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: petNameController,
                        decoration: _inputDecoration('Pet Name', prefixIcon: Icons.edit, errorText: petNameError),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Type, Gender, Age Row
                Row(
                  children: [
                    // Type
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: selectedPetType,
                        decoration: _inputDecoration('Type'),
                        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
                        items: petTypes.map((String val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => selectedPetType = val!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Gender
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: selectedGender,
                        decoration: _inputDecoration('Gender'),
                        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
                        items: gender.map((String val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => selectedGender = val!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Age
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: ageController,
                        decoration: _inputDecoration('Age', errorText: ageError),
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Category & Health
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: selectedCategory,
                        decoration: _inputDecoration('Category'),
                        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
                        items: categories.map((String val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => selectedCategory = val!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: selectedHealth,
                        decoration: _inputDecoration('Health'),
                        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
                        items: health.map((String val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => selectedHealth = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Description
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text('Desc', style: _labelStyle),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: TextField(
                        maxLines: 3,
                        controller: descriptionController,
                        decoration: _inputDecoration('Description', prefixIcon: Icons.description, errorText: descriptionError),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Location
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text('Location', style: _labelStyle),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: TextField(
                        maxLines: 3,
                        controller: locationController,
                        decoration: _inputDecoration(
                          'Tap icon to locate',
                          prefixIcon: Icons.location_on,
                          errorText: locationError,
                          suffixIcon: IconButton(
                            onPressed: () async {
                              position = await _determinePosition();
                              lat = position.latitude;
                              lng = position.longitude;
                              List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
                              Placemark place = placemarks[0];
                              locationController.text = "${place.name},\n${place.postalCode},${place.locality},\n${place.administrativeArea},${place.country}";
                              setState(() {});
                            },
                            icon: Icon(Icons.location_searching, color: primaryColor),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Images
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text('Update\nImages', style: _labelStyle),
                    ),
                    SizedBox(width: 15),
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
                    child: Text(imageError!, style: TextStyle(color: Colors.red, fontSize: 12)),
                  ),

                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () {
                      submitValidation();
                    },
                    child: Text('Update Pet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Styled Image Box Helper
  Widget _buildImageUploadBox(int index) {
    bool hasImage = (images[index] != null && !kIsWeb) || (webImages[index] != null);
    
    // Note: Since we don't load existing images from server into the 'images' list in _loadPet,
    // this will be empty initially. This is consistent with your logic where user only sees image if they pick a NEW one.
    
    return GestureDetector(
      onTap: () {
        setState(() => imageError = null);
        if (kIsWeb) {
            openGallery(index);
        } else {
            pickimagedialog(index);
        }
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: hasImage ? primaryColor : Colors.grey[300]!,
            width: hasImage ? 2 : 1
          ),
          borderRadius: BorderRadius.circular(16),
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
            ? Center(child: Icon(Icons.add_a_photo, size: 24, color: Colors.grey[400]))
            : null,
      ),
    );
  }

  // --- LOGIC FUNCTIONS (Kept largely the same) ---

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error('Location permissions are denied');
    }
    if (permission == LocationPermission.deniedForever) return Future.error('Location permissions are permanently denied.');
    return await Geolocator.getCurrentPosition();
  }

  void pickimagedialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Pick Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: primaryColor),
                title: Text('Camera'),
                onTap: () { Navigator.pop(context); openCamera(index); },
              ),
              ListTile(
                leading: Icon(Icons.image, color: primaryColor),
                title: Text('Gallery'),
                onTap: () { Navigator.pop(context); openGallery(index); },
              ),
            ],
          ),
        );
      },
    );
  }

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

  Future<void> openGallery(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
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

  Future<void> cropImage(int index, File image) async {
    if (kIsWeb) return;
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1), // Square crop
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: primaryColor,
          toolbarWidgetColor: Colors.white,
        ),
        IOSUiSettings(title: 'Cropper'),
      ],
    );
    if (croppedFile != null) {
      image = File(croppedFile.path);
      if (index == 0) images[0] = image;
      if (index == 1) images[1] = image;
      if (index == 2) images[2] = image;
      imageError = null;
      setState(() {});
    }
  }

  void submitValidation() {
    String petName = petNameController.text.trim();
    String description = descriptionController.text.trim();
    String location = locationController.text.trim();
    List<String> base64images = [];

    setState(() {
      petNameError = null;
      ageError = null;
      descriptionError = null;
      locationError = null;
    });

    if (petName.isEmpty) {
      setState(() => petNameError = "Required field");
      return;
    }
    if (ageController.text.trim().isEmpty) {
      setState(() => ageError = "Required");
      return;
    }
    if (description.isEmpty) {
      setState(() => descriptionError = "Required field");
      return;
    }
    if (location.isEmpty) {
      setState(() => locationError = "Required field");
      return;
    }
    
    // Process images only if new ones are selected
    if (kIsWeb) {
      for (int i = 0; i < 3 && webImages[i] != null; i++) {
        base64images.add(base64Encode(webImages[i]!));
      }
    } else {
      for (int i = 0; i < 3 && images[i] != null; i++) {
        base64images.add(base64Encode(images[i]!.readAsBytesSync()));
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: const Text('Save changes?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                submitPet(
                  petName,
                  selectedPetType,
                  selectedGender,
                  ageController.text.trim(),
                  selectedCategory,
                  selectedHealth,
                  description,
                  lat.toString(),
                  lng.toString(),
                  base64images,
                );
              },
              child: Text('Update', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

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
    setState(() => isLoading = true);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(children: [CircularProgressIndicator(color: primaryColor), SizedBox(width: 20), Text('Updating...')]),
      ),
    );

    http.post(
      Uri.parse('${Connection.baseUrl}/pawpal/api/edit_pet.php'),
      body: {
        'petid': widget.pet?.petId,
        'userid': widget.user?.userId,
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
    ).then((response) {
      if (!mounted) return;
      stopLoading(); // Dismiss loading dialog
      Navigator.pop(context); // Dismiss "Updating..." dialog if still there, though stopLoading should handle it if implemented correctly
      
      if (response.statusCode == 200) {
        var resarray = jsonDecode(response.body);
        if (resarray['success']) {
          Navigator.pushAndRemoveUntil(
             context, 
             MaterialPageRoute(builder: (context) => HomePage(user: widget.user)),
             (route) => false
          );
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${resarray['message']}"), backgroundColor: Colors.green));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Update failed: ${resarray['message']}"), backgroundColor: Colors.red));
        }
      }
    }).timeout(const Duration(seconds: 10), onTimeout: () {
      if (!mounted) return;
      stopLoading();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request timed out.')));
    });
  }

  void stopLoading() {
    if (isLoading) {
      Navigator.of(context).pop();
      setState(() => isLoading = false);
    }
  }
}