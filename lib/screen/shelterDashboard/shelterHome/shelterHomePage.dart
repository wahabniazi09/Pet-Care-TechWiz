import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_care/screen/shelterDashboard/shelterHome/adoptrequestPage.dart';
import 'package:intl/intl.dart';

class Shelterhomepage extends StatelessWidget {
  const Shelterhomepage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('adoption_requests')
              .where('shelterId', isEqualTo: currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5425A5)),
                ),
              );
            }

            if (snapshot.hasError) {
              return _errorState();
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _emptyState(screenWidth);
            }

            final requests = snapshot.data!.docs;

            return ListView.builder(
              padding: EdgeInsets.all(screenWidth * 0.04),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final doc = requests[index];
                final request = doc.data() as Map<String, dynamic>;

                Color statusColor;
                IconData statusIcon;
                switch (request['status']) {
                  case 'Approved':
                    statusColor = Colors.green;
                    statusIcon = Icons.check_circle;
                    break;
                  case 'Rejected':
                    statusColor = Colors.red;
                    statusIcon = Icons.cancel;
                    break;
                  case 'Pending':
                  default:
                    statusColor = Colors.orange;
                    statusIcon = Icons.access_time;
                }

                return Container(
                  margin: EdgeInsets.only(bottom: screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdoptionRequestDetailsPage(
                              docId: doc.id,
                              request: request,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: screenWidth * 0.13,
                              height: screenWidth * 0.13,
                              decoration: BoxDecoration(
                                color: const Color(0xFF5425A5).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.pets,
                                color: Color(0xFF5425A5),
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.04),

                            /// ✅ Expanded so text never overflows
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    request['petName'] ?? "Unknown Pet",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.045,
                                      color: const Color(0xFF333333),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: screenWidth * 0.015),
                                  Row(
                                    children: [
                                      Icon(Icons.person,
                                          size: screenWidth * 0.035,
                                          color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          request['applicantName'] ??
                                              'Unknown User',
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.035,
                                            color: Colors.grey[600],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenWidth * 0.015),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          size: screenWidth * 0.035,
                                          color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDate(request['timestamp']),
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.032,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            /// ✅ Status Tag
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.025,
                                vertical: screenWidth * 0.015,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(statusIcon,
                                      size: screenWidth * 0.035,
                                      color: statusColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    request['status'] ?? "Pending",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: statusColor,
                                      fontSize: screenWidth * 0.032,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// ✅ Empty state UI
  Widget _emptyState(double screenWidth) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/no_requests.png',
              width: screenWidth * 0.35,
              height: screenWidth * 0.35,
              color: Colors.grey[300],
            ),
            SizedBox(height: screenWidth * 0.06),
            Text(
              "No adoption requests yet",
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: screenWidth * 0.03),
            Text(
              "When users apply to adopt your pets, their requests will appear here",
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey[500],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Error state UI
  Widget _errorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            "Something went wrong",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Please try again later",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Date formatting
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "Unknown date";

    try {
      if (timestamp is Timestamp) {
        DateTime date = timestamp.toDate();
        return DateFormat('MMM dd, yyyy').format(date);
      } else if (timestamp is String) {
        return timestamp;
      }
      return "Unknown date";
    } catch (e) {
      return "Unknown date";
    }
  }
}
