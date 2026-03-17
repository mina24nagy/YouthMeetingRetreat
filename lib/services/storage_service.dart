import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadPhoto(File file) async {
    try {
      final String fileName = p.basename(file.path);
      final String uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final Reference ref = _storage.ref().child('gallery/$uniqueName');
      
      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  Future<void> deletePhoto(String url) async {
    try {
      final Reference ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      print('Delete error: $e');
    }
  }
}
