import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HealthRecordsScreen extends StatelessWidget {
  const HealthRecordsScreen({super.key});

  Stream<QuerySnapshot> getHealthRecords(String uid) {
    return FirebaseFirestore.instance
        .collection("medical_records")
        .orderBy("created_at", descending: true)
        .snapshots();
  }

  Future<String> getPetName(String petId) async {
    if (petId.isEmpty) return "Unknown Pet";
    final petDoc =
        await FirebaseFirestore.instance.collection("pet").doc(petId).get();
    return petDoc.exists
        ? (petDoc["pet_name"] ?? "Unnamed Pet")
        : "Unknown Pet";
  }

  Future<String> getVetName(String vetId) async {
    if (vetId.isEmpty) return "Unknown Vet";
    final vetDoc =
        await FirebaseFirestore.instance.collection("users").doc(vetId).get();
    return vetDoc.exists ? (vetDoc["name"] ?? "Unnamed Vet") : "Unknown Vet";
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please login to view health records.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Records"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getHealthRecords(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No health records found."));
          }

          final records = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final data = records[index].data() as Map<String, dynamic>;

              final createdAt = (data["created_at"] as Timestamp?)?.toDate();
              final formattedDate = createdAt != null
                  ? DateFormat("dd MMM yyyy, hh:mm a").format(createdAt)
                  : "Unknown date";

              final diagnosis = data["diagnosis"] ?? "Not provided";
              final treatment = data["treatment"] ?? "Not provided";
              final prescription = data["prescription"] ?? "Not provided";
              final petId = data["pet_id"] ?? "";
              final vetId = data["vet_id"] ?? "";

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.medical_information,
                      color: Colors.deepPurple, size: 40),
                  title: Text("Diagnosis: $diagnosis",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text("Date: $formattedDate",
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text("Health Record Details"),
                          content: FutureBuilder(
                            future: Future.wait([
                              getPetName(petId),
                              getVetName(vetId),
                            ]),
                            builder:
                                (context, AsyncSnapshot<List<String>> snap) {
                              if (!snap.hasData) {
                                return const SizedBox(
                                  height: 80,
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              }
                              final petName = snap.data![0];
                              final vetName = snap.data![1];

                              return SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Diagnosis: $diagnosis"),
                                    const SizedBox(height: 6),
                                    Text("Treatment: $treatment"),
                                    const SizedBox(height: 6),
                                    Text("Prescription: $prescription"),
                                    const SizedBox(height: 6),
                                    Text("Pet: $petName"),
                                    const SizedBox(height: 6),
                                    Text("Vet: $vetName"),
                                    const SizedBox(height: 6),
                                    Text("Created At: $formattedDate",
                                        style: const TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey)),
                                  ],
                                ),
                              );
                            },
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext), // ✅ Fixed
                              child: const Text("Close"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
