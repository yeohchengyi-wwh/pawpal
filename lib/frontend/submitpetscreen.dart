import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pawpal/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/connection.dart';
import 'package:pawpal/frontend/homepage.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class FormPetSubmssion extends StatefulWidget {
  final User? user;
  const FormPetSubmssion({super.key, required this.user});

  @override
  State<FormPetSubmssion> createState() => _FormPetSubmssionState();
}

class _FormPetSubmssionState extends State<FormPetSubmssion> {
  List<String> petTypes = ["Cat", "Dog", "Rabbit", "Other"];

  List<String> categories = ["Adoption", "Donation Request", "Help/Rescue"];

  late double width;
  TextEditingController petNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  String selectedPetTypes = "Cat";
  String selectedCategories = "Adoption";
  late Position position;
  late double latitude, longitude;
  List<Uint8List?> webImages = [null, null, null];
  List<File?> images = [null, null, null];
  String? petNameError, descriptionError, locationError, imageError;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    if (width > 400) {
      width = 400;
    } else {
      width = width;
    }
    return Scaffold(
      appBar: AppBar(title: Text('Pet Submission Form')),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: width,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(10),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/petForm.jpeg',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.blue[100],
                      child: const Center(child: Icon(Icons.pets, size: 60, color: Colors.white)),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                Row(
                  children: [
                    Text('Pet Name', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 15),
                    Expanded(
                      child: TextField(
                        controller: petNameController,
                        decoration: InputDecoration(
                          errorText: petNameError,
                          prefixIcon: Icon(Icons.edit),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                Row(
                  children: [
                    Text('Pet Type', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 24),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedPetTypes,
                        decoration: InputDecoration(
                          labelText: 'Select Pet Type',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon: Icon(Icons.keyboard_arrow_down),
                        items: petTypes.map((String selectedPetType) {
                          return DropdownMenuItem<String>(
                            value: selectedPetType,
                            child: Text(selectedPetType),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedPetTypes = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                Row(
                  children: [
                    Text('Category', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 22),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedCategories,
                        decoration: InputDecoration(
                          labelText: 'Select Category',
                          prefixIcon: Icon(Icons.label),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon: Icon(Icons.keyboard_arrow_down),
                        items: categories.map((String selectedCategory) {
                          return DropdownMenuItem<String>(
                            value: selectedCategory,
                            child: Text(selectedCategory),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCategories = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                Row(
                  children: [
                    Text('Description', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 5),
                    Expanded(
                      child: TextField(
                        maxLines: 3,
                        controller: descriptionController,
                        decoration: InputDecoration(
                          errorText: descriptionError,
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                Row(
                  children: [
                    Text('Location', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 26),
                    Expanded(
                      child: TextField(
                        maxLines: 3,
                        controller: locationController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          errorText: locationError,
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () async {
                              position = await _determinePosition();
                              latitude = position.latitude;
                              longitude = position.longitude;
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
                            icon: Icon(Icons.location_searching),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                Row(
                  children: [
                    Text('Image\n(Max 3)', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 33),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            imageError = null;
                          });
                          // index for image, easy for pick and crop image based on index
                          if (kIsWeb) {
                            openGallery(0);
                          } else {
                            pickimagedialog(0);
                          }
                        },
                        child: Container(
                          height: 95,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: imageError == null
                                  ? Colors.grey
                                  : Colors.red,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            image: (images[0] != null && !kIsWeb)
                                ? DecorationImage(
                                    image: FileImage(images[0]!),
                                    fit: BoxFit.cover,
                                  )
                                : (webImages[0] != null)
                                ? DecorationImage(
                                    image: MemoryImage(webImages[0]!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: (images[0] == null && webImages[0] == null)
                              ? Center(
                                  child: Icon(
                                    Icons.photo_library,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            imageError = null;
                          });
                          if (images[0] != null || webImages[0] != null) {
                            if (kIsWeb) {
                              openGallery(1);
                            } else {
                              pickimagedialog(1);
                            }
                          } else {
                            imageError = 'Please click on the first one';
                            setState(() {});
                          }
                        },
                        child: Container(
                          height: 95,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: imageError == null
                                  ? Colors.grey
                                  : Colors.red,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            image: (images[1] != null && !kIsWeb)
                                ? DecorationImage(
                                    image: FileImage(images[1]!),
                                    fit: BoxFit.cover,
                                  )
                                : (webImages[1] != null)
                                ? DecorationImage(
                                    image: MemoryImage(webImages[1]!),
                                    fit: BoxFit.cover,
                                  )
                                : null, // return icon if no image
                          ),
                          child: (images[1] == null && webImages[1] == null)
                              ? Center(
                                  child: Icon(
                                    Icons.photo_library,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            imageError = null;
                          });
                          bool hasImage1 =
                              images[0] != null || webImages[0] != null;
                          bool hasImage2 =
                              images[1] != null || webImages[1] != null;
                          if (!hasImage1) {
                            imageError = 'Please click on the first one';
                            setState(() {});
                          } else if (!hasImage2) {
                            imageError = 'Please click on the second one';
                            setState(() {});
                          } else {
                            if (kIsWeb) {
                              openGallery(2);
                            } else {
                              pickimagedialog(2);
                            }
                          }
                        },
                        child: Container(
                          height: 95,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: imageError == null
                                  ? Colors.grey
                                  : Colors.red,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            image: (images[2] != null && !kIsWeb)
                                ? DecorationImage(
                                    image: FileImage(images[2]!),
                                    fit: BoxFit.cover,
                                  )
                                : (webImages[2] != null)
                                ? DecorationImage(
                                    image: MemoryImage(webImages[2]!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: (images[2] == null && webImages[2] == null)
                              ? Center(
                                  child: Icon(
                                    Icons.photo_library,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                )
                              : null,
                        ),
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
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      submitValidation();
                    },
                    child: Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  openCamera(index);
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
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
        cropImage(index, imageFile); //mobile devices only
      }
    }
  }

  Future<void> cropImage(int index, File originalImage) async {
    if (kIsWeb) return;

    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: originalImage.path,
        aspectRatio: const CropAspectRatio(ratioX: 5, ratioY: 3),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio5x3,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Cropper'),
        ],
      );

      if (croppedFile != null) {
        print("✅ Crop successful: ${croppedFile.path}");
        setState(() {
          images[index] = File(croppedFile.path);
          imageError = null;
        });

        print("✅ Image updated for index $index");
      } else {
        print("⚠️ Crop cancelled by user");
      }
    } catch (e) {
      print("❌ Crop error: $e");
    }
  }

  void submitValidation() {
    String petName = petNameController.text.trim();
    String petType = selectedPetTypes;
    String category = selectedCategories;
    String description = descriptionController.text.trim();
    String location = locationController.text.trim();

    List<String> base64images = [];

    setState(() {
      petNameError = null;
      descriptionError = null;
      locationError = null;
      imageError = null;
    });

    if (petName.isEmpty) {
      setState(() {
        petNameError = "Required field";
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

    //confirmation dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Text('Are you sure you want to submit this form?'),
          actions: [
            TextButton(
              onPressed: () {
                submitPet(
                  petName,
                  petType,
                  category,
                  description,
                  latitude.toString(),
                  longitude.toString(),
                  base64images,
                );
              },
              child: Text('Submit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void submitPet(
  String petName,
  String petType,
  String category,
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

  // 打印调试信息
  print('Sending request to: ${Connection.baseUrl}/pawpal/api/submit_pet.php');
  print('Images count: ${base64images.length}');

  http.post(
    Uri.parse('${Connection.baseUrl}/pawpal/api/submit_pet.php'),
    body: {
      'userid': widget.user?.userId ?? '0',
      'petname': petName,
      'pettype': petType,
      'category': category,
      'description': description,
      'latitude': lat,
      'longitude': lng,
      'images': jsonEncode(base64images.where((img) => img != null).toList()),
    },
  ).then((response) {
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    // 首先关闭loading对话框
    if (mounted) {
      Navigator.of(context).pop(); // 关闭loading对话框
    }
    
    if (response.statusCode == 200) {
      try {
        var jsonResponse = jsonDecode(response.body);
        bool success = jsonResponse['success'] ?? false;
        String message = jsonResponse['message'] ?? 'No message';
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
            ),
          );
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(user: widget.user),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Submit failed: $message"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('JSON decode error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error parsing server response'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Server error: ${response.statusCode}'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    setState(() {
      isLoading = false;
    });
  }).catchError((error) {
    print('Request error: $error');
    if (mounted) {
      Navigator.of(context).pop();
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Network error: ${error.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
    
    setState(() {
      isLoading = false;
    });
  });
}

}
