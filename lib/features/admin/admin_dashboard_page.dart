import 'package:flutter/material.dart';

import '../../core/access/access_service.dart';
import '../../core/auth/auth_service.dart';
import '../../core/models/mission.dart';
import '../correction/correction_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({
    super.key,
    this.controllerMode = false,
    this.projects = const <MissionData>[],
  });

  final bool controllerMode;
  final List<MissionData> projects;

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  MissionStatus? _status;
  _DateFilter _dateFilter = _DateFilter.all;
  String _query = '';

  List<MissionData> get _visibleProjects {
    if (widget.controllerMode) {
      // Aucun contrôleur assigné n'est exposé par les données actuelles.
      return const <MissionData>[];
    }
    final now = DateTime.now();
    return widget.projects
        .where((project) {
          final query = _query.trim().toLowerCase();
          final matchesQuery =
              query.isEmpty ||
              project.displayTitle.toLowerCase().contains(query) ||
              project.address.toLowerCase().contains(query) ||
              project.client.toLowerCase().contains(query);
          final matchesStatus = _status == null || project.status == _status;
          final matchesDate = switch (_dateFilter) {
            _DateFilter.all => true,
            _DateFilter.last7Days => project.updatedAt.isAfter(
              now.subtract(const Duration(days: 7)),
            ),
            _DateFilter.last30Days => project.updatedAt.isAfter(
              now.subtract(const Duration(days: 30)),
            ),
          };
          return matchesQuery && matchesStatus && matchesDate;
        })
        .toList(growable: false);
  }

  Future<void> _signOut() async {
    final demo = AccessService.instance.isDemo;
    AccessService.instance.signOut();
    if (!demo) await AuthService.signOut();
  }

  void _openControlQueue() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const CorrectionPage()),
    );
  }

  void _showProject(MissionData project) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(project.displayTitle),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _DetailLine('Adresse', project.address),
                _DetailLine('Type de mission', project.kind.label),
                _DetailLine('Client', project.client),
                _DetailLine('Statut', project.status.label),
                _DetailLine('Progression', '${project.progress} %'),
                _DetailLine(
                  'Dernière modification',
                  _formatDate(project.updatedAt),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projects = _visibleProjects;
    final controller = widget.controllerMode;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FA),
      appBar: AppBar(
        title: Text(controller ? 'Espace contrôleur' : 'Administration'),
        actions: <Widget>[
          if (controller)
            IconButton(
              tooltip: 'Se déconnecter',
              onPressed: _signOut,
              icon: const Icon(Icons.logout_rounded),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 700;
          final padding = compact ? 16.0 : 24.0;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1440),
              child: ListView(
                padding: EdgeInsets.all(padding),
                children: <Widget>[
                  Text(
                    controller
                        ? 'Projets à vérifier'
                        : 'Suivi global des projets',
                    style: TextStyle(
                      fontSize: compact ? 25 : 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller
                        ? 'Consultez uniquement les dossiers qui vous sont confiés.'
                        : 'Consultez l’activité et l’avancement des dossiers.',
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 22),
                  _metrics(compact),
                  if (!controller) ...<Widget>[
                    const SizedBox(height: 16),
                    _adminTools(compact),
                  ],
                  const SizedBox(height: 24),
                  if (controller)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.icon(
                        onPressed: _openControlQueue,
                        icon: const Icon(Icons.fact_check_outlined),
                        label: const Text('Ouvrir la file de contrôle'),
                      ),
                    )
                  else
                    _filters(compact),
                  const SizedBox(height: 22),
                  Text(
                    controller ? 'Dossiers assignés' : 'Tous les projets',
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (projects.isEmpty)
                    _EmptyProjects(controllerMode: controller)
                  else
                    _projectGrid(projects),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _metrics(bool compact) {
    final projects = widget.controllerMode
        ? const <MissionData>[]
        : widget.projects;
    final inProgress = projects
        .where((project) => project.status == MissionStatus.inProgress)
        .length;
    final completed = projects
        .where((project) => project.status == MissionStatus.completed)
        .length;
    final metrics = widget.controllerMode
        ? const <_MetricData>[
            _MetricData('À contrôler', '—', Icons.inbox_outlined),
            _MetricData('Contrôles en cours', '—', Icons.fact_check_outlined),
            _MetricData('Validés', '—', Icons.verified_outlined),
            _MetricData('Renvoyés à corriger', '—', Icons.replay_outlined),
          ]
        : <_MetricData>[
            _MetricData(
              'Total des projets',
              '${projects.length}',
              Icons.folder,
            ),
            _MetricData('En cours', '$inProgress', Icons.pending_actions),
            _MetricData('Terminés', '$completed', Icons.task_alt),
            const _MetricData('À contrôler', '—', Icons.fact_check_outlined),
            const _MetricData('Validés', '—', Icons.verified_outlined),
            const _MetricData('À corriger', '—', Icons.replay_outlined),
            const _MetricData('Utilisateurs actifs', '—', Icons.people_outline),
          ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = compact
            ? 1
            : constraints.maxWidth < 1050
            ? 2
            : 4;
        final width = (constraints.maxWidth - ((columns - 1) * 14)) / columns;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: width,
                  child: _MetricCard(data: metric),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }

  Widget _adminTools(bool compact) {
    final tools = const <_MetricData>[
      _MetricData(
        'Utilisateurs',
        'Gestion des comptes et rôles',
        Icons.people_outline,
      ),
      _MetricData(
        'Abonnements',
        'Gestion des abonnements existants',
        Icons.credit_card_outlined,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = compact ? constraints.maxWidth : 320.0;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: tools
              .map(
                (tool) => SizedBox(
                  width: width,
                  child: _AdminToolCard(data: tool),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }

  Widget _filters(bool compact) {
    final search = TextField(
      onChanged: (value) => setState(() => _query = value),
      decoration: const InputDecoration(
        labelText: 'Rechercher un projet',
        prefixIcon: Icon(Icons.search),
      ),
    );
    final status = DropdownButtonFormField<MissionStatus?>(
      initialValue: _status,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Statut'),
      items: <DropdownMenuItem<MissionStatus?>>[
        const DropdownMenuItem(value: null, child: Text('Tous les statuts')),
        ...MissionStatus.values.map(
          (value) => DropdownMenuItem(value: value, child: Text(value.label)),
        ),
      ],
      onChanged: (value) => setState(() => _status = value),
    );
    final date = DropdownButtonFormField<_DateFilter>(
      initialValue: _dateFilter,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Date'),
      items: _DateFilter.values
          .map(
            (value) => DropdownMenuItem(value: value, child: Text(value.label)),
          )
          .toList(growable: false),
      onChanged: (value) {
        if (value != null) setState(() => _dateFilter = value);
      },
    );
    if (compact) {
      return Column(
        children: <Widget>[
          search,
          const SizedBox(height: 12),
          status,
          const SizedBox(height: 12),
          date,
        ],
      );
    }
    return Row(
      children: <Widget>[
        Expanded(flex: 2, child: search),
        const SizedBox(width: 12),
        Expanded(child: status),
        const SizedBox(width: 12),
        Expanded(child: date),
      ],
    );
  }

  Widget _projectGrid(List<MissionData> projects) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 700
            ? 1
            : constraints.maxWidth < 1100
            ? 2
            : 3;
        final width = (constraints.maxWidth - ((columns - 1) * 16)) / columns;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: projects
              .map(
                (project) => SizedBox(
                  width: width,
                  child: _ProjectCard(
                    project: project,
                    onOpen: () => _showProject(project),
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _MetricData {
  const _MetricData(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: <Widget>[
            Icon(data.icon, size: 30, color: const Color(0xFF1264F6)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    data.value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    data.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF64748B)),
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

class _AdminToolCard extends StatelessWidget {
  const _AdminToolCard({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: <Widget>[
            Icon(data.icon, size: 30, color: const Color(0xFF1264F6)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    data.label,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.value,
                    style: const TextStyle(color: Color(0xFF64748B)),
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

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project, required this.onOpen});

  final MissionData project;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _StatusBadge(label: project.status.label),
                _StatusBadge(label: project.kind.shortLabel, neutral: true),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              project.displayTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              project.address.trim().isEmpty
                  ? 'Adresse non renseignée'
                  : project.address,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: project.progress / 100),
            const SizedBox(height: 6),
            Text('${project.progress} % complété'),
            const SizedBox(height: 12),
            Text(
              'Modifié le ${_formatDate(project.updatedAt)}',
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Voir le détail'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, this.neutral = false});

  final String label;
  final bool neutral;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: neutral ? const Color(0xFFF1F5F9) : const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            color: neutral ? const Color(0xFF475569) : const Color(0xFF1D4ED8),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _EmptyProjects extends StatelessWidget {
  const _EmptyProjects({required this.controllerMode});

  final bool controllerMode;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: <Widget>[
            const Icon(
              Icons.folder_off_outlined,
              size: 42,
              color: Color(0xFF2563EB),
            ),
            const SizedBox(height: 12),
            Text(
              controllerMode
                  ? 'Aucun projet assigné disponible'
                  : 'Aucun projet disponible',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              controllerMode
                  ? 'La source actuelle ne fournit pas encore les affectations de contrôle.'
                  : 'Les projets apparaîtront ici dès qu’ils seront fournis au tableau de bord.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(value.trim().isEmpty ? 'Non renseigné' : value),
        ],
      ),
    );
  }
}

enum _DateFilter {
  all('Toutes les dates'),
  last7Days('7 derniers jours'),
  last30Days('30 derniers jours');

  const _DateFilter(this.label);
  final String label;
}

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}
