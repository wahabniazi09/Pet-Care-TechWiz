import 'package:flutter/material.dart';
import 'package:pet_care/services/auth/authentication.dart';

class ShelterScreen extends StatefulWidget {
  const ShelterScreen({super.key});

  @override
  State<ShelterScreen> createState() => _ShelterScreenState();
}

class _ShelterScreenState extends State<ShelterScreen> {
  final Authentication authentication = Authentication();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shelter Screen"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authentication.logOut(context),
          ),
        ],
      ),
      body: const Center(
        child: Text("Welcome to Shelter Dashboard"),
      ),
    );
  }
}
