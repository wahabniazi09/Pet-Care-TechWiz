import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_care/screen/user/ProfileScreen/cartScreen.dart';
import 'package:pet_care/consts/colors.dart';
import 'package:pet_care/consts/styles.dart';

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
        const SnackBar(content: Text("Please login to add items to cart")),
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
      SnackBar(content: Text("Added $quantity item(s) to cart")),
    );
  }

  @override
  Widget build(BuildContext context) {
    var product = widget.data;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontFamily: bold)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
            icon: const Icon(Icons.shopping_cart),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            if (product["p_image"] != null &&
                product["p_image"].toString().isNotEmpty)
              Image.memory(base64Decode(product["p_image"]),
                  width: double.infinity, height: 250, fit: BoxFit.cover)
            else
              Container(
                  height: 250,
                  color: Colors.grey,
                  child: const Icon(Icons.image, size: 80)),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product["p_name"] ?? "No name",
                      style: const TextStyle(
                          fontSize: 20,
                          fontFamily: semibold,
                          color: Colors.black87)),
                  const SizedBox(height: 6),
                  Text("Rs: ${product["p_price"] ?? 0}",
                      style: const TextStyle(
                          fontSize: 18, fontFamily: bold, color: redColor)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Text("Quantity:",
                      style: TextStyle(fontFamily: semibold)),
                  const SizedBox(width: 12),
                  IconButton(
                      onPressed: () {
                        if (quantity > 1) setState(() => quantity--);
                      },
                      icon: const Icon(Icons.remove)),
                  Text("$quantity",
                      style: const TextStyle(
                          fontSize: 16,
                          fontFamily: bold,
                          color: Colors.black87)),
                  IconButton(
                      onPressed: () {
                        if (quantity < (product["p_quantity"] ?? 100))
                          setState(() => quantity++);
                      },
                      icon: const Icon(Icons.add)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Description",
                      style: TextStyle(fontFamily: bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(product["p_desc"] ?? "No description provided.",
                      style: const TextStyle(
                          fontFamily: semibold, color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        margin: const EdgeInsets.all(12),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: redColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: addToCart,
          child: const Text(
            "Add To Cart",
            style:
                TextStyle(fontFamily: bold, fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
