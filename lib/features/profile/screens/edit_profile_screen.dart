import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/features/profile/providers/profile_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final String currentName;
  const EditProfileScreen({super.key, required this.currentName});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
      return;
    }
    setState(() => _loading = true);
    final box = Hive.box('authBox');
    final token = box.get('auth_token');
    final profileService = ref.read(profileServiceProvider);

    final success = await profileService.updateName(
      token,
      _nameController.text,
    );
    setState(() => _loading = false);

    if (success) {
      ref.invalidate(profileProvider); // Refresh profile on success
      if (mounted) Navigator.pop(context, _nameController.text);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to update name')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('Save'),
                ),
          ],
        ),
      ),
    );
  }
}
