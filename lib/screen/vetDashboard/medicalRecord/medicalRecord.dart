import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _searchQuery = "";

  /// Show Add Medical Record Form
  void _showAddRecordForm(String petId) {
    final diagnosisController = TextEditingController();
    final treatmentController = TextEditingController();
    final prescriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Add Medical Record",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5425A5)),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: diagnosisController,
                    decoration: InputDecoration(
                      labelText: "Diagnosis",
                      prefixIcon: const Icon(Icons.health_and_safety,
                          color: Color(0xFF5425A5)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: treatmentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Treatment Notes",
                      prefixIcon:
                          const Icon(Icons.note_alt, color: Color(0xFF5425A5)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: prescriptionController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: "Prescription",
                      prefixIcon: const Icon(Icons.medication,
                          color: Color(0xFF5425A5)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: const Color(0xFF5425A5),
                      ),
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text("Save Record",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        await _firestore.collection("medical_records").add({
                          "pet_id": petId,
                          "diagnosis": diagnosisController.text,
                          "treatment": treatmentController.text,
                          "prescription": prescriptionController.text,
                          "created_at": Timestamp.now(),
                          "vet_id": _auth.currentUser!.uid,
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Show all pets assigned to current vet (with approved appointments)
  Widget _buildMedicalRecords() {
    final currentVetId = _auth.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection("appointments")
          .where("Veterinarian_Id", isEqualTo: currentVetId)
          .where("Status", isEqualTo: "approved")
          .snapshots(),
      builder: (context, appointmentSnapshot) {
        if (appointmentSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!appointmentSnapshot.hasData ||
            appointmentSnapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No scheduled appointments."));
        }

        final scheduledAppointments =
            appointmentSnapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data["Pet_Id"] != null;
        }).toList();

        if (scheduledAppointments.isEmpty) {
          return const Center(child: Text("No scheduled appointments."));
        }

        final petIds =
            scheduledAppointments.map((doc) => doc["Pet_Id"] as String).toSet();

        return StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection("pet")
              .where(FieldPath.documentId, whereIn: petIds.toList())
              .snapshots(),
          builder: (context, petSnapshot) {
            if (petSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!petSnapshot.hasData || petSnapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No pets assigned to you."));
            }

            final pets = petSnapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final petName = (data["pet_name"] ?? "").toString().toLowerCase();
              return petName.contains(_searchQuery.toLowerCase());
            }).toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: pets.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final petId = doc.id;

                return _buildMedicalRecordCard(
                  petId,
                  data["pet_name"] ?? "Unnamed Pet",
                  data["pet_breed"] ?? "",
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildMedicalRecordCard(String petId, String petName, String breed) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF5425A5).withOpacity(0.1),
              child: const Icon(Icons.pets, color: Color(0xFF5425A5), size: 30),
            ),
            const SizedBox(width: 16),
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
            IconButton(
              icon: const Icon(Icons.visibility, color: Color(0xFF5425A5)),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            MedicalRecordDetailsScreen(petId: petId)));
              },
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () => _showAddRecordForm(petId),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Medical Records"),
          backgroundColor: const Color(0xFF5425A5)),
      body: _buildMedicalRecords(),
    );
  }
}

class MedicalRecordDetailsScreen extends StatelessWidget {
  final String petId;
  const MedicalRecordDetailsScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
          title: const Text("Medical History"),
          backgroundColor: const Color(0xFF5425A5)),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection("medical_records")
            .where("pet_id", isEqualTo: petId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No medical records found."));
          }

          final records = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final data = records[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data["diagnosis"] ?? "No diagnosis",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text("📝 Treatment: ${data["treatment"] ?? "-"}"),
                      const SizedBox(height: 4),
                      Text("💊 Prescription: ${data["prescription"] ?? "-"}"),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          "Added on: ${(data["created_at"] as Timestamp).toDate().toString().split(' ')[0]}",
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
