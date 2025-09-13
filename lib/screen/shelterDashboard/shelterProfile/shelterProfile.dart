import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_care/screen/shelterDashboard/shelterProfile/editProfile.dart';
import 'package:pet_care/services/authServices/authentication.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("No user logged in"));
    }

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection("users").doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
              child: Text("User details not found in Firestore"));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;

        final String name = userData['name'] ?? user.displayName ?? "No Name";
        final String email = userData['email'] ?? user.email ?? "No Email";
        final String phone = userData['phone'] ?? "No Phone";
        final String profileImage = userData['photoUrl'] ??
            user.photoURL ??
            "https://ui-avatars.com/api/?name=$name";

        return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepPurple.shade900,
                        side: BorderSide(color: Colors.deepPurple.shade900),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EditProfilePage()),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit"),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: () async {
                        await Authentication().logOut(context);
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                    ),
                  ],
                ),
              ),

              // 🔹 Banner & Profile Image
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.shade900,
                          Colors.purple.shade400
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    left: MediaQuery.of(context).size.width / 2 - 50,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 46,
                        backgroundImage: NetworkImage(profileImage),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),

              // 🔹 User Name & Email
              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 Details Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildProfileItem(Icons.phone, "Phone", phone),
                        const Divider(),
                        _buildProfileItem(Icons.email, "Email", email),
                        const Divider(),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            "$title: $value",
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
