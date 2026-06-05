class UserModel {
  final String uid;
  final String name;
  final String email;
  final String profileImage;
  final String bio;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.bio,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profileImage: data['profileImage'] ?? '',
      bio: data['bio'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'bio': bio,
    };
  }
}