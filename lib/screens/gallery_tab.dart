import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/photo.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class GalleryTab extends StatefulWidget {
  final bool isAdmin;
  const GalleryTab({super.key, this.isAdmin = false});

  @override
  State<GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends State<GalleryTab> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  Future<List<Photo>>? _photosFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPhotos();
    });
  }

  void _loadPhotos() {
    final storage = Provider.of<StorageService>(context, listen: false);
    setState(() {
      _photosFuture = storage.getAllGalleryPhotos();
    });
  }

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return;
    if (!context.mounted) return;

    setState(() => _isUploading = true);

    try {
      final storage = Provider.of<StorageService>(context, listen: false);

      final String? downloadUrl = await storage.uploadPhoto(File(image.path));
      if (!context.mounted) return;

      if (downloadUrl != null) {
        _loadPhotos();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo uploaded successfully!')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<RealtimeDatabaseService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ألبوم الصور'),
        actions: [
          if (_isUploading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadPhotos(),
        child: FutureBuilder<List<Photo>>(
          future: _photosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

          final photos = snapshot.data ?? [];
          if (photos.isEmpty) {
            return const Center(child: Text('No photos shared yet. Be the first!'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              return GestureDetector(
                onTap: () => _showFullscreenImage(context, photo),
                child: Hero(
                  tag: photo.url,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.softBlue,
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(photo.url),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      ),
      floatingActionButton: widget.isAdmin 
          ? _buildFab(context)
          : StreamBuilder<bool>(
              stream: db.getGalleryUploadEnabled(),
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return _buildFab(context);
                }
                return const SizedBox.shrink();
              },
            ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: _isUploading ? null : () => _pickAndUploadImage(context),
      child: const Icon(Icons.add_a_photo),
    );
  }

  void _showFullscreenImage(BuildContext context, Photo photo) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
        body: Center(
          child: Hero(
            tag: photo.url,
            child: InteractiveViewer(
              child: Image.network(photo.url),
            ),
          ),
        ),
      ),
    ));
  }
}
