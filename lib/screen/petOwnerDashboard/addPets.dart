import 'package:flutter/material.dart';
import 'package:pet_care/consts/colors.dart';
import 'package:pet_care/consts/styles.dart';
import 'package:pet_care/screen/petOwnerDashboard/petOwnerWidgets/admin_custom_form.dart';
import 'package:pet_care/services/petOwnerServices.dart';
import 'package:pet_care/services/validation_services.dart';

class AddPet extends StatefulWidget {
  const AddPet({super.key});

  @override
  State<AddPet> createState() => _AddPetState();
}

class _AddPetState extends State<AddPet> {
  bool isloading = false;
  final _formKey = GlobalKey<FormState>();
  final petController = Petownerservices();

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
                  onPressed: () {},
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
                    validator: validateProductName),
                const SizedBox(height: 10),
                PetCustomTextField(
                    label: 'Pet Age',
                    hint: 'Enter Pet Age',
                    ispass: false,
                    controller: petController.petAgeController,
                    validator: validateProductDescription),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: PetCustomTextField(
                          label: 'Pet Bread',
                          hint: 'Enter Pet Bread',
                          ispass: false,
                          controller: petController.petBreadController,
                          validator: validatePrice),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PetCustomTextField(
                          label: 'Pet Species',
                          hint: 'Enter Pet Specied',
                          ispass: false,
                          controller: petController.petSpeciesController,
                          validator: validateQuantity),
                    ),
                  ],
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
}
