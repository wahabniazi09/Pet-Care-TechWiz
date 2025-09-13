// Adoption Form Screen
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdoptionFormScreen extends StatefulWidget {
  final Map<String, dynamic> animal;

  const AdoptionFormScreen({super.key, required this.animal});

  @override
  State<AdoptionFormScreen> createState() => _AdoptionFormScreenState();
}

class _AdoptionFormScreenState extends State<AdoptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();

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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.animal["breed"] ?? "Mixed Breed",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Form Title
              const Text(
                "Adoption Application",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Please fill out this form to request adoption",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),

              // Personal Information
              const Text(
                "Personal Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 15),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email Address",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Address Field
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Full Address",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),

              // Living Situation
              const Text(
                "Living Situation",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 15),

              // Home Type
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: "Type of Home",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.home),
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
                onChanged: (value) {
                  setState(() {
                    _selectedHomeType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select your home type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Other Pets
              Row(
                children: [
                  const Text("Do you have other pets?"),
                  const Spacer(),
                  Switch(
                    value: _hasOtherPets,
                    onChanged: (value) {
                      setState(() {
                        _hasOtherPets = value;
                      });
                    },
                    activeColor: Colors.deepOrange,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Children
              Row(
                children: [
                  const Text("Do you have children?"),
                  const Spacer(),
                  Switch(
                    value: _hasChildren,
                    onChanged: (value) {
                      setState(() {
                        _hasChildren = value;
                      });
                    },
                    activeColor: Colors.deepOrange,
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Experience
              const Text(
                "Pet Experience",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _experienceController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Tell us about your experience with pets",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please share your experience';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _submitAdoptionRequest();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Adoption request submitted successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Submit Adoption Request",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _submitAdoptionRequest() {
    final adoptionRequest = {
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
      'submissionDate': DateTime.now().toString(),
    };

    FirebaseFirestore.instance
        .collection('adoption_requests')
        .add(adoptionRequest);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    super.dispose();
  }
}
