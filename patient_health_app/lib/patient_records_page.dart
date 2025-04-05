import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'package:intl/intl.dart';

class PatientRecordsPage extends StatefulWidget {
  final String patientId;

  const PatientRecordsPage({super.key, required this.patientId});

  @override
  State<PatientRecordsPage> createState() => _PatientRecordsPageState();
}

class _PatientRecordsPageState extends State<PatientRecordsPage> {
  final dbHelper = DBHelper();
  Map<String, dynamic>? priorityCondition;
  List<Map<String, dynamic>> records = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final priority = await dbHelper.getPriorityCondition(widget.patientId);
    final visits = await dbHelper.getRecordsByUsername(widget.patientId);
    setState(() {
      priorityCondition = priority;
      records = visits;
      isLoading = false;
    });
  }

  void _addVisit() {
    final causeController = TextEditingController();
    final dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );

    List<Map<String, TextEditingController>> prescriptionControllers = [
      {
        'name': TextEditingController(),
        'dosage': TextEditingController(),
      }
    ];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Visit'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Visit Date'),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: causeController,
                  decoration: const InputDecoration(labelText: 'Cause'),
                ),
                const SizedBox(height: 16),
                const Text('Prescriptions', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Column(
                  children: List.generate(prescriptionControllers.length, (index) {
                    final row = prescriptionControllers[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: row['name'],
                              decoration: const InputDecoration(labelText: 'Medicine Name'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: row['dosage'],
                              decoration: const InputDecoration(labelText: 'Dosage/Type'),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                prescriptionControllers.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Add More"),
                    onPressed: () {
                      setState(() {
                        prescriptionControllers.add({
                          'name': TextEditingController(),
                          'dosage': TextEditingController(),
                        });
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final cause = causeController.text.trim();
                final date = dateController.text.trim();
                final prescriptions = prescriptionControllers.map((row) {
                  final name = row['name']!.text.trim();
                  final dosage = row['dosage']!.text.trim();
                  return name.isNotEmpty && dosage.isNotEmpty ? '$name:$dosage' : null;
                }).whereType<String>().toList();

                if (cause.isNotEmpty && prescriptions.isNotEmpty && date.isNotEmpty) {
                  final prescriptionStr = prescriptions.join(',');
                  await dbHelper.insertRecord(widget.patientId, date, cause, prescriptionStr);
                  Navigator.pop(context);
                  _loadAll(); // refresh
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _setPriorityCondition() {
    final treatmentController = TextEditingController();
    final prescriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Set Priority Condition'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: treatmentController,
              decoration: const InputDecoration(labelText: 'Treatment'),
            ),
            TextField(
              controller: prescriptionController,
              decoration: const InputDecoration(labelText: 'Prescription'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final treatment = treatmentController.text.trim();
              final prescription = prescriptionController.text.trim();
              if (treatment.isNotEmpty && prescription.isNotEmpty) {
                await dbHelper.setPriorityCondition(widget.patientId, treatment, prescription);
                Navigator.pop(context);
                _loadAll(); // refresh
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildPrioritySection() {
  return Card(
    margin: const EdgeInsets.all(16),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: priorityCondition == null
          ? const Text('No priority condition set for this patient.')
          : GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Priority Condition Details'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Treatment: ${priorityCondition!['treatment']}'),
                        const SizedBox(height: 8),
                        Text('Prescription: ${priorityCondition!['prescription']}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Priority Condition', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Treatment: ${priorityCondition!['treatment']}'),
                ],
              ),
            ),
    ),
  );
}


  void _showVisitDetail(Map<String, dynamic> rec) {
    final prescriptionList = (rec['prescription'] as String).split(',').map((e) {
      final parts = e.split(':');
      return parts.length == 2 ? '${parts[0]} – ${parts[1]}' : e;
    }).toList();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Visit on ${rec['visit_date']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cause: ${rec['cause']}'),
            const SizedBox(height: 8),
            const Text('Prescriptions:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...prescriptionList.map((p) => Text(p)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  Widget _buildVisitHistory() {
    if (records.isEmpty) {
      return const Center(child: Text('No visit history found.'));
    }

    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final rec = records[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: ListTile(
            title: ElevatedButton(
              onPressed: () => _showVisitDetail(rec),
              child: Text('Date: ${rec['visit_date']} | Cause: ${rec['cause']}'),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_hospital),
            onPressed: _setPriorityCondition,
            tooltip: 'Set Priority',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addVisit,
            tooltip: 'Add Visit',
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildPrioritySection(),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Visit History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Expanded(child: _buildVisitHistory()),
              ],
            ),
    );
  }
}
