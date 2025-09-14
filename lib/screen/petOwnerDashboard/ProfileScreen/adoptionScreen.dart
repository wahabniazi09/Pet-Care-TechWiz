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
        appBar: AppBar(
          title: const Text("My Adoption Requests"),
          centerTitle: true,
        ),
        body: const Center(
          child: Text("Please login to see your requests",
              style: TextStyle(fontSize: 16)),
        ),
      );
    }

    final requestsRef = FirebaseFirestore.instance
        .collection('adoption_requests')
        .where('userId', isEqualTo: user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Adoption Requests"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: requestsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;
          if (requests.isEmpty) {
            return const Center(
              child: Text("No adoption requests found",
                  style: TextStyle(fontSize: 16)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final data = request.data() as Map<String, dynamic>;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade100, Colors.blue.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: data['petImage'] != null &&
                                data['petImage'].toString().isNotEmpty
                            ? Image.memory(
                                base64Decode(data['petImage']),
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.pets,
                                    size: 36, color: Colors.grey),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['petName'] ?? 'Unknown Pet',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text("Status: ${data['status'] ?? 'Pending'}",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black54)),
                            Text("Home Type: ${data['homeType'] ?? '-'}",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black54)),
                            Text(
                                "Has Other Pets: ${data['hasOtherPets'] == true ? 'Yes' : 'No'}",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black54)),
                            Text(
                                "Has Children: ${data['hasChildren'] == true ? 'Yes' : 'No'}",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black54)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('adoption_requests')
                              .doc(request.id)
                              .delete();
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
