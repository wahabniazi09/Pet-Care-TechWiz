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
import 'package:pet_care/screen/petOwnerDashboard/petOwnerWidgets/petCustomForm.dart';
import 'package:pet_care/screen/petOwnerDashboard/petOwnerWidgets/petDropdown.dart';
import 'package:pet_care/screen/petOwnerDashboard/petHome/petScreen.dart';
import 'package:pet_care/services/petOwnerServices/petOwnerServices.dart';
import 'package:pet_care/services/validationServices/validation_services.dart';

class AddPet extends StatefulWidget {
  const AddPet({super.key});

  @override
  State<AddPet> createState() => _AddPetState();
}

class _AddPetState extends State<AddPet> {
  final petController = Petownerservices();
  final _formKey = GlobalKey<FormState>();
  Uint8List? profileImageWeb;
  String? profileImagePath;

  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[900],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: whiteColor),
        title: const Text(
          'Add Pets',
          style: TextStyle(fontSize: 16.0, color: whiteColor),
        ),
        actions: [
          isloading
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(color: whiteColor),
                )
              : OutlinedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      addpet(context);
                    }
                  },
                  child: const Text(
                    'Add Pets',
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
                PetCustomTextField(
                    label: 'Pet Name',
                    hint: 'Enter Pet Name',
                    ispass: false,
                    controller: petController.petNameController,
                    validator: validatePetName),
                const SizedBox(height: 10),
                PetCustomTextField(
                    label: 'Pet Age',
                    hint: 'Enter Pet Age',
                    ispass: false,
                    controller: petController.petAgeController,
                    validator: validatePetAge),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: PetCustomTextField(
                          label: 'Pet Bread',
                          hint: 'Enter Pet Bread',
                          ispass: false,
                          controller: petController.petBreadController,
                          validator: validatePetBreed),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PetCustomTextField(
                          label: 'Pet Species',
                          hint: 'Enter Pet Specied',
                          ispass: false,
                          controller: petController.petSpeciesController,
                          validator: validatePetSpecies),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                petDropdown(
                  "Gender",
                  petController.genderList,
                  petController.slectedGender,
                  (value) {
                    setState(() {
                      petController.slectedGender = value;
                    });
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: GestureDetector(
                    onTap: changeImage,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: whiteColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: profileImageWeb != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                profileImageWeb!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          : profileImagePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(profileImagePath!),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.camera_alt,
                                  color: whiteColor, size: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Choose Pet Image',
                  style: TextStyle(color: whiteColor, fontFamily: bold),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> changeImage() async {
    setState(() {
      isloading = true;
    });
    try {
      final pickImage = ImagePicker();
      final pickFile = await pickImage.pickImage(
        source: ImageSource.gallery,
      );

      if (pickFile == null) {
        return;
      }

      if (kIsWeb) {
        profileImageWeb = await pickFile.readAsBytes();
      } else {
        profileImagePath = pickFile.path;
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
    setState(() {
      isloading = false;
    });
  }

  Future<void> addpet(BuildContext context) async {
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

      var petadd = firestore.collection(petCollection).doc();
      await petadd.set({
        "pet_id": petadd.id,
        "owner_id": user.uid,
        'pet_image': base64image,
        'pet_wishlist': FieldValue.arrayUnion([]),
        'pet_name': petController.petNameController.text,
        'pet_age': petController.petAgeController.text,
        'pet_gender': petController.slectedGender,
        'pet_species': petController.petSpeciesController.text,
        'pet_bread': petController.petBreadController.text,
      });

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const PetScreen()));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pet Added Successfully.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    } catch (e) {
      showError("Failed to add pet: $e");
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
}
