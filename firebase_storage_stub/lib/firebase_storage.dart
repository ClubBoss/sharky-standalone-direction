library firebase_storage;

import 'dart:async';

class FirebaseStorage {
  FirebaseStorage._();

  static final FirebaseStorage instance = FirebaseStorage._();

  Reference ref(String path) => Reference(path);
}

class Reference {
  Reference(this.path);

  final String path;

  Future<List<int>?> getData() async => null;
}

class FirebaseException implements Exception {
  FirebaseException({required this.code, this.message});

  final String code;
  final String? message;

  @override
  String toString() => 'FirebaseException($code): $message';
}
