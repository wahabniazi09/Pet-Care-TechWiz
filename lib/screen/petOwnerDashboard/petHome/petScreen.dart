import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_care/consts/colors.dart';
import 'package:pet_care/consts/firebase_consts.dart';
import 'package:pet_care/screen/petOwnerDashboard/petHome/addPets.dart';
import 'package:pet_care/screen/petOwnerDashboard/petHome/petUpdates.dart';
import 'package:pet_care/services/authServices/authentication.dart';
import 'package:pet_care/services/firestoreServices/firestoreServices.dart';

class PetScreen extends StatefulWidget {
  const PetScreen({super.key});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> {
  final Authentication authentication = Authentication();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AddPet()),
          );
        },
        backgroundColor: Colors.deepPurple[900],
        child: const Icon(Icons.add, color: whiteColor),
      ),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[900],
        title: const Text(
          "My Pets",
          style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: whiteColor),
            onPressed: () => authentication.logOut(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestoreservices.getpetByowner(currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No pets added yet",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          var pets = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              var pet = pets[index];
              var petData = pet.data() as Map<String, dynamic>;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: petData['pet_image'] != null
                        ? Image.memory(
                            base64Decode(petData['pet_image']),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: Colors.deepPurple[100],
                            child: const Icon(Icons.pets,
                                size: 30, color: Colors.white),
                          ),
                  ),
                  title: Text(
                    petData['pet_name'] ?? "Unnamed",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkFontGrey),
                  ),
                  subtitle: Text(
                    "${petData['pet_bread']} • ${petData['pet_age']} yrs • ${petData['pet_gender']}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: PopupMenuButton<int>(
                    onSelected: (value) async {
                      switch (value) {
                        case 0: // Edit
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PetUpdates(
                                petId: pet.id,
                                petData: petData,
                              ),
                            ),
                          );
                          break;
                        case 1: // Delete
                          await Firestoreservices.deletepet(pet.id);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<int>(
                        value: 0,
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text("Edit"),
                          ],
                        ),
                      ),
                      const PopupMenuItem<int>(
                        value: 1,
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text("Delete"),
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
      ),
    );
  }
}
