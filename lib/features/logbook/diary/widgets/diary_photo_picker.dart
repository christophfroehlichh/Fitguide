import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';

class DiaryPhotoPicker extends StatefulWidget {
  final String? initialPhotoUrl;
  final DateTime selectedDate;
  final String userId;
  final Function(String?) onPhotoChanged;

  const DiaryPhotoPicker({
    super.key,
    this.initialPhotoUrl,
    required this.selectedDate,
    required this.userId,
    required this.onPhotoChanged,
  });

  @override
  State<DiaryPhotoPicker> createState() => DiaryPhotoPickerState();
}

class DiaryPhotoPickerState extends State<DiaryPhotoPicker> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  String? _currentPhotoUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _currentPhotoUrl = widget.initialPhotoUrl;
  }

  @override
  void didUpdateWidget(DiaryPhotoPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPhotoUrl != widget.initialPhotoUrl) {
      setState(() {
        _currentPhotoUrl = widget.initialPhotoUrl;
        _selectedImage = null;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _currentPhotoUrl = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden des Bildes: $e')),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _currentPhotoUrl = null;
    });
    widget.onPhotoChanged(null);
  }

  Future<String?> uploadImage() async {
    if (_selectedImage == null) return _currentPhotoUrl;

    setState(() {
      _isUploading = true;
    });

    try {
      final fileName =
          'diary_${DateFormat('yyyyMMdd').format(widget.selectedDate)}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(widget.userId)
          .child('diary_photos')
          .child(fileName);

      Uint8List? compressedBytes;

      if (kIsWeb) {
        final bytes = await _selectedImage!.readAsBytes();
        compressedBytes = await FlutterImageCompress.compressWithList(
          bytes,
          minWidth: 1920,
          minHeight: 1080,
          quality: 85,
        );
      } else {
        final result = await FlutterImageCompress.compressWithFile(
          _selectedImage!.path,
          minWidth: 1920,
          minHeight: 1080,
          quality: 85,
        );
        compressedBytes = result;
      }

      if (compressedBytes == null) {
        throw Exception('Komprimierung fehlgeschlagen');
      }

      final uploadTask = storageRef.putData(compressedBytes);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _isUploading = false;
        _currentPhotoUrl = downloadUrl;
      });

      return downloadUrl;
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler beim Hochladen: $e')));
      }
      return null;
    }
  }

  bool get isUploading => _isUploading;

  bool get hasImage => _selectedImage != null || _currentPhotoUrl != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Foto (optional)', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        if (_selectedImage != null || _currentPhotoUrl != null)
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _selectedImage != null
                      ? (kIsWeb
                            ? Image.network(
                                _selectedImage!.path,
                                fit: BoxFit.contain,
                              )
                            : Image.file(
                                File(_selectedImage!.path),
                                fit: BoxFit.contain,
                              ))
                      : Image.network(_currentPhotoUrl!, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: _removeImage,
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          )
        else
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  'Kein Foto ausgewählt',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galerie'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Kamera'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
