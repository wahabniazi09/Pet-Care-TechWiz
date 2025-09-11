import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_care/services/firestoreServices/firestoreServices.dart';

class ReviewFormPage extends StatelessWidget {
  const ReviewFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Review Form")),
      body: const Center(
        child: Text("Here will be the Review Form 📝"),
      ),
    );
  }
}

class AdoptionRequestPage extends StatelessWidget {
  const AdoptionRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Adoption Request")),
      body: const Center(
        child: Text("Here will be the Adoption Request Form 🐾"),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestoreservices.getAnimal(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No animals found"));
          }

          var animals = snapshot.data!.docs;

          return ListView.builder(
            itemCount: animals.length,
            itemBuilder: (context, index) {
              var animal = animals[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: MemoryImage(
                          base64Decode(animal['animal_image']),
                        ),
                      ),
                      title: Text(animal["animal_name"]),
                      subtitle: Text("Status: ${animal["adoption_status"]}"),
                      trailing: animal["adoption_status"] == "Adopted"
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.pets, color: Colors.blue),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.rate_review),
                          label: const Text("Review"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ReviewFormPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.assignment),
                          label: const Text("Adopt Request"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdoptionRequestPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
