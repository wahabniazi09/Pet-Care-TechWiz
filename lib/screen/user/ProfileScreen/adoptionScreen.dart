import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdoptionScreen extends StatelessWidget {
  const AdoptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Adoption Requests")),
        body: const Center(child: Text("Please login to see your requests")),
      );
    }

    final requestsRef = FirebaseFirestore.instance
        .collection('adoption_requests')
        .where('userId', isEqualTo: user.uid);

    return Scaffold(
      appBar: AppBar(title: const Text("My Adoption Requests")),
      body: StreamBuilder<QuerySnapshot>(
        stream: requestsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final requests = snapshot.data!.docs;
          if (requests.isEmpty)
            return const Center(child: Text("No adoption requests found"));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final data = request.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: data['petImage'] != null &&
                          data['petImage'].toString().isNotEmpty
                      ? Image.memory(
                          base64Decode(data['petImage']),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.pets),
                  title: Text(data['petName'] ?? 'Unknown Pet'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Status: ${data['status'] ?? 'Pending'}"),
                      Text("Home Type: ${data['homeType'] ?? '-'}"),
                      Text(
                          "Has Other Pets: ${data['hasOtherPets'] ? 'Yes' : 'No'}"),
                      Text(
                          "Has Children: ${data['hasChildren'] ? 'Yes' : 'No'}"),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('adoption_requests')
                          .doc(request.id)
                          .delete();
                    },
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
