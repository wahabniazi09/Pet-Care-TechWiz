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
