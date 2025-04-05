import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'admin_home_page.dart';
import 'patient_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final dbHelper = DBHelper();

  String selectedRole = 'Admin/Doctor';
  final List<String> roles = ['Admin/Doctor', 'Patient'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField(
              value: selectedRole,
              items: roles
                  .map((role) =>
                      DropdownMenuItem(value: role, child: Text(role)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedRole = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Select Role'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final username = _usernameController.text.trim();
                final password = _passwordController.text.trim();

                final user = await dbHelper.validateUser(username, password);

                if (user != null) {
                  final role = user['role'];

                  if ((selectedRole == 'Admin/Doctor' && (role == 'Admin' || role == 'Doctor')) ||
                      (selectedRole == 'Patient' && role == 'Patient')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Login successful as $role")),
                    );

                    if (role == 'Admin' || role == 'Doctor') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminHomePage()),
                      );
                    } else {
                     Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PatientHomePage(patientId: username),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Role mismatch!")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invalid credentials")),
                  );
                }
              },
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
