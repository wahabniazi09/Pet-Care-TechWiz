import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditAdoptionRequestScreen extends StatefulWidget {
  final String requestId; // Firestore document ID
  final Map<String, dynamic> requestData; // Existing data

  const EditAdoptionRequestScreen({
    super.key,
    required this.requestId,
    required this.requestData,
  });

  @override
  State<EditAdoptionRequestScreen> createState() =>
      _EditAdoptionRequestScreenState();
}

class _EditAdoptionRequestScreenState extends State<EditAdoptionRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _experienceController;

  String? _selectedHomeType;
  bool _hasOtherPets = false;
  bool _hasChildren = false;

  @override
  void initState() {
    super.initState();

    // pre-fill fields with existing data
    _nameController =
        TextEditingController(text: widget.requestData['applicantName'] ?? "");
    _emailController =
        TextEditingController(text: widget.requestData['applicantEmail'] ?? "");
    _phoneController =
        TextEditingController(text: widget.requestData['applicantPhone'] ?? "");
    _addressController = TextEditingController(
        text: widget.requestData['applicantAddress'] ?? "");
    _experienceController =
        TextEditingController(text: widget.requestData['experience'] ?? "");

    _selectedHomeType = widget.requestData['homeType'];
    _hasOtherPets = widget.requestData['hasOtherPets'] ?? false;
    _hasChildren = widget.requestData['hasChildren'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Adoption Request"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, "Full Name", Icons.person),
              const SizedBox(height: 15),
              _buildTextField(_emailController, "Email", Icons.email),
              const SizedBox(height: 15),
              _buildTextField(_phoneController, "Phone", Icons.phone),
              const SizedBox(height: 15),
              _buildTextField(_addressController, "Address", Icons.home,
                  maxLines: 3),
              const SizedBox(height: 15),
              DropdownButtonFormField(
                value: _selectedHomeType,
                decoration: InputDecoration(
                  labelText: "Type of Home",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.house),
                ),
                items: const [
                  DropdownMenuItem(value: "House", child: Text("House")),
                  DropdownMenuItem(
                      value: "Apartment", child: Text("Apartment")),
                  DropdownMenuItem(
                      value: "Condominium", child: Text("Condominium")),
                  DropdownMenuItem(value: "Other", child: Text("Other")),
                ],
                onChanged: (val) => setState(() => _selectedHomeType = val),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Text("Do you have other pets?"),
                  const Spacer(),
                  Switch(
                      value: _hasOtherPets,
                      onChanged: (v) => setState(() => _hasOtherPets = v))
                ],
              ),
              Row(
                children: [
                  const Text("Do you have children?"),
                  const Spacer(),
                  Switch(
                      value: _hasChildren,
                      onChanged: (v) => setState(() => _hasChildren = v))
                ],
              ),
              const SizedBox(height: 15),
              _buildTextField(
                  _experienceController, "Experience with Pets", Icons.pets,
                  maxLines: 3),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateRequest,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text("Update Request",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon),
      ),
      validator: (value) =>
          (value == null || value.isEmpty) ? "Enter $label" : null,
    );
  }

  Future<void> _updateRequest() async {
    if (!_formKey.currentState!.validate()) return;

    await FirebaseFirestore.instance
        .collection('adoption_requests')
        .doc(widget.requestId)
        .update({
      'applicantName': _nameController.text,
      'applicantEmail': _emailController.text,
      'applicantPhone': _phoneController.text,
      'applicantAddress': _addressController.text,
      'homeType': _selectedHomeType,
      'hasOtherPets': _hasOtherPets,
      'hasChildren': _hasChildren,
      'experience': _experienceController.text,
      'lastUpdated': DateTime.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Request updated successfully!")),
    );
    Navigator.pop(context);
  }
}
