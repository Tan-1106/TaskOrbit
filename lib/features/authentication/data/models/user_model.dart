import 'package:task_orbit/features/authentication/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
    );
  }

  factory UserModel.fromFirebaseUser({
    required String uid,
    required String name,
    required String email,
  }) {
    return UserModel(
      id: uid,
      name: name,
      email: email,
    );
  }

  UserModel copyWithModel({
    String? id,
    String? name,
    String? email,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}
