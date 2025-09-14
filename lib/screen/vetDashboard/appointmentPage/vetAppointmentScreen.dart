import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_care/consts/firebase_consts.dart';
import 'package:pet_care/screen/vetDashboard/appointmentPage/scheduleAppointmentPage.dart';


class VetAppointmentsScreen extends StatefulWidget {
  const VetAppointmentsScreen({super.key});

  @override
  State<VetAppointmentsScreen> createState() => _VetAppointmentsScreenState();
}

class _VetAppointmentsScreenState extends State<VetAppointmentsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

        final appointments = snapshot.data!;

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

                return _buildAppointmentCard(
                  appointment['Appointment_Id'],
                  petData['pet_name'] ?? "Unnamed Pet",
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
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: const Icon(Icons.pets, color: Colors.deepPurple, size: 36),
          title: Text(petName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: statusColor)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildAppointments(),
    );
  }
}
