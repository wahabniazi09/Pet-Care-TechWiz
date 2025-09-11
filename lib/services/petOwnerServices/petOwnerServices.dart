import 'package:flutter/material.dart';

class Petownerservices {
  var petNameController = TextEditingController();
  var petAgeController = TextEditingController();
  var petBreadController = TextEditingController();
  var petSpeciesController = TextEditingController();
  var petGenderController = TextEditingController();

  String slectedGender = "Male";
  final List<String> genderList = ["Male", "Female"];
}
