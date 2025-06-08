import 'package:client/features/profile/screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/features/profile/providers/profile_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final box = Hive.box('authBox');
    final profileAsync = ref.watch(profileProvider);
    final localUserId = box.get('user_id');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                // Get the latest profile data
                final user = ref.read(profileProvider).value;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No profile data to edit.')),
                  );
                  return;
                }
                // Use GoRouter to navigate and await result
                final result = await context.push<String>(
                  '/edit-profile',
                  extra: user['name'] ?? '',
                );
                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name updated successfully!')),
                  );
                }
              } else if (value == 'logout') {
                await box.clear();
                ref.invalidate(profileProvider);
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'logout', child: Text('Log out')),
                ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          // Navigate to Add Item page
          context.push('/add-item');
        },
        child: const Icon(Icons.add),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Failed to load profile.')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No profile data.'));
          }
          // Validate user id from backend matches local storage
          if (user['id'] != localUserId) {
            // Log out and redirect if not matching
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await box.clear();
              ref.invalidate(profileProvider);
              if (context.mounted) {
                context.go('/login');
              }
            });
            return const Center(
              child: Text('Session expired. Please log in again.'),
            );
          }
          final items = user['items'] as List<dynamic>? ?? [];
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.green[100],
                  child: Icon(
                    Icons.account_circle,
                    size: 64,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    user['name'] ?? 'Unknown User',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    user['email'] ?? 'No Email',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Text(
                      'Listed Items',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child:
                      items.isEmpty
                          ? const Center(child: Text('No items listed.'))
                          : GridView.builder(
                            itemCount: items.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 0.7,
                                ),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              // You can customize ProductCard to accept your item structure
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'] ?? 'No Name',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(item['description'] ?? ''),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
