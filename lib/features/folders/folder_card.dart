import 'package:flutter/material.dart';

import 'folder_model.dart';

class FolderCard extends StatelessWidget {
  const FolderCard({
    required this.folder,
    required this.onOpen,
    required this.onDelete,
    super.key,
  });

  final FolderModel folder;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  IconData get _icon {
    switch (folder.missionType) {
      case MissionType.entry:
        return Icons.login_rounded;
      case MissionType.exit:
        return Icons.logout_rounded;
      case MissionType.beforeWorks:
        return Icons.construction_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(_icon, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(folder.title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(folder.address, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${folder.client} • ${folder.missionLabel}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Supprimer',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
            const SizedBox(width: 4),
            FilledButton(
              onPressed: onOpen,
              child: const Text('Ouvrir'),
            ),
          ],
        ),
      ),
    );
  }
}
