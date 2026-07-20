import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoPickerSection extends StatefulWidget {
  final String title;

  const PhotoPickerSection({super.key, this.title = 'Photos'});

  @override
  State<PhotoPickerSection> createState() => _PhotoPickerSectionState();
}

class _PhotoPickerSectionState extends State<PhotoPickerSection>
    with AutomaticKeepAliveClientMixin {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _photos = [];

  @override
  bool get wantKeepAlive => true;

  Future<void> _takePhoto() async {
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo == null || !mounted) return;

      setState(() {
        _photos.add(photo);
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La caméra n’est pas disponible sur cet appareil.'),
        ),
      );
    }
  }

  Future<void> _selectPhotos() async {
    try {
      final photos = await _picker.pickMultiImage(imageQuality: 85);

      if (photos.isEmpty || !mounted) return;

      setState(() {
        _photos.addAll(photos);
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’ouvrir la galerie.')),
      );
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  void _showPhoto(XFile photo) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(30),
          child: Stack(
            children: [
              InteractiveViewer(
                child: Image.file(
                  File(photo.path),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 500,
                      height: 350,
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: const Text('Impossible d’afficher cette photo.'),
                    );
                  },
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: IconButton.filled(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_library_outlined, color: Colors.blue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${widget.title} (${_photos.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _selectPhotos,
                icon: const Icon(Icons.collections_outlined),
                label: const Text('Galerie'),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Photo'),
              ),
            ],
          ),
          if (_photos.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _photos.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(width: 12);
                },
                itemBuilder: (context, index) {
                  final photo = _photos[index];

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _showPhoto(photo),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            File(photo.path),
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 110,
                                height: 110,
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child: const Icon(Icons.broken_image_outlined),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        right: -7,
                        top: -7,
                        child: IconButton.filled(
                          tooltip: 'Supprimer la photo',
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _removePhoto(index),
                          icon: const Icon(Icons.close, size: 17),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
