class Adoption {
  String? adoptionId;
  String? petId;
  String? userId;
  String? contactInfo;
  String? reasonAdopt;
  String? requestDate;

  // Added pet name
  String? petName;

  // Added other user info
  String? otherUserId;
  String? otherUserName;
  String? otherUserEmail;
  String? otherUserPhone;

  Adoption({
    this.adoptionId,
    this.petId,
    this.userId,
    this.contactInfo,
    this.reasonAdopt,
    this.requestDate,

    this.petName,

    this.otherUserId,
    this.otherUserName,
    this.otherUserEmail,
    this.otherUserPhone,
  });

  Adoption.fromJson(Map<String, dynamic> json) {
    adoptionId = json['adoption_id'];
    petId = json['pet_id'];
    userId = json['user_id'];
    contactInfo = json['contact_info'];
    reasonAdopt = json['reason_adopt'];
    requestDate = json['requested_date'];

    petName = json['pet_name'];

    otherUserId = json['other_user_id'];
    otherUserName = json['other_user_name'];
    otherUserEmail = json['other_user_email'];
    otherUserPhone = json['other_user_phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['adoption_id'] = adoptionId;
    data['pet_id'] = petId;
    data['user_id'] = userId;
    data['contact_info'] = contactInfo;
    data['reason_adopt'] = reasonAdopt;
    data['requested_date'] = requestDate;

    data['pet_name'] = petName;

    data['other_user_id'] = otherUserId;
    data['other_user_name'] = otherUserName;
    data['other_user_email'] = otherUserEmail;
    data['other_user_phone'] = otherUserPhone;

    return data;
  }
}