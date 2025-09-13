import 'package:flutter/material.dart';

class ShelterOwnerServices {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final typeController = TextEditingController();
  final breedController = TextEditingController();
  final healthController = TextEditingController();
  final descriptionController = TextEditingController();
  final weightController = TextEditingController();
  final sizeController = TextEditingController();
  final colorController = TextEditingController();
  final locationController = TextEditingController();

  String selectedGender = "Male";
  String selectedAdoptionStatus = "Available";
  String? selectedAnimalType;
  String? selectedBreed;
  String selectedVaccination = "Yes";
  String selectedNeutered = "No";
  String selectedSize = "Medium";
  String selectedColor = "Brown";
  String selectedLocation = "Karachi";

  String? animalImageBase64;

  void clearAll() {
    nameController.clear();
    ageController.clear();
    typeController.clear();
    breedController.clear();
    healthController.clear();
    descriptionController.clear();
    weightController.clear();
    sizeController.clear();
    colorController.clear();
    locationController.clear();

    selectedGender = "Male";
    selectedAdoptionStatus = "Available";
    selectedAnimalType = null;
    selectedBreed = null;
    selectedVaccination = "Yes";
    selectedNeutered = "No";
    selectedSize = "Medium";
    selectedColor = "Brown";
    animalImageBase64 = null;
    selectedLocation = "Karachi";
  }
}
