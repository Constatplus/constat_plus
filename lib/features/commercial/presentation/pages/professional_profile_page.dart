import 'package:flutter/material.dart';

import '../../domain/models/user_profile.dart';
import '../../domain/repositories/commercial_repositories.dart';
import '../../infrastructure/repositories/supabase_profile_repository.dart';

class ProfessionalProfilePage extends StatefulWidget {
  final ProfileRepository? repository;

  const ProfessionalProfilePage({super.key, this.repository});

  @override
  State<ProfessionalProfilePage> createState() =>
      _ProfessionalProfilePageState();
}

class _ProfessionalProfilePageState extends State<ProfessionalProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _companyName = TextEditingController();
  final _companyNumber = TextEditingController();
  final _vatNumber = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _professionalTitle = TextEditingController();

  late final ProfileRepository _repository;
  UserProfile? _profile;
  Object? _error;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? SupabaseProfileRepository();
    _load();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _companyName.dispose();
    _companyNumber.dispose();
    _vatNumber.dispose();
    _address.dispose();
    _phone.dispose();
    _professionalTitle.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await _repository.getCurrentProfile();
      if (!mounted) return;
      if (profile == null) {
        throw StateError('Aucun profil associé à cette session.');
      }
      _fill(profile);
      setState(() => _profile = profile);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _fill(UserProfile profile) {
    _firstName.text = profile.firstName;
    _lastName.text = profile.lastName;
    _companyName.text = profile.companyName;
    _companyNumber.text = profile.companyNumber;
    _vatNumber.text = profile.vatNumber;
    _address.text = profile.address;
    _phone.text = profile.phone;
    _professionalTitle.text = profile.professionalTitle;
  }

  Future<void> _save() async {
    final profile = _profile;
    if (profile == null || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final saved = await _repository.saveProfile(
        profile.copyWith(
          firstName: _firstName.text,
          lastName: _lastName.text,
          companyName: _companyName.text,
          companyNumber: _companyNumber.text,
          vatNumber: _vatNumber.text,
          address: _address.text,
          phone: _phone.text,
          professionalTitle: _professionalTitle.text,
          updatedAt: DateTime.now().toUtc(),
        ),
      );
      if (!mounted) return;
      setState(() => _profile = saved);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil professionnel enregistré.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enregistrement impossible : $error'),
          backgroundColor: const Color(0xFFB42318),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? value) {
    return (value?.trim().isEmpty ?? true) ? 'Champ obligatoire.' : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil professionnel')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error.toString(), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _load,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Form(
                    key: _formKey,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              initialValue: _profile?.email ?? '',
                              enabled: false,
                              decoration: const InputDecoration(
                                labelText: 'Adresse e-mail',
                                prefixIcon: Icon(Icons.mail_outline),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _firstName,
                                    validator: _required,
                                    decoration: const InputDecoration(
                                      labelText: 'Prénom',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: TextFormField(
                                    controller: _lastName,
                                    validator: _required,
                                    decoration: const InputDecoration(
                                      labelText: 'Nom',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _professionalTitle,
                              decoration: const InputDecoration(
                                labelText: 'Titre professionnel',
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _companyName,
                              decoration: const InputDecoration(
                                labelText: 'Entreprise',
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _companyNumber,
                              decoration: const InputDecoration(
                                labelText: 'Numéro d’entreprise',
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _vatNumber,
                              decoration: const InputDecoration(
                                labelText: 'Numéro de TVA',
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _address,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'Adresse professionnelle',
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Téléphone',
                              ),
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: _saving ? null : _save,
                              icon: _saving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.save_outlined),
                              label: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Text('Enregistrer le profil'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
