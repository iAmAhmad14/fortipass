import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:async/async.dart'; // Add this import for StreamZip
import 'add_entry_screen.dart';
import 'category_list_screen.dart';
import 'detail_screen.dart'; // Add this import for DetailScreen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openCategory(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryListScreen(category: category),
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return Wrap(
          children: ['Passwords', 'Notes', 'ID Cards', 'Credit Cards']
              .map(
                (type) => ListTile(
              title: Text(
                type,
                style: const TextStyle(color: Colors.white),
              ),
              leading: Icon(
                _getIconForCategory(type),
                color: Colors.red,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEntryScreen(category: type),
                  ),
                );
              },
            ),
          )
              .toList(),
        );
      },
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Passwords':
        return Icons.lock;
      case 'Notes':
        return Icons.note;
      case 'ID Cards':
        return Icons.credit_card;
      case 'Credit Cards':
        return Icons.payment;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('FortiPass', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: UniversalSearchDelegate(userId: FirebaseAuth.instance.currentUser?.uid ?? ''),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 1,
                childAspectRatio: 3.5,
                mainAxisSpacing: 20,
                children: [
                  _buildCategoryCard(context, 'Passwords', Icons.lock),
                  _buildCategoryCard(context, 'Notes', Icons.note),
                  _buildCategoryCard(context, 'ID Cards', Icons.credit_card),
                  _buildCategoryCard(context, 'Credit Cards', Icons.payment),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEntryDialog(context),
        backgroundColor: Colors.red[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String label, IconData icon) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(color: Colors.red[800]!, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15.0),
        onTap: () => _openCategory(context, label),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 30, color: Colors.red),
              const SizedBox(width: 20),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class UniversalSearchDelegate extends SearchDelegate<String> {
  final String userId;

  UniversalSearchDelegate({required this.userId});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(
        child: Text('Start typing to search across all entries',
            style: TextStyle(color: Colors.white)),
      );
    }

    return StreamBuilder<List<QuerySnapshot>>(
      stream: _getCombinedStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = <Map<String, dynamic>>[];
        final categories = ['Passwords', 'Notes', 'ID Cards', 'Credit Cards'];

        for (int i = 0; i < categories.length; i++) {
          final categoryDocs = snapshot.data?[i].docs ?? [];
          for (final doc in categoryDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final title = data['Title']?.toString().toLowerCase() ?? '';
            if (title.contains(query.toLowerCase())) {
              results.add({
                ...data,
                'id': doc.id,
                'category': categories[i],
              });
            }
          }
        }

        if (results.isEmpty) {
          return const Center(
            child: Text('No matching entries found',
                style: TextStyle(color: Colors.white)),
          );
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final entry = results[index];
            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: ListTile(
                title: Text(entry['Title'] ?? 'Untitled',
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  'Type: ${entry['category']}',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(
                        category: entry['category'],
                        docId: entry['id'],
                        data: entry,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Stream<List<QuerySnapshot>> _getCombinedStream() {
    final categories = ['Passwords', 'Notes', 'ID Cards', 'Credit Cards'];
    final streams = categories.map((category) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection(category)
          .orderBy('Title')
          .snapshots();
    }).toList();

    return StreamZip(streams);
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: const TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: const TextStyle(color: Colors.white),
      ),
    );
  }
}