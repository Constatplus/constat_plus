import 'package:flutter/material.dart';

import '../models/photo_item.dart';

class PhotoGallery extends StatelessWidget {
  const PhotoGallery({
    required this.photos,
    required this.onDelete,
    required this.onOpen,
    super.key,
  });

  final List<PhotoItem> photos;
  final ValueChanged<PhotoItem> onDelete;
  final ValueChanged<PhotoItem> onOpen;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE4E7EC)),
        ),
        child: const Column(
          children: [
            Icon(Icons.photo_library_outlined, size: 38),
            SizedBox(height: 10),
            Text('Aucune photo ajoutée.'),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 620
            ? 3
            : 2;
        final width = (constraints.maxWidth - ((count - 1) * 12)) / count;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final photo in photos)
              SizedBox(
                width: width,
                child: _PhotoTile(
                  photo: photo,
                  onDelete: () => onDelete(photo),
                  onOpen: () => onOpen(photo),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.photo,
    required this.onDelete,
    required this.onOpen,
  });

  final PhotoItem photo;
  final VoidCallback onDelete;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.memory(
                photo.bytes,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Center(
                  child: Icon(Icons.broken_image_outlined, size: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 6, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      photo.note.trim().isEmpty ? photo.name : photo.note,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Supprimer',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
