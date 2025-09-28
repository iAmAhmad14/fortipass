import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddEntryScreen extends StatefulWidget {
  final String category;
  const AddEntryScreen({super.key, required this.category});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  final Map<String, List<String>> fieldTemplates = {
    'Passwords': ['Title', 'Username', 'Email', 'Password', 'URL'],
    'Notes': ['Title', 'Note'],
    'ID Cards': ['Title', 'Full Name', 'ID Number', 'Expiry Date'],
    'Credit Cards': ['Title', 'Card Number', 'Holder Name', 'Expiry', 'CVV'],
  };

  final Map<String, List<TextInputType>> fieldInputTypes = {
    'Passwords': [
      TextInputType.text,
      TextInputType.text,
      TextInputType.emailAddress,
      TextInputType.text,
      TextInputType.url,
    ],
    'Notes': [TextInputType.text, TextInputType.multiline],
    'ID Cards': [
      TextInputType.text,
      TextInputType.text,
      TextInputType.text,
      TextInputType.datetime,
    ],
    'Credit Cards': [
      TextInputType.text,
      TextInputType.number,
      TextInputType.text,
      TextInputType.datetime,
      TextInputType.number,
    ],
  };

  void _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final data = {for (var key in _controllers.keys) key: _controllers[key]!.text};
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection(widget.category)
        .add(data);

    if (mounted) Navigator.pop(context);
  }

  String? _validateField(String fieldName, String? value) {
    if (value == null || value.isEmpty) {
      if (fieldName == 'Title') return 'Required';
      if (fieldName == 'Email' && widget.category == 'Passwords') return null;
      return 'Required';
    }

    if (fieldName == 'CVV' && value.length != 3) {
      return 'Must be 3 digits';
    }

    if (fieldName == 'Card Number' && value.length != 16) {
      return 'Must be 16 digits';
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    for (var field in fieldTemplates[widget.category] ?? []) {
      _controllers[field] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fields = fieldTemplates[widget.category] ?? [];
    final inputTypes = fieldInputTypes[widget.category] ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Add ${widget.category}', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              for (int i = 0; i < fields.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fields[i],
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _controllers[fields[i]],
                        keyboardType: inputTypes[i],
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[900],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        maxLines: fields[i] == 'Note' ? 5 : 1,
                        validator: (value) => _validateField(fields[i], value),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'SAVE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}