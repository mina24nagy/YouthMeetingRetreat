import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/photo.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadPhoto(File file) async {
    try {
      final String fileName = file.path.split('/').last;
      final String uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final Reference ref = _storage.ref().child('gallery/$uniqueName');
      
      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  Future<void> deletePhoto(String url) async {
    try {
      final Reference ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }

  Future<List<Photo>> getAllGalleryPhotos() async {
    try {
      final ListResult result = await _storage.ref('gallery').listAll();
      final List<Photo> photos = [];
      
      for (var ref in result.items) {
        final String url = await ref.getDownloadURL();
        final FullMetadata metadata = await ref.getMetadata();
        
        photos.add(Photo(
          id: ref.name,
          url: url,
          uploadedBy: 'Anonymous',
          timestamp: metadata.timeCreated ?? DateTime.now(),
        ));
      }
      
      photos.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return photos;
    } catch (e) {
      debugPrint('Error fetching gallery photos: $e');
      return [];
    }
  }
}
