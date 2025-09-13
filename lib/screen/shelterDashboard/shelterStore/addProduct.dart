import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_care/consts/colors.dart';
import 'package:pet_care/consts/firebase_consts.dart';
import 'package:pet_care/screen/shelterDashboard/shelterScreen.dart';
import 'package:pet_care/screen/widgets/comonTextField.dart';
import 'package:pet_care/services/validationServices/validation_services.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  bool isloading = false;
  Uint8List? profileImageWeb;
  String? profileImagePath;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController pnameController = TextEditingController();
  final TextEditingController pdescController = TextEditingController();
  final TextEditingController ppriceController = TextEditingController();
  final TextEditingController pquantityController = TextEditingController();

  List<String> categoryList = ["Food", "Toys", "Clothes"];
  List<String> subCategoryList = [];
  String? selectedCategory;
  String? selectedSubCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[900],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "Add Product",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          isloading
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : OutlinedButton(
                  onPressed: () {
                    addData(context);
                  },
                  child: const Text(
                    'Add Product',
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
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/pet123.png',
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 140,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: Text(
                  "Product Details",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: whiteColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // No validation
              buildTextField(
                  "Product Name", pnameController, validateProductName),
              const SizedBox(height: 12),
              buildTextField("Product Description", pdescController,
                  validateProductDescription),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: buildTextField(
                        "Price", ppriceController, validatePrice,
                        inputType: TextInputType.number),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildTextField(
                        "Quantity", pquantityController, validateQuantity,
                        inputType: TextInputType.number),
                  ),
                ],
              ),

              const SizedBox(height: 12),
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
                    selectedSubCategory = null;
                    subCategoryList = getSubCategories(value!);
                  });
                },
              ),

              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedSubCategory,
                decoration: InputDecoration(
                  labelText: "Select Sub Category",
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
                items: subCategoryList
                    .map((sub) => DropdownMenuItem(
                          value: sub,
                          child: Text(sub,
                              style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSubCategory = value;
                  });
                },
              ),

              const SizedBox(height: 20),
              const Text(
                'Choose Product Image',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),

              Center(
                child: GestureDetector(
                  onTap: () => changeImage(),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.deepPurple[200],
                    ),
                    child: profileImageWeb != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(profileImageWeb!,
                                fit: BoxFit.cover),
                          )
                        : profileImagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(File(profileImagePath!),
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
                  'First image will be your display image',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addData(BuildContext context) async {
    try {
      if ((kIsWeb && profileImageWeb == null) ||
          (!kIsWeb && profileImagePath == null)) {
        showError("Please select an image");
        return;
      }

      setState(() {
        isloading = true;
      });

      String base64image;
      if (kIsWeb) {
        base64image = base64Encode(profileImageWeb!);
      } else {
        base64image = base64Encode(File(profileImagePath!).readAsBytesSync());
      }
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        showError("User not logged in");
        return;
      }
      var store =
          FirebaseFirestore.instance.collection(productCollection).doc();
      await store.set({
        "p_id": store.id,
        "shelter_id": user.uid,
        'p_name': pnameController.text,
        'p_desc': pdescController.text,
        'p_price': ppriceController.text,
        'p_quantity': pquantityController.text,
        'p_category': selectedCategory,
        'p_sub_category': selectedSubCategory,
        'p_image': base64image,
        'created_at': DateTime.now(),
      });

      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const ShelterScreen()));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Product Added Successfully.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    } catch (e) {
      showError("Failed to add product: $e");
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          message,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Future<void> changeImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return;

      if (kIsWeb) {
        profileImageWeb = await pickedFile.readAsBytes();
      } else {
        profileImagePath = pickedFile.path;
      }
      setState(() {});
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  List<String> getSubCategories(String category) {
    if (category == "Food") {
      return ["Dry Food", "Wet Food", "Snacks"];
    } else if (category == "Toys") {
      return ["Chew Toys", "Balls", "Interactive"];
    } else if (category == "Clothes") {
      return ["Winter", "Summer", "Accessories"];
    }
    return [];
  }
}
