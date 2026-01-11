class User {
  String? userId;
  String? userImage;
  String? userName;
  String? userEmail;
  String? userPassword;
  String? userPhone;
  String? userWallet;
  String? userRegdate;

  User(
      {this.userId,
      this.userImage,
      this.userName,
      this.userEmail,
      this.userPassword,
      this.userPhone,
      this.userWallet,
      this.userRegdate});

  User.fromJson(Map<String, dynamic> json) {
    userId = json['user_id']?.toString();
    userImage = json['user_image'];
    userName = json['name'];
    userEmail = json['email'];
    userPassword = json['password'];
    userPhone = json['phone'];
    userWallet = json['wallet'];
    userRegdate = json['reg_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['user_image'] = userImage;
    data['name'] = userName;
    data['email'] = userEmail;
    data['password'] = userPassword;
    data['phone'] = userPhone;
    data['wallet'] = userWallet;
    data['reg_date'] = userRegdate;
    return data;
  }
}