class Donation{
  String? donationId;
  String? petId;
  String? userId;
  String? donationType;
  String? amount;
  String? description;
  String? donationDate;

  // Added pet name
  String? petName;

  // Added other user name
  String? otherUserName;

  Donation({
  this.donationId,
  this.petId,
  this.userId,
  this.donationType,
  this.amount,
  this.description,
  this.donationDate,

  this.petName,

  this.otherUserName
});

Donation.fromJson(Map<String, dynamic> json){
  donationId = json['donation_id'];
  petId = json['pet_id'];
  userId = json['user_id'];
  donationType = json['donation_type'];
  amount = json['amount'];
  description = json['description'];
  donationDate = json['donation_date'];

  petName = json['pet_name'];

  otherUserName = json['other_user_name'];
}

Map<String, dynamic> toJson(){
  final Map<String, dynamic> data = <String, dynamic>{};
  data['donation_id'] = donationId;
  data['pet_id'] = petId;
  data['user_id'] = userId;
  data['donation_type'] = donationType;
  data['amount'] = amount;
  data['description'] = description;
  data['donation_date'] = donationDate;

  data['pet_name'] = petName;

  data['other_user_name'] = otherUserName;

  return data;
}

}
