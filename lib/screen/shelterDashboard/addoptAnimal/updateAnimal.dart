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

class UpdateAnimal extends StatefulWidget {
  final Map<String, dynamic> animalData;
  final String animalId;

  const UpdateAnimal({
    super.key,
    required this.animalData,
    required this.animalId,
  });

  @override
  State<UpdateAnimal> createState() => _UpdateAnimalState();
}

class _UpdateAnimalState extends State<UpdateAnimal> {
  final _formKey = GlobalKey<FormState>();
  final shelterownerservices = ShelterOwnerServices();
  Uint8List? profileImageWeb;
  String? profileImagePath;

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
  final List<String> colors = ["Brown", "Black", "White", "Golden", "Mixed"];
  final List<String> locations = ["Karachi", "Lahore", "Islamabad", "Other"];

  @override
  void initState() {
    super.initState();
    // Load existing values into controllers
    shelterownerservices.nameController.text = widget.animalData["animal_name"];
    shelterownerservices.ageController.text = widget.animalData["animal_age"];
    shelterownerservices.healthController.text =
        widget.animalData["animal_health"];
    shelterownerservices.descriptionController.text =
        widget.animalData["description"] ?? "";
    shelterownerservices.weightController.text =
        widget.animalData["weight"] ?? "";
    shelterownerservices.selectedAnimalType = widget.animalData["animal_type"];
    shelterownerservices.selectedBreed = widget.animalData["animal_breed"];
    shelterownerservices.selectedGender = widget.animalData["animal_gender"];
    shelterownerservices.selectedAdoptionStatus =
        widget.animalData["adoption_status"];
    shelterownerservices.selectedSize = widget.animalData["size"] ?? "Medium";
    shelterownerservices.selectedColor = widget.animalData["color"] ?? "Brown";
    shelterownerservices.selectedLocation =
        widget.animalData["location"] ?? "Karachi";
    shelterownerservices.selectedVaccination =
        widget.animalData["vaccination"] ?? "Yes";
    shelterownerservices.selectedNeutered =
        widget.animalData["neutered"] ?? "No";

    if (widget.animalData["animal_image"] != null) {
      try {
        Uint8List bytes = base64Decode(widget.animalData["animal_image"]);
        profileImageWeb = bytes;
      } catch (e) {
        print("Failed to load animal image: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[900],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title:
            const Text("Update Animal", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : OutlinedButton(
                  onPressed: () {
                    updateAnimal(context);
                  },
                  child: const Text(
                    'Update Animal',
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
            children: [
              buildTextField("Animal Name", shelterownerservices.nameController,
                  validatePetName),
              const SizedBox(height: 10),

              // Animal Type
              DropdownButtonFormField<String>(
                value: shelterownerservices.selectedAnimalType,
                decoration: _dropdownDecoration("Animal Type"),
                items: animalTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
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
                      decoration: _dropdownDecoration("Breed"),
                      items: breeds.map((breed) {
                        return DropdownMenuItem(
                          value: breed,
                          child: Text(breed),
                        );
                      }).toList(),
                      onChanged: (val) => setState(
                          () => shelterownerservices.selectedBreed = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              buildTextField("Health Status",
                  shelterownerservices.healthController, validateAddress),
              const SizedBox(height: 10),

              buildTextField("Weight (kg)",
                  shelterownerservices.weightController, validateAddress),
              const SizedBox(height: 10),

              // Gender
              DropdownButtonFormField<String>(
                value: shelterownerservices.selectedGender,
                decoration: _dropdownDecoration("Gender"),
                items: ["Male", "Female"].map((gender) {
                  return DropdownMenuItem(value: gender, child: Text(gender));
                }).toList(),
                onChanged: (val) =>
                    setState(() => shelterownerservices.selectedGender = val!),
              ),
              const SizedBox(height: 10),

              // Size + Color
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: shelterownerservices.selectedSize,
                      decoration: _dropdownDecoration("Size"),
                      items: sizes.map((size) {
                        return DropdownMenuItem(value: size, child: Text(size));
                      }).toList(),
                      onChanged: (val) => setState(
                          () => shelterownerservices.selectedSize = val!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: shelterownerservices.selectedColor,
                      decoration: _dropdownDecoration("Color"),
                      items: colors.map((color) {
                        return DropdownMenuItem(
                            value: color, child: Text(color));
                      }).toList(),
                      onChanged: (val) => setState(
                          () => shelterownerservices.selectedColor = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Location
              DropdownButtonFormField<String>(
                value: shelterownerservices.selectedLocation,
                decoration: _dropdownDecoration("Location"),
                items: locations.map((loc) {
                  return DropdownMenuItem(value: loc, child: Text(loc));
                }).toList(),
                onChanged: (val) => setState(
                    () => shelterownerservices.selectedLocation = val!),
              ),
              const SizedBox(height: 10),

              // Vaccination
              DropdownButtonFormField<String>(
                value: shelterownerservices.selectedVaccination,
                decoration: _dropdownDecoration("Vaccinated"),
                items: ["Yes", "No"].map((val) {
                  return DropdownMenuItem(value: val, child: Text(val));
                }).toList(),
                onChanged: (val) => setState(
                    () => shelterownerservices.selectedVaccination = val!),
              ),
              const SizedBox(height: 10),

              // Neutered
              DropdownButtonFormField<String>(
                value: shelterownerservices.selectedNeutered,
                decoration: _dropdownDecoration("Neutered"),
                items: ["Yes", "No"].map((val) {
                  return DropdownMenuItem(value: val, child: Text(val));
                }).toList(),
                onChanged: (val) => setState(
                    () => shelterownerservices.selectedNeutered = val!),
              ),
              const SizedBox(height: 10),

              // Description
              buildTextField("Description",
                  shelterownerservices.descriptionController, validateAddress),
              const SizedBox(height: 20),

              // Adoption Status
              DropdownButtonFormField<String>(
                value: shelterownerservices.selectedAdoptionStatus,
                decoration: _dropdownDecoration("Adoption Status"),
                items: ["Available", "Adopted", "Pending"].map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (val) => setState(
                    () => shelterownerservices.selectedAdoptionStatus = val!),
              ),
              const SizedBox(height: 20),

              // Image picker
              GestureDetector(
                onTap: () => changeImage(),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: profileImageWeb != null
                      ? Image.memory(profileImageWeb!, fit: BoxFit.cover)
                      : profileImagePath != null
                          ? Image.file(File(profileImagePath!),
                              fit: BoxFit.cover)
                          : const Icon(Icons.camera_alt,
                              color: Colors.white, size: 40),
                ),
              ),
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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

  Future<void> updateAnimal(BuildContext context) async {
    try {
      setState(() => isLoading = true);

      String? base64image;
      if (profileImageWeb != null) {
        base64image = base64Encode(profileImageWeb!);
      } else if (profileImagePath != null) {
        base64image = base64Encode(File(profileImagePath!).readAsBytesSync());
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        showError("User not logged in");
        return;
      }

      var animalDoc =
          firestore.collection(animalCollection).doc(widget.animalId);

      Map<String, dynamic> updatedData = {
        "animal_id": animalDoc.id,
        "shelter_id": user.uid,
        "animal_name": shelterownerservices.nameController.text,
        "animal_type": shelterownerservices.selectedAnimalType,
        "animal_age": shelterownerservices.ageController.text,
        "animal_breed": shelterownerservices.selectedBreed,
        "animal_gender": shelterownerservices.selectedGender,
        "animal_health": shelterownerservices.healthController.text,
        "adoption_status": shelterownerservices.selectedAdoptionStatus,
        "size": shelterownerservices.selectedSize,
        "color": shelterownerservices.selectedColor,
        "location": shelterownerservices.selectedLocation,
        "description": shelterownerservices.descriptionController.text,
        "weight": shelterownerservices.weightController.text,
        "vaccination": shelterownerservices.selectedVaccination,
        "neutered": shelterownerservices.selectedNeutered,
        "updated_at": FieldValue.serverTimestamp(),
      };

      if (base64image != null) {
        updatedData["animal_image"] = base64image;
      }

      await animalDoc.update(updatedData);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ShelterScreen()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Animal updated successfully")),
      );
    } catch (e) {
      showError("Failed to update: $e");
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
