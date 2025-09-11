// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_care/consts/firebase_consts.dart';
import 'package:pet_care/screen/shelterDashboard/shelterScreen.dart';
import 'package:pet_care/screen/shelterDashboard/shelterStore/shelterProductdetails.dart';

class UpdateShelterProduct extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const UpdateShelterProduct(
      {super.key, required this.productId, required this.productData});

  @override
  State<UpdateShelterProduct> createState() => _UpdateShelterProductState();
}

class _UpdateShelterProductState extends State<UpdateShelterProduct> {
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
  void initState() {
    super.initState();

    pnameController.text = widget.productData["p_name"];
    pdescController.text = widget.productData["p_desc"];
    ppriceController.text = widget.productData["p_price"];
    pquantityController.text = widget.productData["p_quantity"];

    selectedCategory = widget.productData["p_category"];
    selectedSubCategory = widget.productData["p_sub_category"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[900],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Add Product',
          style: TextStyle(fontSize: 16.0, color: Colors.white),
        ),
        actions: [
          isloading
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : OutlinedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      updateData(context);
                    }
                  },
                  child: const Text(
                    'Add Product',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTextField("Product Name", pnameController),
                const SizedBox(height: 10),
                buildTextField("Product Description", pdescController),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: buildTextField("Price", ppriceController)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: buildTextField("Quantity", pquantityController)),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  hint: const Text("Select Category"),
                  items: categoryList
                      .map((cat) =>
                          DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                      selectedSubCategory = null;
                      subCategoryList = getSubCategories(value!);
                    });
                  },
                  validator: (value) =>
                      value == null ? "Please select category" : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedSubCategory,
                  hint: const Text("Select Sub Category"),
                  items: subCategoryList
                      .map((sub) =>
                          DropdownMenuItem(value: sub, child: Text(sub)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSubCategory = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? "Please select sub-category" : null,
                ),
                const SizedBox(height: 15),
                const Text(
                  'Choose Product Image',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Center(
                  child: GestureDetector(
                    onTap: () => changeImage(),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: profileImageWeb != null
                          ? Image.memory(profileImageWeb!, fit: BoxFit.cover)
                          : profileImagePath != null
                              ? Image.file(File(profileImagePath!),
                                  fit: BoxFit.cover)
                              : Image.memory(
                                  base64Decode(widget.productData['p_image']),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'First image will be your display image',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      validator: (value) =>
          value == null || value.isEmpty ? "$label required" : null,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
      ),
    );
  }

  Future<void> updateData(BuildContext context) async {
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

      var petUpdate =
          firestore.collection(productCollection).doc(widget.productId);
      await petUpdate.update({
        "shelter_id": user.uid,
        'p_name': pnameController.text,
        'p_desc': pdescController.text,
        "p_image": base64image,
        'p_price': ppriceController.text,
        'p_quantity': pquantityController.text,
        'p_category': selectedCategory,
        'p_sub_category': selectedSubCategory,
        'updated_at': DateTime.now(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ShelterProductDetails()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product Updated Successfully")),
      );
    } catch (e) {
      showError("Failed to update product: $e");
    } finally {
      setState(() => isloading = false);
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
