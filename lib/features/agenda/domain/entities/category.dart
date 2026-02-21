import 'package:flutter/material.dart';

class Category {
  final String id;
  final String userId;
  final String name;
  final Color color;
  final bool isSynced;
  final bool isDeleted;

  const Category({
    required this.id,
    required this.userId,
    required this.name,
    required this.color,
    this.isSynced = false,
    this.isDeleted = false,
  });

  Category copyWith({
    String? id,
    String? userId,
    String? name,
    Color? color,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      color: color ?? this.color,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Category(id: $id, name: $name)';
}
