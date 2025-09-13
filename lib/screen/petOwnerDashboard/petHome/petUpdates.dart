import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_care/consts/colors.dart';
import 'package:pet_care/consts/firebase_consts.dart';
import 'package:pet_care/screen/petOwnerDashboard/petHome/petScreen.dart';

import 'package:pet_care/screen/widgets/comonTextField.dart';
import 'package:pet_care/services/petOwnerServices/petOwnerServices.dart';
import 'package:pet_care/services/validationServices/validation_services.dart';

class PetUpdates extends StatefulWidget {
  final String petId;
  final Map<String, dynamic> petData;
  const PetUpdates({
    super.key,
    required this.petId,
    required this.petData,
  });

  @override
  State<PetUpdates> createState() => _PetUpdatesState();
}

class _PetUpdatesState extends State<PetUpdates> {
  final petController = Petownerservices();
  bool isloading = false;
  Uint8List? profileImageWeb;
  String? profileImagePath;
  final _formKey = GlobalKey<FormState>();
  final List<String> breeds = ["Dog", "Cat", "Bird", "Rabbit", "Other"];
  String? selectedBreed;
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    setState(() {});

    petController.petNameController.text = widget.petData["pet_name"];
    petController.petAgeController.text = widget.petData["pet_age"];
    petController.petGenderController.text = widget.petData["pet_gender"];
    petController.petSpeciesController.text = widget.petData["pet_species"];
    selectedBreed = widget.petData["pet_bread"];
    selectedGender = widget.petData["pet_gender"];

    if (widget.petData["pet_image"] != null) {
      try {
        Uint8List bytes = base64Decode(widget.petData["pet_image"]);
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
        title: const Text(
          "Update Pet",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          isloading
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : OutlinedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      updatepet(context);
                    }
                  },
                  child: const Text(
                    'Update Pet',
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
                  "Update Pet Details",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: whiteColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              buildTextField(
                  "Pet Name", petController.petNameController, validatePetName),
              const SizedBox(height: 10),
              buildTextField("Species", petController.petSpeciesController,
                  validatePetSpecies),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: buildTextField("Age (yrs)",
                        petController.petAgeController, validatePetAge),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: DropdownButtonFormField<String>(
                    value:
                        breeds.contains(selectedBreed) ? selectedBreed : null,
                    dropdownColor: Colors.deepPurple[700],
                    decoration: _dropdownDecoration("Breed"),
                    items: breeds.map((breed) {
                      return DropdownMenuItem(
                        value: breed,
                        child: Text(breed,
                            style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedBreed = val;
                      });
                    },
                  )),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedGender,
                dropdownColor: Colors.deepPurple[700],
                decoration: _dropdownDecoration("Gender"),
                items: ["Male", "Female"].map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender,
                        style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedGender = val;
                  });
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Choose Pet Image',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: () => updateImage(),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.deepPurple[200],
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

  Future<void> updatepet(BuildContext context) async {
    try {
      if ((kIsWeb && profileImageWeb == null) ||
          (!kIsWeb && profileImagePath == null)) {
        showError("Please select an image");
        return;
      }

      setState(() {
        isloading = true;
      });

      String base64image;
      if (kIsWeb) {
        base64image = base64Encode(profileImageWeb!);
      } else {
        base64image = base64Encode(File(profileImagePath!).readAsBytesSync());
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        showError("User not logged in");
        return;
      }

      var petadd = firestore.collection(petCollection).doc(widget.petId);
      await petadd.update({
        "pet_id": petadd.id,
        "owner_id": user.uid,
        "pet_image": base64image,
        "pet_wishlist": FieldValue.arrayUnion([]),
        "pet_name": petController.petNameController.text,
        "pet_age": petController.petAgeController.text,
        "pet_gender": selectedGender,
        "pet_species": petController.petSpeciesController.text,
        "pet_bread": selectedBreed,
      });

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const PetScreen()));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pet Updated Successfully.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    } catch (e) {
      showError("Failed to update pet: $e");
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          message,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Future<void> updateImage() async {
    setState(() {
      isloading = true;
    });
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) return;

      if (kIsWeb) {
        profileImageWeb = await pickedFile.readAsBytes();
      } else {
        profileImagePath = pickedFile.path;
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
    setState(() {
      isloading = false;
    });
  }
}
