import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_care/consts/consts.dart';

class AdoptionFormScreen extends StatefulWidget {
  final Map<String, dynamic> animal;

  const AdoptionFormScreen({super.key, required this.animal});

  @override
  State<AdoptionFormScreen> createState() => _AdoptionFormScreenState();
}

class _AdoptionFormScreenState extends State<AdoptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _experienceController = TextEditingController();

  String? _selectedHomeType;
  bool _hasOtherPets = false;
  bool _hasChildren = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adoption Request"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet Info
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[200],
                      ),
                      child: widget.animal["animal_image"] != null
                          ? Image.memory(
                              base64Decode(widget.animal["animal_image"]),
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Icon(Icons.pets,
                                  size: 40, color: Colors.grey[400]),
                            ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.animal["animal_name"] ?? "Unknown",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.animal["breed"] ?? "Mixed Breed",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Form Title
              const Text(
                "Adoption Application",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Please fill out this form to request adoption",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Personal Information
              _buildTextField(_nameController, "Full Name", Icons.person),
              const SizedBox(height: 15),
              _buildTextField(_emailController, "Email", Icons.email,
                  validator: (value) => (value == null || !value.contains('@'))
                      ? "Enter a valid email"
                      : null),
              const SizedBox(height: 15),
              _buildTextField(_phoneController, "Phone Number", Icons.phone),
              const SizedBox(height: 15),
              _buildTextField(_addressController, "Full Address", Icons.home,
                  maxLines: 3),

              const SizedBox(height: 20),
              // Living Situation
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: "Type of Home",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.house),
                ),
                value: _selectedHomeType,
                items: const [
                  DropdownMenuItem(value: "House", child: Text("House")),
                  DropdownMenuItem(
                      value: "Apartment", child: Text("Apartment")),
                  DropdownMenuItem(
                      value: "Condominium", child: Text("Condominium")),
                  DropdownMenuItem(value: "Other", child: Text("Other")),
                ],
                onChanged: (value) => setState(() {
                  _selectedHomeType = value;
                }),
                validator: (value) =>
                    value == null ? "Please select your home type" : null,
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  const Text("Do you have other pets?"),
                  const Spacer(),
                  Switch(
                    value: _hasOtherPets,
                    onChanged: (v) => setState(() => _hasOtherPets = v),
                  )
                ],
              ),
              Row(
                children: [
                  const Text("Do you have children?"),
                  const Spacer(),
                  Switch(
                    value: _hasChildren,
                    onChanged: (v) => setState(() => _hasChildren = v),
                  )
                ],
              ),
              const SizedBox(height: 20),

              _buildTextField(_experienceController,
                  "Tell us about your experience with pets", Icons.pets,
                  maxLines: 4),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitAdoptionRequest,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text("Submit Request",
                      style: TextStyle(
                          fontSize: 18,
                          color: whiteColor,
                          fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon),
      ),
      validator: validator ??
          (value) =>
              (value == null || value.isEmpty) ? "Please enter $label" : null,
    );
  }

  void _submitAdoptionRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to submit.")),
      );
      return;
    }

    final adoptionRequest = {
      'userId': user.uid, // store current user ID
      'petId': widget.animal['animal_id'],
      'petName': widget.animal['animal_name'],
      'shelterId': widget.animal['shelter_id'],
      'applicantName': _nameController.text,
      'applicantEmail': _emailController.text,
      'applicantPhone': _phoneController.text,
      'applicantAddress': _addressController.text,
      'homeType': _selectedHomeType,
      'hasOtherPets': _hasOtherPets,
      'hasChildren': _hasChildren,
      'experience': _experienceController.text,
      'submissionDate': DateTime.now(),
    };

    await FirebaseFirestore.instance
        .collection('adoption_requests')
        .add(adoptionRequest);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Request submitted successfully!")),
    );
    Navigator.pop(context);
  }
}
