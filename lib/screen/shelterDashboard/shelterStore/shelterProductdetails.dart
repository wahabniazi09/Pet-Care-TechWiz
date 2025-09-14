import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_care/consts/colors.dart';
import 'package:pet_care/consts/firebase_consts.dart';
import 'package:pet_care/screen/shelterDashboard/shelterStore/addProduct.dart';
import 'package:pet_care/screen/shelterDashboard/shelterStore/updateShelterProduct.dart';
import 'package:pet_care/services/authServices/authentication.dart';
import 'package:pet_care/services/firestoreServices/firestoreServices.dart';

class ShelterProductDetails extends StatefulWidget {
  const ShelterProductDetails({super.key});

  @override
  State<ShelterProductDetails> createState() => _ShelterProductDetailsState();
}

class _ShelterProductDetailsState extends State<ShelterProductDetails> {
  final Authentication authentication = Authentication();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProduct()),
          );
        },
        backgroundColor: Colors.deepPurple[900],
        child: const Icon(Icons.add, color: whiteColor),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestoreservices.getproductByshelter(currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No products added yet",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap the + button to add your first product",
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          var product = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: product.length,
            itemBuilder: (context, index) {
              var prod = product[index];
              var productData = prod.data() as Map<String, dynamic>;

              // Convert price to double for proper formatting
              double price = 0.0;
              if (productData['p_price'] != null) {
                if (productData['p_price'] is String) {
                  price = double.tryParse(productData['p_price']) ?? 0.0;
                } else if (productData['p_price'] is num) {
                  price = productData['p_price'].toDouble();
                }
              }

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: productData['p_image'] != null
                        ? Image.memory(
                            base64Decode(productData['p_image']),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                color: Colors.deepPurple[100],
                                child: Icon(Icons.error_outline,
                                    size: 30, color: Colors.deepPurple[900]),
                              );
                            },
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.pets,
                                size: 30, color: Colors.deepPurple[900]),
                          ),
                  ),
                  title: Text(
                    productData['p_name'] ?? "Unnamed",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkFontGrey),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        "Quantity: ${productData['p_quantity']}",
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Price: \$${price.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Category: ${productData['p_sub_category'] ?? 'Not specified'}",
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<int>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[700]),
                    onSelected: (value) async {
                      switch (value) {
                        case 0: // Edit
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateShelterProduct(
                                productId: prod.id,
                                productData: productData,
                              ),
                            ),
                          );
                          break;
                        case 1: // Delete
                          bool confirmDelete = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirm Delete"),
                                content: const Text(
                                    "Are you sure you want to delete this product?"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmDelete == true) {
                            // Show loading indicator
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );

                            try {
                              await FirebaseFirestore.instance
                                  .collection('products')
                                  .doc(prod.id)
                                  .delete();

                              // Close the loading dialog
                              Navigator.of(context).pop();

                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Product deleted successfully"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              // Close the loading dialog
                              Navigator.of(context).pop();

                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error deleting product: $e"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<int>(
                        value: 0,
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text("Edit"),
                          ],
                        ),
                      ),
                      const PopupMenuItem<int>(
                        value: 1,
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text("Delete"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
