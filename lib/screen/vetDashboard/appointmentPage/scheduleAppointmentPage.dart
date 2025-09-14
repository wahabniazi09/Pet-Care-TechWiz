import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleAppointmentPage extends StatefulWidget {
  final String appointmentId;
  const ScheduleAppointmentPage({super.key, required this.appointmentId});

  @override
  State<ScheduleAppointmentPage> createState() =>
      _ScheduleAppointmentPageState();
}

class _ScheduleAppointmentPageState extends State<ScheduleAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _scheduledDateTime;
  String _scheduledStatus = "pending";

  final _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? _appointmentData;

  @override
  void initState() {
    super.initState();
    _loadAppointment();
  }

  Future<void> _loadAppointment() async {
    final doc = await _firestore
        .collection("appointments")
        .doc(widget.appointmentId)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _appointmentData = data;
        _notesController.text = data["Notes"] ?? "";
        if (data["Scheduled_DateTime"] != null &&
            data["Scheduled_DateTime"] is Timestamp) {
          _scheduledDateTime =
              (data["Scheduled_DateTime"] as Timestamp).toDate();
        }
        _scheduledStatus = data["Scheduled_Status"] ?? "pending";
      });
    }
  }

  Future<void> _pickDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _scheduledDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime =
          await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (pickedTime != null) {
        setState(() {
          _scheduledDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _addSchedule() async {
    if (_formKey.currentState!.validate() && _scheduledDateTime != null) {
      await _firestore
          .collection("appointments")
          .doc(widget.appointmentId)
          .update({
        "Scheduled_DateTime": Timestamp.fromDate(_scheduledDateTime!),
        "Scheduled_Notes": _notesController.text.trim(),
        "Status": _scheduledStatus,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Schedule added successfully!")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final originalDate = _appointmentData?["Date_Time"];
    String originalDateText = "Not provided";
    if (originalDate is Timestamp) {
      originalDateText =
          DateFormat("dd/MM/yyyy, hh:mm a").format(originalDate.toDate());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Schedule"),
        backgroundColor: Colors.deepPurple,
      ),
      body: _appointmentData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Original Requested Time:",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(originalDateText,
                        style: const TextStyle(color: Colors.grey)),
                    const Divider(height: 30),

                    /// Scheduled date
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _scheduledDateTime != null
                                ? DateFormat("dd/MM/yyyy, hh:mm a")
                                    .format(_scheduledDateTime!)
                                : "No schedule date selected",
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _pickDateTime,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple),
                          child: const Text("Pick Date & Time"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    /// Notes
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Vet Notes",
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null || val.isEmpty
                          ? "Please enter notes"
                          : null,
                    ),
                    const SizedBox(height: 16),

                    /// Status dropdown
                    DropdownButtonFormField<String>(
                      value: _scheduledStatus,
                      items: const [
                        DropdownMenuItem(
                            value: "pending", child: Text("Pending")),
                        DropdownMenuItem(
                            value: "approved", child: Text("Approved")),
                        DropdownMenuItem(
                            value: "rejected", child: Text("Rejected")),
                      ],
                      onChanged: (val) =>
                          setState(() => _scheduledStatus = val!),
                      decoration: const InputDecoration(
                          labelText: "Schedule Status",
                          border: OutlineInputBorder()),
                    ),

                    const Spacer(),

                    /// Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addSchedule,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("Save Schedule"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
