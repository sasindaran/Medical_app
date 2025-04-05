import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'chat_bot_page.dart'; // Make sure to create this page in the next step

class PatientHomePage extends StatefulWidget {
  final String patientId;

  const PatientHomePage({super.key, required this.patientId});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  final dbHelper = DBHelper();
  Map<String, dynamic>? priorityCondition;
  List<Map<String, dynamic>> records = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final priority = await dbHelper.getPriorityCondition(widget.patientId);
    final visits = await dbHelper.getRecordsByUsername(widget.patientId);
    setState(() {
      priorityCondition = priority;
      records = visits;
      isLoading = false;
    });
  }

  Widget _buildPrioritySection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: priorityCondition == null
            ? const Text('No priority condition set.')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Priority Condition', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Treatment: ${priorityCondition!['treatment']}'),
                ],
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
            title: Text('Date: ${rec['visit_date']}'),
            subtitle: Text('Cause: ${rec['cause']}'),
            onTap: () => _showVisitDetail(rec),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Health Records'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatBotPage(username: widget.patientId),
            ),
          );
        },
        child: const Icon(Icons.chat),
        tooltip: 'Ask Health Assistant',
      ),
    );
  }
}
