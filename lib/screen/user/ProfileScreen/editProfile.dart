import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final String uid;
  final Map<String, dynamic> userData;

  const EditProfileScreen({
    super.key,
    required this.uid,
    required this.userData,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  Uint8List? profileImageWeb;
  File? profileImageFile;
  String? _base64Image;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData["name"]);
    _phoneController = TextEditingController(text: widget.userData["phone"]);
    _base64Image = widget.userData["image"];
  }

  /// Pick image for web or mobile
  Future<void> changeImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          profileImageWeb = bytes;
          _base64Image = base64Encode(bytes);
        });
      } else {
        final file = File(pickedFile.path);
        final bytes = await file.readAsBytes();
        setState(() {
          profileImageFile = file;
          _base64Image = base64Encode(bytes);
        });
      }
    }
  }

  /// Save profile to Firestore
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updateData = {
          "name": _nameController.text.trim(),
          "phone": _phoneController.text.trim(),
          "updatedAt": FieldValue.serverTimestamp(),
          "image": _base64Image ?? "", // Save current or new image
        };

        await FirebaseFirestore.instance
            .collection("users")
            .doc(widget.uid)
            .update(updateData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error updating profile: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.deepOrange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.deepOrange, width: 3),
                    ),
                    child: ClipOval(
                      child: kIsWeb
                          ? (profileImageWeb != null
                              ? Image.memory(profileImageWeb!,
                                  fit: BoxFit.cover)
                              : (_base64Image != null &&
                                      _base64Image!.isNotEmpty
                                  ? Image.memory(base64Decode(_base64Image!),
                                      fit: BoxFit.cover)
                                  : Image.asset("assets/default.png",
                                      fit: BoxFit.cover)))
                          : (profileImageFile != null
                              ? Image.file(profileImageFile!, fit: BoxFit.cover)
                              : (_base64Image != null &&
                                      _base64Image!.isNotEmpty
                                  ? Image.memory(base64Decode(_base64Image!),
                                      fit: BoxFit.cover)
                                  : Image.asset("assets/default.png",
                                      fit: BoxFit.cover))),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: changeImage,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child:
                            const Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? "Please enter your name"
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.isEmpty
                    ? "Please enter your phone number"
                    : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange),
                  child: const Text("Save Changes"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
