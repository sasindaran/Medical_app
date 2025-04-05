import 'package:flutter/material.dart';
import 'db_helper.dart';

class AddPatientPage extends StatefulWidget {
  const AddPatientPage({super.key});

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _addPatient() async {
    if (_formKey.currentState!.validate()) {
      final db = DBHelper();
      await db.insertUser(
        _usernameController.text,
        _passwordController.text,
        'Patient', // fixed role
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Patient added successfully")),
      );
      _usernameController.clear();
      _passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Patient")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Patient ID"),
                validator: (value) =>
                    value!.isEmpty ? "Enter Patient ID" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? "Enter Password" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addPatient,
                child: const Text("Add Patient"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
