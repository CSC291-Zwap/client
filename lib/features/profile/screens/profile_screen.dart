import 'package:client/data/models/item.dart';
import 'package:client/features/home/widgets/product_card.dart';
import 'package:client/features/profile/screens/edit_profile_screen.dart';
import 'package:client/services/profile_service.dart';
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
                // Get the current profile data from the async value
                final currentProfile = ref.read(profileProvider);

                // Check if we have valid profile data
                if (!currentProfile.hasValue || currentProfile.value == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No profile data to edit.')),
                  );
                  return;
                }

                final data = currentProfile.value!;
                final user = data['user'] as Map<String, dynamic>?;

                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No user data to edit.')),
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
        error: (err, stack) {
          // Redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final box = Hive.box('authBox');
            await box.clear();
            ref.invalidate(profileProvider);
            if (context.mounted) {
              context.go('/login');
            }
          });
          return const Center(
            child: Text('Session expired. Please log in again.'),
          );
        },
        data: (data) {
          print('Profile data fetched: $data');
          if (data == null) {
            return const Center(child: Text('No profile data.'));
          }

          // Extract user info and items from the restructured data
          final user = data['user'] as Map<String, dynamic>?;
          print('User data: $user');
          final items =
              user != null ? (user['items'] as List<dynamic>? ?? []) : [];
          print('Items data: $items');
          if (user == null) {
            return const Center(child: Text('No user data.'));
          }

          // print('User data: $user');
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

          List<Item> itemsData =
              items.map((item) {
                return Item.fromJson(item);
              }).toList();

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
                    (user['name'] ?? 'Unknown User'),
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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
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
                      itemsData.isEmpty
                          ? const Center(child: Text('No items listed.'))
                          : GridView.builder(
                            itemCount: itemsData.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 0.7,
                                ),
                            itemBuilder: (context, index) {
                              final Item item = itemsData[index];
                              // print('Item in profile: $item');
                              return ProductCard(data: item);
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
