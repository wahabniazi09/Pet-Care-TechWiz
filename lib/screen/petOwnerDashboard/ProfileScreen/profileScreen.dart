import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_care/screen/login_register_screen/loginScreen.dart';
import 'package:pet_care/screen/login_register_screen/registerScreen.dart';
import 'package:pet_care/screen/petOwnerDashboard/ProfileScreen/adoptionScreen.dart';
import 'package:pet_care/screen/petOwnerDashboard/ProfileScreen/appointmentScreen.dart';
import 'package:pet_care/screen/petOwnerDashboard/ProfileScreen/cartScreen.dart';
import 'package:pet_care/screen/petOwnerDashboard/ProfileScreen/editProfile.dart';
import 'package:pet_care/screen/petOwnerDashboard/ProfileScreen/myPets.dart';
import 'package:pet_care/screen/petOwnerDashboard/ProfileScreen/orderScreen.dart';
import 'package:pet_care/screen/widgets/ownButton.dart';
import 'package:pet_care/services/authServices/authentication.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Profile")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_outline,
                    size: 80, color: Colors.deepOrange),
                const SizedBox(height: 20),
                const Text(
                  "You are not logged in",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Ownbutton(
                  title: "Login",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  width: MediaQuery.of(context).size.width * 0.9,
                ),
                const SizedBox(height: 10),
                Ownbutton(
                  title: "Register",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  width: MediaQuery.of(context).size.width * 0.9,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: firestore.collection("users").doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;

        if (userData == null) {
          return const Scaffold(
            body: Center(child: Text("No profile data found")),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text("My Profile")),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: userData["image"] != null
                            ? MemoryImage(base64Decode(userData["image"]))
                            : const AssetImage("assets/default.png")
                                as ImageProvider,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userData["name"] ?? "User",
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(userData["email"] ?? "",
                                style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text(userData["phone"] ?? "",
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Buttons
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon:
                              const Icon(Icons.edit, color: Colors.deepOrange),
                          label: const Text("Edit Profile"),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfileScreen(
                                uid: user.uid,
                                userData: userData,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.logout,
                              color: Colors.deepOrange),
                          label: const Text("Logout"),
                          onPressed: () => Authentication().logOut(context),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Menu Items
                _buildMenuItem(context,
                    icon: Icons.shopping_cart,
                    text: "My Cart",
                    screen: const CartScreen()),
                _buildMenuItem(context,
                    icon: Icons.receipt_long,
                    text: "My Orders",
                    screen: const OrdersScreen()),
                _buildMenuItem(context,
                    icon: Icons.pets,
                    text: "Adopt Requests",
                    screen: const AdoptionScreen()),
                _buildMenuItem(context,
                    icon: Icons.calendar_today,
                    text: "Appointments",
                    screen: const AppointmentsScreen()),
                _buildMenuItem(
                  context,
                  icon: Icons.pets,
                  text: "My Pets",
                  screen: const MyPetsScreen(),
                ),

                const Divider(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required IconData icon, required String text, required Widget screen}) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepOrange),
      title: Text(text, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
    );
  }
}
