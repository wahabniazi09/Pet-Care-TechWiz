import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_care/consts/styles.dart';
import 'package:pet_care/consts/theme_constant.dart';
import 'package:pet_care/screen/petOwnerDashboard/ProfileScreen/cartScreen.dart';

class ItemDetails extends StatefulWidget {
  final String title;
  final dynamic data;

  const ItemDetails({super.key, required this.title, required this.data});

  @override
  State<ItemDetails> createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  int quantity = 1;

  Future<void> addToCart() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please login to add items to cart"),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      return;
    }

    final cartRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("cart")
        .doc(widget.data["p_id"]);

    final cartItem = await cartRef.get();

    if (cartItem.exists) {
      await cartRef.update({
        "quantity": (cartItem.data()?["quantity"] ?? 0) + quantity,
      });
    } else {
      await cartRef.set({
        "p_id": widget.data["p_id"],
        "p_name": widget.data["p_name"],
        "p_price": widget.data["p_price"],
        "p_image": widget.data["p_image"] ?? '',
        "quantity": quantity,
        "added_at": FieldValue.serverTimestamp(),
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Added $quantity item(s) to cart"),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    var product = widget.data;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            fontFamily: bold,
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
            icon: Icon(
              Icons.shopping_cart,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: isSmallScreen ? 16 : 20),
            if (product["p_image"] != null &&
                product["p_image"].toString().isNotEmpty)
              Image.memory(
                base64Decode(product["p_image"]),
                width: double.infinity,
                height: isSmallScreen ? 200 : 250,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: isSmallScreen ? 200 : 250,
                color: Colors.grey[200],
                child: Icon(
                  Icons.shopping_bag,
                  size: 60,
                  color: Colors.grey[400],
                ),
              ),
            SizedBox(height: isSmallScreen ? 16 : 20),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product["p_name"] ?? "No name",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 20,
                      fontFamily: semibold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 4 : 6),
                  Text(
                    "Rs: ${product["p_price"] ?? 0}",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontFamily: bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
              child: Row(
                children: [
                  Text(
                    "Quantity:",
                    style: TextStyle(
                      fontFamily: semibold,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  IconButton(
                    onPressed: () {
                      if (quantity > 1) setState(() => quantity--);
                    },
                    icon: Icon(
                      Icons.remove,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Text(
                    "$quantity",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontFamily: bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (quantity < (product["p_quantity"] ?? 100))
                        setState(() => quantity++);
                    },
                    icon: Icon(
                      Icons.add,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Description",
                    style: TextStyle(
                        fontFamily: bold, fontSize: isSmallScreen ? 14 : 16),
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  Text(
                    product["p_desc"] ?? "No description provided.",
                    style: TextStyle(
                      fontFamily: semibold,
                      color: Colors.black54,
                      fontSize: isSmallScreen ? 13 : 14,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isSmallScreen ? 60 : 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: isSmallScreen ? 70 : 80,
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
          ),
          onPressed: addToCart,
          child: Text(
            "Add To Cart",
            style: TextStyle(
                fontFamily: bold,
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.white),
          ),
        ),
      ),
    );
  }
}
