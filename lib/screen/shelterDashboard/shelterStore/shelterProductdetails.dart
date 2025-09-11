import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_care/consts/colors.dart';
import 'package:pet_care/consts/firebase_consts.dart';
import 'package:pet_care/screen/petOwnerDashboard/petHome/petUpdates.dart';
import 'package:pet_care/screen/shelterDashboard/shelterScreen.dart';
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AddProduct()),
          );
        },
        backgroundColor: Colors.deepPurple[900],
        child: const Icon(Icons.add, color: whiteColor),
      ),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[900],
        title: const Text(
          "My Products",
          style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: whiteColor),
            onPressed: () => authentication.logOut(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestoreservices.getproductByshelter(currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No product added yet",
                style: TextStyle(fontSize: 16, color: Colors.grey),
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

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
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
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: Colors.deepPurple[100],
                            child: const Icon(Icons.pets,
                                size: 30, color: Colors.white),
                          ),
                  ),
                  title: Text(
                    productData['p_name'] ?? "Unnamed",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkFontGrey),
                  ),
                  subtitle: Text(
                    "${productData['p_quantity']} • ${productData['p_price']} • ${productData['p_sub_category']}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: PopupMenuButton<int>(
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
                          await Firestoreservices.deletepet(prod.id);
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
