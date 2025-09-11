import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_care/consts/colors.dart';
import 'package:pet_care/consts/firebase_consts.dart';
import 'package:pet_care/screen/shelterDashboard/addoptAnimal/addAnimal.dart';
import 'package:pet_care/screen/shelterDashboard/shelterStore/addProduct.dart';
import 'package:pet_care/screen/shelterDashboard/shelterStore/shelterProductdetails.dart';
import 'package:pet_care/services/authServices/authentication.dart';
import 'package:pet_care/services/firestoreServices/firestoreServices.dart';

class ShelterScreen extends StatefulWidget {
  const ShelterScreen({super.key});

  @override
  State<ShelterScreen> createState() => _ShelterScreenState();
}

class _ShelterScreenState extends State<ShelterScreen> {
  final Authentication authentication = Authentication();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAnimal()),
          );
        },
        backgroundColor: Colors.deepPurple[900],
        child: const Icon(Icons.add, color: whiteColor),
      ),
      appBar: AppBar(
        title: const Text("Shelter Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authentication.logOut(context),
          ),
          IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShelterProductDetails()));
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestoreservices.getAnimalbyShelterOwner(currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No animals available for adoption yet.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }
          var animals = snapshot.data!.docs;
          return ListView.builder(
            itemCount: animals.length,
            itemBuilder: (context, index) {
              var animal = animals[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: animal['animal_image'] != null
                      ? CircleAvatar(
                          backgroundImage: MemoryImage(
                            const Base64Decoder()
                                .convert(animal['animal_image']),
                          ),
                        )
                      : const CircleAvatar(
                          child: Icon(Icons.pets),
                        ),
                  title: Text(
                    animal['animal_name'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                      "Age: ${animal['animal_age']}, Gender: ${animal['animal_gender']}"),
                  trailing: Text(
                    animal['adoption_status'] ?? 'Available',
                    style: TextStyle(
                      color: (animal['adoption_status'] == 'Adopted')
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
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
