import 'package:flutter/material.dart';
import 'db_helper.dart';

class EditPatientPage extends StatefulWidget {
  final Map<String, dynamic> patient;

  const EditPatientPage({super.key, required this.patient});

  @override
  State<EditPatientPage> createState() => _EditPatientPageState();
}

class _EditPatientPageState extends State<EditPatientPage> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  final dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.patient['username']);
    _passwordController = TextEditingController(text: widget.patient['password']);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updatePatient() async {
    final newPassword = _passwordController.text;
    final username = widget.patient['username'];

    await dbHelper.updateUser(username, newPassword);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Patient updated successfully')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Patient')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updatePatient,
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
