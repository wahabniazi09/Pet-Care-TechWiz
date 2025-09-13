import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdoptionRequestDetailsPage extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> request;

  const AdoptionRequestDetailsPage({
    super.key,
    required this.docId,
    required this.request,
  });

  Future<void> updateRequestStatus(String requestId, String status) async {
    await FirebaseFirestore.instance
        .collection('adoption_requests')
        .doc(requestId)
        .update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Request Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            detailRow("Pet Name", request['petName'] ?? "N/A"),
            detailRow("Pet ID", request['petId'] ?? "N/A"),
            detailRow("Applicant", request['applicantName'] ?? "N/A"),
            detailRow("Phone", request['applicantPhone'] ?? "N/A"),
            detailRow("Email", request['applicantEmail'] ?? "N/A"),
            detailRow("Address", request['applicantAddress'] ?? "N/A"),
            detailRow("Home Type", request['homeType'] ?? "N/A"),
            detailRow("Has Children",
                (request['hasChildren'] == true) ? "Yes" : "No"),
            detailRow("Has Other Pets",
                (request['hasOtherPets'] == true) ? "Yes" : "No"),
            detailRow("Experience", request['experience'] ?? "N/A"),
            detailRow("Status", request['status'] ?? "Pending"),
            // detailRow(
            //   "Submission Date",
            //   request['submissionDate'] != null
            //       ? (request['submissionDate'] as Timestamp).toDate().toString()
            //       : "N/A",
            // ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await updateRequestStatus(docId, "Approved");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Request Approved")),
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check),
                  label: const Text("Approve"),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await updateRequestStatus(docId, "Rejected");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Request Rejected")),
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                  label: const Text("Reject"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
