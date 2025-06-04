import 'package:flutter/material.dart';
import 'package:client/data/dummy_items.dart';
import 'package:client/features/home/widgets/product_card.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final String userName = "Thompson";
  final String email = "thawzin.moem@kmutt.ac.th";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Edit profile tapped')));
              } else if (value == 'logout') {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Log out tapped')));
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
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Icon
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
                userName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                email,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Text(
                  'Listed Items',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: dummyItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemBuilder:
                    (context, index) => ProductCard(data: dummyItems[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
