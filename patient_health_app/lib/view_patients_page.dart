import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'patient_records_page.dart';
import 'edit_patient_page.dart';

class ViewPatientsPage extends StatefulWidget {
  const ViewPatientsPage({super.key});

  @override
  State<ViewPatientsPage> createState() => _ViewPatientsPageState();
}

class _ViewPatientsPageState extends State<ViewPatientsPage> {
  List<Map<String, dynamic>> patients = [];

  void _fetchPatients() async {
    final db = DBHelper();
    final allUsers = await db.getUsers();
    setState(() {
      patients = allUsers.where((user) => user['role'] == 'Patient').toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  void _showOptions(Map<String, dynamic> patient) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
        children: [
          ListTile(
            title: const Text('Edit Details'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditPatientPage(patient: patient),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Records'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PatientRecordsPage(
                    patientId: patient['username'], // ✅ FIXED: username instead of id
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Patients')),
      body: ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
         return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 3,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showOptions(patient),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              patient['username'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    ),
  ),
);

        },
      ),
    );
  }
}
