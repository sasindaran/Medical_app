import 'package:flutter/material.dart';
import 'db_helper.dart';

class AddAdminPage extends StatefulWidget {
  const AddAdminPage({super.key});

  @override
  State<AddAdminPage> createState() => _AddAdminPageState();
}

class _AddAdminPageState extends State<AddAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _addAdmin() async {
    if (_formKey.currentState!.validate()) {
      final dbHelper = DBHelper();
      await dbHelper.insertUser(
        _usernameController.text,
        _passwordController.text,
        'Admin', // role is fixed
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin added successfully')),
      );

      _usernameController.clear();
      _passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Admin')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a username' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a password' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addAdmin,
                child: const Text('Add Admin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
