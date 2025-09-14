import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddEditPetScreen extends StatefulWidget {
  final Map<String, dynamic>? petData;
  final String? petId;

  const AddEditPetScreen({super.key, this.petData, this.petId});

  @override
  State<AddEditPetScreen> createState() => _AddEditPetScreenState();
}

class _AddEditPetScreenState extends State<AddEditPetScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = "";
  String species = "";
  String breed = "";
  String age = "";
  String gender = "";
  String? base64Image;

  // Predefined dropdown values
  final List<String> genderOptions = ["Male", "Female"];
  final List<String> breedOptions = ["Rabbit", "Dog", "Cat", "Bird", "Other"];

  @override
  void initState() {
    super.initState();
    if (widget.petData != null) {
      name = widget.petData!["pet_name"] ?? "";
      species = widget.petData!["pet_species"] ?? "";
      breed = widget.petData!["pet_bread"] ?? "";
      age = widget.petData!["pet_age"] ?? "";
      gender = widget.petData!["pet_gender"] ?? "";
      base64Image = widget.petData!["pet_image"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.petId == null ? "Add Pet" : "Edit Pet"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final image =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    final bytes = await image.readAsBytes();
                    setState(() {
                      base64Image = base64Encode(bytes);
                    });
                  }
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: base64Image != null
                      ? MemoryImage(base64Decode(base64Image!))
                      : null,
                  child: base64Image == null
                      ? const Icon(Icons.add_a_photo, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // Pet Name
              _buildTextField("Pet Name", name, (val) => name = val,
                  validator: true),

              // Species
              _buildTextField("Species", species, (val) => species = val),

              // Breed Dropdown
              DropdownButtonFormField<String>(
                value: breed.isNotEmpty ? breed : null,
                decoration: const InputDecoration(
                  labelText: "Breed",
                  border: OutlineInputBorder(),
                ),
                items: breedOptions
                    .map((b) => DropdownMenuItem(
                          value: b,
                          child: Text(b),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => breed = val ?? ""),
                validator: (val) =>
                    val == null || val.isEmpty ? "Select Breed" : null,
              ),
              const SizedBox(height: 12),

              // Age
              _buildTextField("Age", age, (val) => age = val),

              // Gender Dropdown
              DropdownButtonFormField<String>(
                value: gender.isNotEmpty ? gender : null,
                decoration: const InputDecoration(
                  labelText: "Gender",
                  border: OutlineInputBorder(),
                ),
                items: genderOptions
                    .map((g) => DropdownMenuItem(
                          value: g,
                          child: Text(g),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => gender = val ?? ""),
                validator: (val) =>
                    val == null || val.isEmpty ? "Select Gender" : null,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _savePet,
                  child: Text(widget.petId == null ? "Add Pet" : "Update Pet"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, String initialValue, Function(String) onChanged,
      {bool validator = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
        validator: validator
            ? (val) => val == null || val.isEmpty ? "Enter $label" : null
            : null,
      ),
    );
  }

  void _savePet() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final petData = {
      "owner_id": user.uid,
      "pet_name": name,
      "pet_species": species,
      "pet_bread": breed,
      "pet_age": age,
      "pet_gender": gender,
      "pet_image": base64Image ?? "",
    };

    final firestore = FirebaseFirestore.instance;
    if (widget.petId == null) {
      await firestore.collection("pet").add(petData);
    } else {
      await firestore.collection("pet").doc(widget.petId).update(petData);
    }

    Navigator.pop(context);
  }
}
