import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_care/consts/theme_constant.dart';
import 'package:pet_care/screen/widgets/snackBar.dart';

class AdoptionScreen extends StatelessWidget {
  const AdoptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("My Adoption Requests"),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 20.0 : 30.0),
              child: Text(
                "Please login to view your adoption requests",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  color: Colors.grey[600],
                ),
              )),
        ),
      );
    }

    final requestsRef = FirebaseFirestore.instance
        .collection('adoption_requests')
        .where('userId', isEqualTo: user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Adoption Requests"),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: requestsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            );
          }

          if (snapshot.hasError) {
            AppNotifier.showSnack(
              context,
              message: "Failed to load adoption requests",
              isError: true,
            );
            return Center(
              child: Text(
                "Something went wrong",
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  color: Colors.grey[600],
                ),
              ),
            );
          }

          final requests = snapshot.data!.docs;
          if (requests.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 20.0 : 30.0),
                child: Text(
                  "You haven't made any adoption requests yet",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final data = request.data() as Map<String, dynamic>;

              return Container(
                margin: EdgeInsets.only(bottom: isSmallScreen ? 12.0 : 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: data['petImage'] != null &&
                                data['petImage'].toString().isNotEmpty
                            ? Image.memory(
                                base64Decode(data['petImage']),
                                width: isSmallScreen ? 60 : 70,
                                height: isSmallScreen ? 60 : 70,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: isSmallScreen ? 60 : 70,
                                height: isSmallScreen ? 60 : 70,
                                color: Colors.grey[100],
                                child: Icon(
                                  Icons.pets,
                                  size: isSmallScreen ? 28 : 36,
                                  color: Colors.grey[400],
                                ),
                              ),
                      ),
                      SizedBox(width: isSmallScreen ? 12 : 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['petName'] ?? 'Unknown Pet',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: isSmallScreen ? 4 : 6),
                            _buildStatusChip(data['status'] ?? 'Pending'),
                            SizedBox(height: isSmallScreen ? 6 : 8),
                            Text(
                              "Home Type: ${data['homeType'] ?? 'Not specified'}",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 2 : 4),
                            Text(
                              "Other Pets: ${data['hasOtherPets'] == true ? 'Yes' : 'No'}",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 2 : 4),
                            Text(
                              "Children: ${data['hasChildren'] == true ? 'Yes' : 'No'}",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: isSmallScreen ? 20 : 24,
                          color: Colors.red[400],
                        ),
                        onPressed: () {
                          _showDeleteDialog(context, request.id);
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

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'approved':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'rejected':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      case 'pending':
      default:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String requestId) {
    final TextEditingController reasonController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Request"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    "Are you sure you want to delete this adoption request?"),
                const SizedBox(height: 16),
                TextFormField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    labelText: "Reason for deletion (optional)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('adoption_requests')
                        .doc(requestId)
                        .delete();
                    Navigator.of(context).pop();
                    AppNotifier.showSnack(
                      context,
                      message: "Adoption request deleted successfully",
                    );
                  } catch (error) {
                    Navigator.of(context).pop();
                    AppNotifier.handleError(context, error);
                  }
                }
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
