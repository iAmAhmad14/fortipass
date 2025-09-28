import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DetailScreen extends StatefulWidget {
  final String category;
  final String docId;
  final Map<String, dynamic> data;

  const DetailScreen({
    super.key,
    required this.category,
    required this.docId,
    required this.data,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final Map<String, TextEditingController> _controllers = {};
  bool _isEditing = false;
  final Map<String, bool> _obscureText = {};

  @override
  void initState() {
    super.initState();
    widget.data.forEach((key, value) {
      _controllers[key] = TextEditingController(text: value?.toString() ?? '');
      // Only obscure password fields
      _obscureText[key] = key.toLowerCase().contains('password') || key.toLowerCase().contains('cvv');
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final updatedData = {
      for (var key in _controllers.keys) key: _controllers[key]!.text
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection(widget.category)
        .doc(widget.docId)
        .update(updatedData);

    setState(() => _isEditing = false);
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _toggleObscure(String key) {
    setState(() {
      _obscureText[key] = !_obscureText[key]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.data['Title'] ?? 'Details',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit,
                color: Colors.white),
            onPressed: () {
              if (_isEditing) {
                _saveChanges();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: _controllers.entries.map((entry) {
                final isPasswordField = entry.key.toLowerCase().contains('password') ||
                    entry.key.toLowerCase().contains('cvv');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: entry.value,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[900],
                                enabled: _isEditing,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              obscureText: isPasswordField ? _obscureText[entry.key]! : false,
                              maxLines: entry.key == 'Note' ? 5 : 1,
                            ),
                          ),
                          if (!_isEditing)
                            IconButton(
                              icon: const Icon(Icons.copy, color: Colors.red),
                              onPressed: () => _copyToClipboard(entry.value.text),
                            ),
                          if (isPasswordField && !_isEditing)
                            IconButton(
                              icon: Icon(
                                _obscureText[entry.key]! ? Icons.visibility : Icons.visibility_off,
                                color: Colors.red,
                              ),
                              onPressed: () => _toggleObscure(entry.key),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red[800],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Type: ${widget.category}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}