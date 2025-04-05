import 'package:flutter/material.dart';
import 'db_helper.dart';

class SetPriorityConditionPage extends StatefulWidget {
  final String username;

  const SetPriorityConditionPage({super.key, required this.username});

  @override
  State<SetPriorityConditionPage> createState() => _SetPriorityConditionPageState();
}

class _SetPriorityConditionPageState extends State<SetPriorityConditionPage> {
  final _treatmentController = TextEditingController();
  final _prescriptionController = TextEditingController();

  bool _isSaved = false;

  Future<void> _saveCondition() async {
    final treatment = _treatmentController.text.trim();
    final prescription = _prescriptionController.text.trim();

    if (treatment.isNotEmpty && prescription.isNotEmpty) {
      final db = DBHelper();
      await db.setPriorityCondition(widget.username, treatment, prescription);
      setState(() {
        _isSaved = true;
      });
    }
  }

  @override
  void dispose() {
    _treatmentController.dispose();
    _prescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set Priority Condition")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Assign a condition to: ${widget.username}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            TextField(
              controller: _treatmentController,
              decoration: const InputDecoration(labelText: "Treatment (e.g., Cancer)"),
            ),
            TextField(
              controller: _prescriptionController,
              decoration: const InputDecoration(labelText: "Prescription (e.g., Med A, Med B)"),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveCondition,
              child: const Text("Save Condition"),
            ),
            if (_isSaved)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text("✅ Priority condition saved!", style: TextStyle(color: Colors.green)),
              )
          ],
        ),
      ),
    );
  }
}
