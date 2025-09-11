import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_care/consts/colors.dart';
import 'package:pet_care/consts/firebase_consts.dart';
import 'package:pet_care/consts/styles.dart';
import 'package:pet_care/screen/shelterDashboard/shelterScreen.dart';
import 'package:pet_care/screen/shelterDashboard/shelterWidgets/shelterTextField.dart';
import 'package:pet_care/services/shelterOwnerServices/shelterOwnerServices.dart';
import 'package:pet_care/services/validationServices/validation_services.dart';

class AddAnimal extends StatefulWidget {
  const AddAnimal({super.key});

  @override
  State<AddAnimal> createState() => _AddAnimalState();
}

class _AddAnimalState extends State<AddAnimal> {
  final _formKey = GlobalKey<FormState>();
  final shelterownerservices = Shelterownerservices();
  Uint8List? profileImageWeb;
  String? profileImagePath;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[900],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: whiteColor),
        title: const Text(
          'Add Animal',
          style: TextStyle(fontSize: 16.0, color: whiteColor),
        ),
        actions: [
          isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(color: whiteColor),
                )
              : OutlinedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      saveAnimal(context);
                    }
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(color: whiteColor),
                  ),
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTextField("Animal Name",
                    shelterownerservices.nameController, validatePetName),
                const SizedBox(height: 10),
                buildTextField("Animal Type",
                    shelterownerservices.typeController, validatePetSpecies),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: buildTextField("Age (yrs)",
                          shelterownerservices.ageController, validatePetAge),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: buildTextField(
                          "Breed",
                          shelterownerservices.breedController,
                          validatePetBreed),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                buildTextField("Health Status",
                    shelterownerservices.healthController, validateAddress),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: shelterownerservices.selectedGender,
                  dropdownColor: Colors.white,
                  decoration: const InputDecoration(
                    labelText: "Gender",
                    border: OutlineInputBorder(),
                  ),
                  items: ["Male", "Female"].map((gender) {
                    return DropdownMenuItem(value: gender, child: Text(gender));
                  }).toList(),
                  onChanged: (val) => setState(
                      () => shelterownerservices.selectedGender = val!),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: shelterownerservices.selectedAdoptionStatus,
                  dropdownColor: Colors.white,
                  decoration: const InputDecoration(
                    labelText: "Adoption Status",
                    border: OutlineInputBorder(),
                  ),
                  items: ["Available", "Adopted", "Pending"].map((status) {
                    return DropdownMenuItem(value: status, child: Text(status));
                  }).toList(),
                  onChanged: (val) => setState(
                      () => shelterownerservices.selectedAdoptionStatus = val!),
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: changeImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: whiteColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: profileImageWeb != null
                          ? Image.memory(profileImageWeb!, fit: BoxFit.cover)
                          : profileImagePath != null
                              ? Image.file(File(profileImagePath!),
                                  fit: BoxFit.cover)
                              : const Icon(Icons.camera_alt,
                                  color: whiteColor, size: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Upload Animal Photo',
                    style: TextStyle(color: whiteColor, fontFamily: bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> changeImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        profileImageWeb = await pickedFile.readAsBytes();
      } else {
        profileImagePath = pickedFile.path;
      }
      setState(() {});
    }
  }

  Future<void> saveAnimal(BuildContext context) async {
    try {
      if ((kIsWeb && profileImageWeb == null) ||
          (!kIsWeb && profileImagePath == null)) {
        showError("Please select an image");
        return;
      }

      setState(() => isLoading = true);

      String base64image = kIsWeb
          ? base64Encode(profileImageWeb!)
          : base64Encode(File(profileImagePath!).readAsBytesSync());

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        showError("User not logged in");
        return;
      }

      var animal = firestore.collection(animalCollection).doc();
      await animal.set({
        "animal_id": animal.id,
        "shelter_id": user.uid,
        "animal_name": shelterownerservices.nameController.text,
        "animal_type": shelterownerservices.typeController.text,
        "animal_age": shelterownerservices.ageController.text,
        "animal_breed": shelterownerservices.breedController.text,
        "animal_gender": shelterownerservices.selectedGender,
        "animal_health": shelterownerservices.healthController.text,
        "adoption_status": shelterownerservices.selectedAdoptionStatus,
        "animal_image": base64image,
        "created_at": FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ShelterScreen()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Animal added successfully")),
      );
    } catch (e) {
      showError("Failed to save: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.red, content: Text(message)),
    );
  }
}
