import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_care/consts/firebase_consts.dart';
import 'package:pet_care/screen/shelterDashboard/shelterProfile/shelterProfile.dart';
import 'package:pet_care/screen/vetDashboard/appointmentPage/vetAppointmentScreen.dart';
import 'package:pet_care/screen/vetDashboard/deshboardPage/dashboardScreen.dart';
import 'package:pet_care/screen/vetDashboard/medicalRecord/medicalRecord.dart';
import 'package:pet_care/services/authServices/authentication.dart';

class VetScreen extends StatefulWidget {
  const VetScreen({super.key});

  @override
  State<VetScreen> createState() => _VetScreenState();
}

class _VetScreenState extends State<VetScreen> {
  final Authentication authentication = Authentication();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF5425A5),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
      ),
      body: _getCurrentPage(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return "Veterinarian Dashboard";
      case 1:
        return "Medical Records";
      case 2:
        return "Appointments";
      case 3:
        return "My Profile";
      default:
        return "PAWFECTCARE";
    }
  }

  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return VetDashboard();
      case 1:
        return MedicalRecordsScreen();
      case 2:
        return VetAppointmentsScreen();
      case 3:
        return ProfilePage();
      default:
        return VetDashboard();
    }
  }

  // Widget _buildMedicalRecords() {
  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.all(16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // Search bar
  //         TextField(
  //           decoration: InputDecoration(
  //             hintText: "Search pets or owners...",
  //             prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
  //             filled: true,
  //             fillColor: Colors.white,
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(12),
  //               borderSide: BorderSide.none,
  //             ),
  //             contentPadding:
  //                 const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
  //           ),
  //         ),
  //         const SizedBox(height: 20),

  //         // Recent records
  //         const Text(
  //           "Recent Medical Records",
  //           style: TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.bold,
  //             color: Color(0xFF333333),
  //           ),
  //         ),
  //         const SizedBox(height: 12),

  //         _buildMedicalRecordCard(
  //             "Max", "Golden Retriever", "Last visit: 2 days ago"),
  //         _buildMedicalRecordCard(
  //             "Bella", "Siamese Cat", "Last visit: 1 week ago"),
  //         _buildMedicalRecordCard(
  //             "Rocky", "German Shepherd", "Last visit: 3 days ago"),
  //         _buildMedicalRecordCard(
  //             "Luna", "Labrador", "Last visit: 2 weeks ago"),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildMedicalRecordCard(
  //     String petName, String breed, String lastVisit) {
  //   return Card(
  //     margin: const EdgeInsets.only(bottom: 12),
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     elevation: 2,
  //     child: ListTile(
  //       contentPadding: const EdgeInsets.all(16),
  //       leading: Container(
  //         width: 50,
  //         height: 50,
  //         decoration: BoxDecoration(
  //           color: const Color(0xFF5425A5).withOpacity(0.1),
  //           shape: BoxShape.circle,
  //         ),
  //         child: Icon(Icons.pets, color: Color(0xFF5425A5)),
  //       ),
  //       title: Text(
  //         petName,
  //         style: const TextStyle(fontWeight: FontWeight.bold),
  //       ),
  //       subtitle: Text("$breed • $lastVisit"),
  //       trailing: IconButton(
  //         icon: Icon(Icons.visibility, color: Color(0xFF5425A5)),
  //         onPressed: () {
  //           // Navigate to medical record details
  //         },
  //       ),
  //     ),
  //   );
  // }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF5425A5),
          unselectedItemColor: Colors.grey[600],
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          elevation: 10,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == 0
                      ? const Color(0xFF5425A5).withOpacity(0.15)
                      : Colors.transparent,
                ),
                child: Icon(
                  Icons.dashboard,
                  size: 24,
                  color: _currentIndex == 0
                      ? const Color(0xFF5425A5)
                      : Colors.grey[600],
                ),
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == 1
                      ? const Color(0xFF5425A5).withOpacity(0.15)
                      : Colors.transparent,
                ),
                child: Icon(
                  Icons.medical_services,
                  size: 24,
                  color: _currentIndex == 1
                      ? const Color(0xFF5425A5)
                      : Colors.grey[600],
                ),
              ),
              label: 'Records',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == 2
                      ? const Color(0xFF5425A5).withOpacity(0.15)
                      : Colors.transparent,
                ),
                child: Icon(
                  Icons.calendar_today,
                  size: 24,
                  color: _currentIndex == 2
                      ? const Color(0xFF5425A5)
                      : Colors.grey[600],
                ),
              ),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == 3
                      ? const Color(0xFF5425A5).withOpacity(0.15)
                      : Colors.transparent,
                ),
                child: Icon(
                  Icons.person,
                  size: 24,
                  color: _currentIndex == 3
                      ? const Color(0xFF5425A5)
                      : Colors.grey[600],
                ),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
