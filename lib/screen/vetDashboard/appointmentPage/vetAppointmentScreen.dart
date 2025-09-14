import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_care/consts/firebase_consts.dart';
import 'package:pet_care/screen/vetDashboard/appointmentPage/scheduleAppointmentPage.dart';

<<<<<<< HEAD

=======
/// ---------------------------
/// VET SIDE - View Appointments with Filters
/// ---------------------------
>>>>>>> 0f754525050b5a6ceacc01dabd80f026c15266b0
class VetAppointmentsScreen extends StatefulWidget {
  const VetAppointmentsScreen({super.key});

  @override
  State<VetAppointmentsScreen> createState() => _VetAppointmentsScreenState();
}

class _VetAppointmentsScreenState extends State<VetAppointmentsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _searchName = "";
  DateTime? _selectedDate;

  Stream<List<Map<String, dynamic>>> getAppointments() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('appointments')
        .where('Veterinarian_Id', isEqualTo: currentUser!.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['Appointment_Id'] = doc.id; // docId
              return data;
            }).toList());
  }

  /// Cancel appointment function
  void _cancelAppointment(String appointmentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Appointment"),
        content:
            const Text("Are you sure you want to cancel this appointment?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("No")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestore.collection('appointments').doc(appointmentId).delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Appointment canceled successfully."),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to cancel appointment: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Build vet’s appointment list
  Widget _buildAppointments() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: getAppointments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No appointments found."));
        }

        var appointments = snapshot.data!;

        // Filter by selected date
        if (_selectedDate != null) {
          appointments = appointments.where((appointment) {
            if (appointment['Date_Time'] is Timestamp) {
              final dt = (appointment['Date_Time'] as Timestamp).toDate();
              return dt.year == _selectedDate!.year &&
                  dt.month == _selectedDate!.month &&
                  dt.day == _selectedDate!.day;
            }
            return false;
          }).toList();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];

            String formattedDate = "Unknown time";
            if (appointment['Date_Time'] != null) {
              final ts = appointment['Date_Time'];
              if (ts is Timestamp) {
                formattedDate =
                    DateFormat("dd/MM/yyyy, hh:mm a").format(ts.toDate());
              }
            }

            final petId = appointment['Pet_Id'];

            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('pet').doc(petId).get(),
              builder: (context, petSnapshot) {
                if (petSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!petSnapshot.hasData || !petSnapshot.data!.exists) {
                  return _buildAppointmentCard(
                    appointment['Appointment_Id'],
                    "Unknown Pet",
                    "",
                    formattedDate,
                    appointment['Notes'] ?? "",
                    appointment['Status'] ?? "pending",
                  );
                }

                final petData =
                    petSnapshot.data!.data() as Map<String, dynamic>;
                final petName = petData['pet_name'] ?? "Unnamed Pet";

                // Filter by pet name (case-insensitive)
                if (_searchName.isNotEmpty &&
                    !petName
                        .toLowerCase()
                        .contains(_searchName.toLowerCase())) {
                  return const SizedBox.shrink();
                }

                return _buildAppointmentCard(
                  appointment['Appointment_Id'],
                  petName,
                  "${petData['pet_bread'] ?? ''} (${petData['pet_species'] ?? ''})",
                  formattedDate,
                  appointment['Notes'] ?? "",
                  appointment['Status'] ?? "pending",
                );
              },
            );
          },
        );
      },
    );
  }

  
  Widget _buildAppointmentCard(String appointmentId, String petName,
      String breed, String dateTime, String reason, String status) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case "approved":
        statusColor = Colors.green;
        break;
      case "rejected":
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScheduleAppointmentPage(
              appointmentId: appointmentId,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.pets, color: Colors.deepPurple, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(petName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(breed),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(dateTime,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple)),
                      const SizedBox(height: 4),
                      Text(status,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: statusColor)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(reason, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _cancelAppointment(appointmentId),
                  child: const Text("Cancel",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Filter bar with search and date picker
  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search by pet name...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              onChanged: (val) {
                setState(() {
                  _searchName = val;
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.deepPurple),
            onPressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                setState(() {
                  _selectedDate = pickedDate;
                });
              }
            },
          ),
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.red),
              onPressed: () {
                setState(() {
                  _selectedDate = null;
                });
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildAppointments()),
        ],
      ),
    );
  }
}
