class Pet {
  String? petId;
  String? userId;
  String? petName;
  String? petType;
  String? category;
  String? description;
  String? latitude;
  String? longitude;
  String? createdDate;

  // Added user info
  String? userName;
  String? userEmail;
  String? userPhone;

  Pet({
    this.petId,
    this.userId,
    this.petName,
    this.petType,
    this.category,
    this.description,
    this.latitude,
    this.longitude,
    this.createdDate,
    this.userName,
    this.userEmail,
    this.userPhone,
  });

  Pet.fromJson(Map<String, dynamic> json) {
    petId = json['pet_id'];
    userId = json['user_id'];
    petName = json['pet_name'];
    petType = json['pet_type'];
    category = json['category'];
    description = json['description'];
    latitude = json['lat'];
    longitude = json['lng'];
    createdDate = json['created_at'];

    // Mapping user fields
    userName = json['name'];
    userEmail = json['email'];
    userPhone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pet_id'] = petId;
    data['user_id'] = userId;
    data['pet_name'] = petName;
    data['pet_type'] = petType;
    data['category'] = category;
    data['description'] = description;
    data['lat'] = latitude;
    data['lng'] = longitude;
    data['created_at'] = createdDate;

    data['name'] = userName;
    data['email'] = userEmail;
    data['phone'] = userPhone;

    return data;
  }
}