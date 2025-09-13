import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pet_care/consts/colors.dart';
import 'package:pet_care/screen/shelterDashboard/blogScreen/blogHome.dart';
import 'package:pet_care/services/validationServices/validation_services.dart';

class UpdateBlogScreen extends StatefulWidget {
  final String blogId;
  final Map<String, dynamic> blogData;

  const UpdateBlogScreen({
    super.key,
    required this.blogId,
    required this.blogData,
  });

  @override
  State<UpdateBlogScreen> createState() => UpdateBlogScreenState();
}

class UpdateBlogScreenState extends State<UpdateBlogScreen> {
  bool isLoading = false;
  Uint8List? blogImageWeb;
  String? blogImagePath;

  final formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var excerptController = TextEditingController();
  var contentController = TextEditingController();
  List<String> categoryList = ["Health", "Nutrition", "Training", "Others"];
  String? selectedCategory;
  String? existingImage;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.blogData["title"];
    excerptController.text = widget.blogData["excerpt"];
    contentController.text = widget.blogData["content"];
    selectedCategory = widget.blogData["category"];
    existingImage = widget.blogData["image"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[900],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "Update Blog",
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
                  onPressed: () => updateBlog(),
                  child: const Text(
                    'Update',
                    style: TextStyle(color: whiteColor),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            : existingImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(
                                        base64Decode(existingImage!),
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
                  'Tap to change blog image',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: titleController,
                validator: validateProductName,
                style: const TextStyle(color: Colors.white),
                decoration: inputDecoration("Title"),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: excerptController,
                validator: validateProductDescription,
                style: const TextStyle(color: Colors.white),
                decoration: inputDecoration("Excerpt"),
              ),
              const SizedBox(height: 12),

              // Category
              DropdownButtonFormField<String>(
                value: selectedCategory != null &&
                        categoryList.contains(selectedCategory)
                    ? selectedCategory
                    : null,
                decoration: inputDecoration("Select Category"),
                style: const TextStyle(color: Colors.white),
                dropdownColor: Colors.deepPurple[800],
                items: categoryList
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat,
                              style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (value) => setState(() {
                  selectedCategory = value;
                }),
              ),
              const SizedBox(height: 12),

              // Content
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[800],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.yellow, width: 1.5),
                ),
                child: TextFormField(
                  controller: contentController,
                  validator: validateProductDescription,
                  maxLines: null,
                  minLines: 8,
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

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.yellow),
        borderRadius: BorderRadius.circular(12),
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

  Future<void> updateBlog() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      String base64Image = existingImage ?? "";

      if (blogImageWeb != null) {
        base64Image = base64Encode(blogImageWeb!);
      } else if (blogImagePath != null) {
        base64Image = base64Encode(File(blogImagePath!).readAsBytesSync());
      }

      await FirebaseFirestore.instance
          .collection('blogs')
          .doc(widget.blogId)
          .update({
        'title': titleController.text.trim(),
        'excerpt': excerptController.text.trim(),
        'content': contentController.text.trim(),
        'category': selectedCategory,
        'date': DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
        'image': base64Image,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BlogHome()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Blog Updated Successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}
