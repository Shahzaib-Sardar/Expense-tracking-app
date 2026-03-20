class UserModel {
  final int? id;
  final String firebaseUid;
  final String name;
  final String email;
  final String? profilePicturePath;
  final String createdAt;

  UserModel({
    this.id,
    required this.firebaseUid,
    required this.name,
    required this.email,
    this.profilePicturePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebase_uid': firebaseUid,
      'name': name,
      'email': email,
      'profile_picture_path': profilePicturePath,
      'created_at': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      firebaseUid: map['firebase_uid'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      profilePicturePath: map['profile_picture_path'] as String?,
      createdAt: map['created_at'] as String,
    );
  }
}