import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_care/screen/login_register_screen/loginScreen.dart';
import 'package:pet_care/screen/login_register_screen/registerScreen.dart';
import 'package:pet_care/screen/widgets/ownButton.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: user == null
          ? _buildGuestUI(context)
          : _buildUserRequests(context, user.uid),
    );
  }

  Widget _buildGuestUI(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          height: 40,
          child: Ownbutton(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => LoginScreen())),
            title: "Login",
            width: MediaQuery.of(context).size.width - 20,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 40,
          child: Ownbutton(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => RegisterScreen())),
            title: "Register",
            width: MediaQuery.of(context).size.width - 20,
          ),
        ),
      ]),
    );
  }

  Widget _buildUserRequests(BuildContext context, String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('adoption_requests')
          .where('userId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final requests = snapshot.data!.docs;
        if (requests.isEmpty)
          return const Center(child: Text("No requests yet"));

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(req['petName'] ?? "Unknown Pet"),
                subtitle: Text("Status: Pending"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // TODO: Navigate to edit screen with req.id
                        }),
                    IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('adoption_requests')
                              .doc(req.id)
                              .delete();
                        }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
