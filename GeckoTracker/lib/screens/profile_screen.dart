import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/gecko_profile.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final GeckoProfile profile;
  final void Function(GeckoProfile profile) onSave;

  const ProfileScreen({
    super.key,
    required this.profile,
    required this.onSave,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _morphController;
  late TextEditingController _notesController;
  late String _sex;
  late DateTime _birthDate;
  late String _avatarPath;
  late GeckoProfile _currentProfile;

  final List<String> _sexOptions = ['Самец', 'Самка', 'Не определен'];

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.profile;
    _nameController = TextEditingController(text: _currentProfile.name);
    _morphController = TextEditingController(text: _currentProfile.morph);
    _notesController = TextEditingController(text: _currentProfile.notes);
    _sex = _currentProfile.sex;
    _birthDate = _currentProfile.birthDate;
    _avatarPath = _currentProfile.avatarPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _morphController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _avatarPath = pickedFile.path;
      });
      _save();
    }
  }

  void _save() {
    final updated = _currentProfile.copyWith(
      name: _nameController.text.trim(),
      morph: _morphController.text.trim(),
      sex: _sex,
      birthDate: _birthDate,
      notes: _notesController.text.trim(),
      avatarPath: _avatarPath,
    );
    _currentProfile = updated;
    widget.onSave(updated);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Профиль геккона обновлен!'),
        backgroundColor: AppTheme.secondaryPurple,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValidAvatar =
        _avatarPath.isNotEmpty && File(_avatarPath).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль питомца'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Аватарка
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 54,
                      backgroundColor: AppTheme.surfaceLight,
                      backgroundImage:
                          hasValidAvatar ? FileImage(File(_avatarPath)) : null,
                      child: !hasValidAvatar
                          ? const Icon(Icons.pets_rounded,
                              size: 55, color: AppTheme.primaryPurple)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.primaryPurple,
                        child: const Icon(Icons.camera_alt_rounded,
                            size: 18, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Поля ввода
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Кличка питомца',
                prefixIcon: Icon(Icons.badge_rounded, color: AppTheme.primaryPurple),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _morphController,
              decoration: const InputDecoration(
                labelText: 'Морфа (окрас)',
                prefixIcon: Icon(Icons.palette_rounded, color: AppTheme.primaryPurple),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _sex,
              decoration: const InputDecoration(
                labelText: 'Пол',
                prefixIcon: Icon(Icons.transgender_rounded, color: AppTheme.primaryPurple),
              ),
              items: _sexOptions
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _sex = v!),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.cake_rounded, color: AppTheme.primaryPurple),
                title: const Text('Дата рождения / приобретения'),
                subtitle: Text(DateFormat('dd.MM.yyyy').format(_birthDate)),
                trailing: const Icon(Icons.edit_calendar_rounded),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _birthDate,
                    firstDate: DateTime(2010),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _birthDate = picked);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Особые отметки / Характер',
                prefixIcon: Icon(Icons.description_rounded, color: AppTheme.primaryPurple),
              ),
            ),
            const SizedBox(height: 24),

            // Кнопка сохранения профиля
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Сохранить изменения',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),

            const Divider(height: 40, color: Color(0xFF2E2740)),

            // Блок напоминаний
            const Text(
              'Напоминания о кормлении',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final name = _nameController.text.trim().isEmpty
                          ? 'эублефара'
                          : _nameController.text.trim();
                      NotificationService.scheduleFeedingReminder(
                        hour: 9,
                        minute: 0,
                        geckoName: name,
                      );
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Утреннее напоминание (09:00) установлено'),
                          backgroundColor: AppTheme.surfaceLight,
                        ),
                      );
                    },
                    icon: const Icon(Icons.wb_sunny_rounded),
                    label: const Text('Утро (09:00)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.surfaceLight,
                      foregroundColor: AppTheme.primaryPurple,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final name = _nameController.text.trim().isEmpty
                          ? 'эублефара'
                          : _nameController.text.trim();
                      NotificationService.scheduleFeedingReminder(
                        hour: 19,
                        minute: 0,
                        geckoName: name,
                      );
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Вечернее напоминание (19:00) установлено'),
                          backgroundColor: AppTheme.surfaceLight,
                        ),
                      );
                    },
                    icon: const Icon(Icons.nights_stay_rounded),
                    label: const Text('Вечер (19:00)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.surfaceLight,
                      foregroundColor: AppTheme.primaryPurple,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
