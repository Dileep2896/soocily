import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:soocily/features/storage/domain/storage_repo.dart';

class FirebaseStorageRepo implements StorageRepo {
  final FirebaseStorage storage = FirebaseStorage.instance;

  /* 
  PROFILE IMAGE UPLOAD
  */

  @override
  Future<String?> uploadProfileImageMobile(String path, String fileName) {
    return _uploadProfileImageMobile(path, fileName, 'profile_images');
  }

  @override
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String fileName) {
    return _uploadProfileImageWeb(fileBytes, fileName, 'profile_images');
  }

  /*
  POST IMAGE UPLOAD
  */

  @override
  Future<String?> uploadPostImageMobile(String path, String fileName) {
    return _uploadProfileImageMobile(path, fileName, 'post_images');
  }

  @override
  Future<String?> uploadPostImageWeb(Uint8List fileBytes, String fileName) {
    return _uploadProfileImageWeb(fileBytes, fileName, 'post_images');
  }

  // HELPER METHODS

  // mobile platforms (file)
  Future<String?> _uploadProfileImageMobile(
      String path, String fileName, String folder) async {
    try {
      // Get the file from the path
      final file = File(path);

      // Create a reference to the storage location
      final ref = storage.ref().child('$folder/$fileName');

      // Upload the file
      final uploadTask = await ref.putFile(file);

      // Get the download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  // web platforms (bytes)
  Future<String?> _uploadProfileImageWeb(
      Uint8List fileBytes, String fileName, String folder) async {
    try {
      // Create a reference to the storage location
      final ref = storage.ref().child(folder).child(fileName);

      // Upload the file
      final uploadTask = await ref.putData(fileBytes);

      // Get the download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }
}
