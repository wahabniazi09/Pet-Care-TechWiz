import 'package:flutter/material.dart';
import 'package:pet_care/consts/colors.dart';
import 'package:pet_care/screen/petOwnerDashboard/addPets.dart';
import 'package:pet_care/services/auth/authentication.dart';

class PetScreen extends StatefulWidget {
  const PetScreen({super.key});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> {
  final Authentication authentication = Authentication();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => AddPet()));
        },
        backgroundColor: Colors.deepPurple[900],
        child: const Icon(
          Icons.add,
          color: whiteColor,
        ),
      ),
      appBar: AppBar(
        title: const Text("pet Screen"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authentication.logOut(context),
          ),
        ],
      ),
      body: const Center(
        child: Text("Welcome to pet Dashboard"),
      ),
    );
  }
}
