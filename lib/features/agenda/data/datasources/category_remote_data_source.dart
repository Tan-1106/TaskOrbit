import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:task_orbit/features/agenda/domain/entities/category.dart' as domain;

abstract interface class CategoryRemoteDataSource {
  Future<List<domain.Category>> getCategories(String userId);

  Future<void> createCategory(domain.Category category);

  Future<void> deleteCategory(String userId, String categoryId);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final FirebaseFirestore firestore;

  const CategoryRemoteDataSourceImpl(this.firestore);

  CollectionReference<Map<String, dynamic>> _categoriesRef(String userId) {
    return firestore.collection('users').doc(userId).collection('categories');
  }

  @override
  Future<List<domain.Category>> getCategories(String userId) async {
    final snapshot = await _categoriesRef(userId).get();
    return snapshot.docs.map((doc) => _categoryFromDoc(doc)).toList();
  }

  @override
  Future<void> createCategory(domain.Category category) async {
    await _categoriesRef(category.userId).doc(category.id).set(_categoryToMap(category));
  }

  @override
  Future<void> deleteCategory(String userId, String categoryId) async {
    await _categoriesRef(userId).doc(categoryId).delete();
  }

  domain.Category _categoryFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return domain.Category(
      id: doc.id,
      userId: d['userId'] as String,
      name: d['name'] as String,
      color: Color(d['colorValue'] as int),
      isSynced: true,
      isDeleted: false,
    );
  }

  Map<String, dynamic> _categoryToMap(domain.Category cat) {
    return {
      'userId': cat.userId,
      'name': cat.name,
      'colorValue': cat.color.toARGB32(),
    };
  }
}
