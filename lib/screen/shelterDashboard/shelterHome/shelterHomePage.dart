import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('adoption_requests')
            .where('shelterId', isEqualTo: currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No adoption requests yet.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            );
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.pets, color: Colors.deepPurple),
                  title: Text(request['petName'] ?? "Unknown Pet"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Applicant: ${request['applicantName']}"),
                      Text("Email: ${request['applicantEmail']}"),
                      Text("Phone: ${request['applicantPhone']}"),
                      Text("Address: ${request['applicantAddress']}"),
                    ],
                  ),
                  // trailing: Text(
                  //   request['submissionDate'] != null
                  //       ? (request['submissionDate'] as Timestamp)
                  //           .toDate()
                  //           .toString()
                  //           .substring(0, 16)
                  //       : "",
                  //   style: const TextStyle(fontSize: 12, color: Colors.grey),
                  // ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
