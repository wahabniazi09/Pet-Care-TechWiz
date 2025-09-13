import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_care/consts/colors.dart';
import 'package:pet_care/consts/firebase_consts.dart';
import 'package:pet_care/screen/shelterDashboard/shelterScreen.dart';
import 'package:pet_care/screen/widgets/comonTextField.dart';
import 'package:pet_care/services/shelterOwnerServices/shelterOwnerServices.dart';
import 'package:pet_care/services/validationServices/validation_services.dart';

class AddAnimal extends StatefulWidget {
  const AddAnimal({super.key});

  @override
  State<AddAnimal> createState() => _AddAnimalState();
}

class _AddAnimalState extends State<AddAnimal> {
  final _formKey = GlobalKey<FormState>();
  final shelterownerservices = ShelterOwnerServices();
  Uint8List? animalImageWeb;
  String? animalImagePath;

  bool isLoading = false;

  final List<String> animalTypes = ["Dog", "Cat", "Bird", "Rabbit", "Other"];
  final List<String> breeds = [
    "Labrador",
    "German Shepherd",
    "Persian Cat",
    "Siamese",
    "Parrot",
    "Mixed",
    "Other"
  ];
  final List<String> sizes = ["Small", "Medium", "Large"];
  final List<String> colors = ["Black", "White", "Brown", "Golden", "Mixed"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[900],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "Add Animal",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : OutlinedButton(
                  onPressed: () {
                    saveAnimal(context);
                  },
                  child: const Text(
                    'Add Animal',
                    style: TextStyle(color: whiteColor),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Image
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/pet123.png',
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 140,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: Text(
                  "Animal Details",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: whiteColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Name
              buildTextField("Animal Name", shelterownerservices.nameController,
                  validatePetName),
              const SizedBox(height: 10),

              // Animal Type
              DropdownButtonFormField<String>(
                value: shelterownerservices.selectedAnimalType,
                dropdownColor: Colors.deepPurple[700],
                decoration: _dropdownDecoration("Animal Type"),
                items: animalTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child:
                        Text(type, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (val) => setState(
                    () => shelterownerservices.selectedAnimalType = val!),
              ),
              const SizedBox(height: 10),

              // Age + Breed
              Row(
                children: [
                  Expanded(
                    child: buildTextField("Age (yrs)",
                        shelterownerservices.ageController, validatePetAge),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: shelterownerservices.selectedBreed,
                      dropdownColor: Colors.deepPurple[700],
                      decoration: _dropdownDecoration("Breed"),
                      items: breeds.map((breed) {
                        return DropdownMenuItem(
                          value: breed,
                          child: Text(breed,
                              style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (val) => setState(
                          () => shelterownerservices.selectedBreed = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Gender
              DropdownButtonFormField<String>(
                value: shelterownerservices.selectedGender,
                dropdownColor: Colors.deepPurple[700],
                decoration: _dropdownDecoration("Gender"),
                items: ["Male", "Female"].map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender,
                        style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (val) =>
                    setState(() => shelterownerservices.selectedGender = val!),
              ),
              const SizedBox(height: 10),

              // Size
              DropdownButtonFormField<String>(
                value: shelterownerservices.selectedSize,
                dropdownColor: Colors.deepPurple[700],
                decoration: _dropdownDecoration("Size"),
                items: sizes.map((size) {
                  return DropdownMenuItem(
                    value: size,
                    child:
                        Text(size, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (val) =>
                    setState(() => shelterownerservices.selectedSize = val!),
              ),
              const SizedBox(height: 10),

              // Color
              DropdownButtonFormField<String>(
                value: shelterownerservices.selectedColor,
                dropdownColor: Colors.deepPurple[700],
                decoration: _dropdownDecoration("Color"),
                items: colors.map((color) {
                  return DropdownMenuItem(
                    value: color,
                    child: Text(color,
                        style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (val) =>
                    setState(() => shelterownerservices.selectedColor = val!),
              ),
              const SizedBox(height: 10),

              // Location
              buildTextField("Location",
                  shelterownerservices.locationController, validateAddress),
              const SizedBox(height: 10),

              // Health Status
              buildTextField("Health Status",
                  shelterownerservices.healthController, validateAddress),
              const SizedBox(height: 10),

              // Description
              buildTextField(
                  "Description",
                  shelterownerservices.descriptionController,
                  validateProductDescription,
                  maxLines: 5),
              const SizedBox(height: 10),

              // Adoption Status
              DropdownButtonFormField<String>(
                value: shelterownerservices.selectedAdoptionStatus,
                dropdownColor: Colors.deepPurple[700],
                decoration: _dropdownDecoration("Adoption Status"),
                items: ["Available", "Adopted", "Pending"].map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status,
                        style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (val) => setState(
                    () => shelterownerservices.selectedAdoptionStatus = val!),
              ),
              const SizedBox(height: 20),

              // Image Picker
              const Text(
                'Choose Animal Image',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: () => changeImage(),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.deepPurple[200],
                    ),
                    child: animalImageWeb != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(animalImageWeb!,
                                fit: BoxFit.cover),
                          )
                        : animalImagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(File(animalImagePath!),
                                    fit: BoxFit.cover),
                              )
                            : const Icon(Icons.camera_alt,
                                color: Colors.white, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'First image will be your display image',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: whiteColor),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: whiteColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.amber),
      ),
    );
  }

  Future<void> changeImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        animalImageWeb = await pickedFile.readAsBytes();
      } else {
        animalImagePath = pickedFile.path;
      }
      setState(() {});
    }
  }

  Future<void> saveAnimal(BuildContext context) async {
    try {
      if ((kIsWeb && animalImageWeb == null) ||
          (!kIsWeb && animalImagePath == null)) {
        showError("Please select an image");
        return;
      }

      setState(() => isLoading = true);

      String base64image = kIsWeb
          ? base64Encode(animalImageWeb!)
          : base64Encode(File(animalImagePath!).readAsBytesSync());

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
        "animal_type": shelterownerservices.selectedAnimalType,
        "animal_age": shelterownerservices.ageController.text,
        "animal_breed": shelterownerservices.selectedBreed,
        "animal_gender": shelterownerservices.selectedGender,
        "animal_size": shelterownerservices.selectedSize,
        "animal_color": shelterownerservices.selectedColor,
        "animal_location": shelterownerservices.locationController.text,
        "animal_health": shelterownerservices.healthController.text,
        "animal_description": shelterownerservices.descriptionController.text,
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
