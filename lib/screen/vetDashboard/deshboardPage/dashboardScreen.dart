import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VetDashboard extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  VetDashboard({super.key});

  /// Today’s Appointments Stream
  Stream<List<Map<String, dynamic>>> getAppointments() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _firestore
        .collection('appointments')
        .where('Veterinarian_Id', isEqualTo: user.uid)
        .where('Scheduled_DateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('Scheduled_DateTime',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['Appointment_Id'] = doc.id;
              return data;
            }).toList());
  }

  /// Appointment Card
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const Icon(Icons.pets, color: Colors.deepPurple, size: 36),
        title:
            Text(petName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(breed),
            const SizedBox(height: 4),
            Text(reason, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(dateTime,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 4),
            Text(status,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: statusColor)),
          ],
        ),
      ),
    );
  }

  /// Dashboard UI
  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore
                .collection('users')
                .doc(_auth.currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              String vetName = "Doctor";
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                vetName = data['name'] ?? "Doctor";
              }
              return _welcomeBox(vetName);
            },
          ),
          const SizedBox(height: 20),
          const Text(
            "Today's Appointments",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),

          // Real-time appointments list
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: getAppointments(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text("No appointments for today.");
              }

              final appointments = snapshot.data!;

              return Column(
                children: appointments.map((appointment) {
                  String formattedDate = "Unknown time";
                  if (appointment['Scheduled_DateTime'] != null) {
                    final ts = appointment['Scheduled_DateTime'];
                    if (ts is Timestamp) {
                      formattedDate = DateFormat("hh:mm a").format(ts.toDate());
                    }
                  }

                  return FutureBuilder<DocumentSnapshot>(
                    future: _firestore
                        .collection('pet')
                        .doc(appointment['Pet_Id'])
                        .get(),
                    builder: (context, petSnapshot) {
                      if (petSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      String petName = "Unknown Pet";
                      String breed = "";
                      if (petSnapshot.hasData && petSnapshot.data!.exists) {
                        final petData =
                            petSnapshot.data!.data() as Map<String, dynamic>;
                        petName = petData['pet_name'] ?? "Unnamed Pet";
                        breed =
                            "${petData['pet_bread'] ?? ''} (${petData['pet_species'] ?? ''})";
                      }

                      return _buildAppointmentCard(
                        appointment['Appointment_Id'],
                        petName,
                        breed,
                        formattedDate,
                        appointment['Scheduled_Notes'] ??
                            "", // Use Scheduled_Notes
                        appointment['Status'] ?? "pending",
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Welcome Box
  Widget _welcomeBox(String vetName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8A4FFF), Color(0xFF5425A5)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome, $vetName!",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Your Today's Appointments",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildDashboard());
  }
}
