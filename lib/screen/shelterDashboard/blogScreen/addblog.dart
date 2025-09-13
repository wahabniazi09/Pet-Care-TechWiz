import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pet_care/consts/colors.dart';
import 'package:pet_care/consts/firebase_consts.dart';
import 'package:pet_care/screen/shelterDashboard/blogScreen/blogHome.dart';

import 'package:pet_care/screen/widgets/comonTextField.dart';
import 'package:pet_care/services/validationServices/validation_services.dart';

class AddBlogScreen extends StatefulWidget {
  const AddBlogScreen({super.key});

  @override
  State<AddBlogScreen> createState() => _AddBlogScreenState();
}

class _AddBlogScreenState extends State<AddBlogScreen> {
  bool isLoading = false;
  Uint8List? blogImageWeb;
  String? blogImagePath;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _excerptController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  List<String> categoryList = ["Health", "Nutrition", "Training", "Others"];
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[900],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "Add Blog",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : OutlinedButton(
                  onPressed: () => submitBlog(),
                  child: const Text(
                    'Publish',
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
              // Blog Image
              Center(
                child: GestureDetector(
                  onTap: () => pickImage(),
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.deepPurple[200],
                    ),
                    child: blogImageWeb != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child:
                                Image.memory(blogImageWeb!, fit: BoxFit.cover),
                          )
                        : blogImagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(File(blogImagePath!),
                                    fit: BoxFit.cover),
                              )
                            : const Icon(Icons.camera_alt,
                                color: Colors.white, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Tap to select blog image',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 20),

              // Blog Details Header
              Center(
                child: Text(
                  "Blog Details",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: whiteColor),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              buildTextField("Title", _titleController, validateProductName),
              const SizedBox(height: 12),

              // Excerpt
              buildTextField(
                  "Excerpt", _excerptController, validateProductDescription),
              const SizedBox(height: 12),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: "Select Category",
                  labelStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.yellow),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                dropdownColor: Colors.deepPurple[800],
                items: categoryList
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat,
                              style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[800],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.yellow, width: 1.5),
                ),
                child: TextFormField(
                  controller: _contentController,
                  validator: validateProductDescription,
                  maxLines: null, // allows content to grow dynamically
                  minLines: 8, // initial visible height
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Enter full content here...",
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
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

  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      if (kIsWeb) {
        blogImageWeb = await pickedFile.readAsBytes();
      } else {
        blogImagePath = pickedFile.path;
      }
      setState(() {});
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> submitBlog() async {
    if ((kIsWeb && blogImageWeb == null) ||
        (!kIsWeb && blogImagePath == null)) {
      showError("Please select an image");
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      String base64Image;
      if (kIsWeb) {
        base64Image = base64Encode(blogImageWeb!);
      } else {
        base64Image = base64Encode(File(blogImagePath!).readAsBytesSync());
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        showError("User not logged in");
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection(userCollection)
          .doc(user.uid)
          .get();
      final authorName = userDoc.data()?["name"] ?? "Unknown";

      await FirebaseFirestore.instance.collection('blogs').add({
        'title': _titleController.text.trim(),
        'excerpt': _excerptController.text.trim(),
        'content': _contentController.text.trim(),
        'category': selectedCategory,
        'author': authorName,
        'author_id': user.uid,
        'date': DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
        'image': base64Image,
      });

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const BlogHome()));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Blog Added Successfully.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    } catch (e) {
      showError("Failed to add blog: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(message, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
