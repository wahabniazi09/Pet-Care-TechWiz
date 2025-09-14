import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_care/screen/petOwnerDashboard/ProfileScreen/editpets.dart';

class MyPetsScreen extends StatelessWidget {
  const MyPetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Pets")),
        body: const Center(child: Text("Please login to see your pets")),
      );
    }

    final petsRef =
        firestore.collection("pet").where("owner_id", isEqualTo: user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Pets"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditPetScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: petsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final pets = snapshot.data!.docs;
          if (pets.isEmpty)
            return const Center(child: Text("No pets added yet"));

          return ListView.builder(
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index].data() as Map<String, dynamic>;
              final petId = pets[index].id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: pet["pet_image"] != null
                        ? MemoryImage(base64Decode(pet["pet_image"]))
                        : null,
                    child: pet["pet_image"] == null
                        ? const Icon(Icons.pets)
                        : null,
                  ),
                  title: Text(pet["pet_name"] ?? "Unnamed Pet"),
                  subtitle: Text(
                      "${pet["pet_species"] ?? ""} | ${pet["pet_bread"] ?? ""} | Age: ${pet["pet_age"] ?? ""} | Gender: ${pet["pet_gender"] ?? ""}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditPetScreen(
                                petData: pet,
                                petId: petId,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await firestore.collection("pet").doc(petId).delete();
                        },
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
