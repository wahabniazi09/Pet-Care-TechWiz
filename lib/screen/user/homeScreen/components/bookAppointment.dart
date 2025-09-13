import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> vet;

  const BookAppointmentScreen({super.key, required this.vet});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  String? selectedPetId;
  Map<String, dynamic>? selectedPet;
  List<Map<String, dynamic>> pets = [];

  @override
  void initState() {
    super.initState();
    _loadUserPets();
  }

  Future<void> _loadUserPets() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('pet')
          .where('owner_id', isEqualTo: user.uid)
          .get();

      setState(() {
        pets = snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
      });
    }
  }

  Future<void> _saveAppointment() async {
    if (selectedPetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a pet')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Save appointment
    final appointmentDoc =
        FirebaseFirestore.instance.collection('appointments').doc();

    await appointmentDoc.set({
      "appointment_id": appointmentDoc.id,
      "vet_id": widget.vet['uid'] ?? widget.vet['id'],
      "vet_name": widget.vet['name'],
      "owner_id": user.uid,
      "pet_id": selectedPetId,
      "pet_name": selectedPet?['pet_name'] ?? 'Unknown',
      "pet_image": selectedPet?['pet_image'] ?? '',
      "status": "pending",
      "created_at": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Appointment booked successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Book Appointment with ${widget.vet['name']}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Your Pet:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedPetId,
              items: pets
                  .map((pet) => DropdownMenuItem<String>(
                        value: pet['id'],
                        child: Text(pet['pet_name'] ?? 'Unnamed Pet'),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedPetId = value;
                  selectedPet = pets.firstWhere((pet) => pet['id'] == value);
                });
              },
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _saveAppointment,
                child: const Text('Book Appointment'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.deepOrange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
