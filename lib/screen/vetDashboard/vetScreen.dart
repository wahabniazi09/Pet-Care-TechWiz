import 'package:flutter/material.dart';
import 'package:pet_care/services/auth/authentication.dart';

class VetScreen extends StatefulWidget {
  const VetScreen({super.key});

  @override
  State<VetScreen> createState() => _VetScreenState();
}

class _VetScreenState extends State<VetScreen> {
  final Authentication authentication = Authentication();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vet Screen"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authentication.logOut(context),
          ),
        ],
      ),
      body: const Center(
        child: Text("Welcome to Vet Dashboard"),
      ),
    );
  }
}
