import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Appointments")),
        body: const Center(
          child: Text("Please login to see your appointments"),
        ),
      );
    }

    final appointmentsRef = firestore
        .collection("appointments")
        .where("owner_id", isEqualTo: user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Appointments"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: appointmentsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final appointments = snapshot.data!.docs;

          if (appointments.isEmpty) {
            return const Center(
              child: Text(
                "No appointments booked yet",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final data = appointments[index].data() as Map<String, dynamic>;

              final requestDate = (data["date_time"] as Timestamp?)?.toDate();
              final scheduledDate =
                  (data["Scheduled_DateTime"] as Timestamp?)?.toDate();
              final scheduledStatus = data["Status"] ?? "Not Scheduled";
              final scheduledNotes = data["Scheduled_Notes"] ?? "";

              final petId = data["Pet_Id"];
              final vetId = data["Veterinarian_Id"];
              final status = data["status"] ?? "Pending";
              final notes = data["notes"] ?? "";

              return FutureBuilder<DocumentSnapshot>(
                future: firestore.collection("pet").doc(petId).get(),
                builder: (context, petSnapshot) {
                  String petName = "Unknown Pet";
                  if (petSnapshot.hasData && petSnapshot.data!.exists) {
                    final petData =
                        petSnapshot.data!.data() as Map<String, dynamic>;
                    petName = petData["pet_name"] ?? "Unnamed Pet";
                  }

                  return FutureBuilder<DocumentSnapshot>(
                    future: firestore.collection("users").doc(vetId).get(),
                    builder: (context, vetSnapshot) {
                      String vetName = "Unknown Vet";
                      if (vetSnapshot.hasData && vetSnapshot.data!.exists) {
                        final vetData =
                            vetSnapshot.data!.data() as Map<String, dynamic>;
                        vetName = vetData["name"] ?? "Unnamed Vet";
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Header
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.pets,
                                        color: Colors.deepPurple),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          petName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          "Vet: $vetName",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),
                              const Divider(),

                              /// Appointment details
                              if (requestDate != null)
                                Row(
                                  children: [
                                    const Icon(Icons.schedule,
                                        color: Colors.blue, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Requested: ${DateFormat("dd MMM yyyy, hh:mm a").format(requestDate)}",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),

                              const SizedBox(height: 6),

                              if (notes.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.note,
                                        color: Colors.grey, size: 18),
                                    const SizedBox(width: 6),
                                    Expanded(
                                        child: Text("Owner Notes: $notes")),
                                  ],
                                ),
                              ],

                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            color: Colors.deepPurple, size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          scheduledDate != null
                                              ? "Shedule: ${DateFormat("dd MMM yyyy, hh:mm a").format(scheduledDate)}"
                                              : "Not Scheduled",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text("Vet Status: $scheduledStatus"),
                                    if (scheduledNotes.isNotEmpty)
                                      Text("Vet Notes: $scheduledNotes"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
