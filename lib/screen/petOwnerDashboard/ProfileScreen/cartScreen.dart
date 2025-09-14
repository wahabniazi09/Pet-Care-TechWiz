import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_care/screen/petOwnerDashboard/ProfileScreen/ordersaddScreen.dart';
import 'package:pet_care/screen/widgets/ownButton.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, int> quantities = {};
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Cart")),
        body: const Center(child: Text("Please login to see your cart")),
      );
    }

    final cartRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("cart");

    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),
      body: StreamBuilder<QuerySnapshot>(
        stream: cartRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var cartItems = snapshot.data!.docs;
          if (cartItems.isEmpty) {
            return const Center(child: Text("Your cart is empty"));
          }

          // Initialize local quantities
          for (var item in cartItems) {
            if (!quantities.containsKey(item.id)) {
              quantities[item.id] = item["quantity"] ?? 1;
            }
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var item = cartItems[index];
                    int quantity = quantities[item.id]!;
                    double price = (item["p_price"] ?? 0) is double
                        ? item["p_price"]
                        : double.tryParse(item["p_price"].toString()) ?? 0.0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: item["p_image"] != null &&
                                item["p_image"].toString().isNotEmpty
                            ? Image.memory(base64Decode(item["p_image"]),
                                width: 50, height: 50, fit: BoxFit.cover)
                            : const Icon(Icons.image_not_supported),
                        title: Text(item["p_name"]),
                        subtitle: Text("Rs $price x $quantity"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                if (quantity > 1) {
                                  setState(() {
                                    quantities[item.id] = quantity - 1;
                                  });
                                  cartRef
                                      .doc(item["p_id"])
                                      .update({"quantity": quantity - 1});
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  quantities[item.id] = quantity + 1;
                                });
                                cartRef
                                    .doc(item["p_id"])
                                    .update({"quantity": quantity + 1});
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                cartRef.doc(item["p_id"]).delete();
                                setState(() {
                                  quantities.remove(item.id);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Ownbutton(
                  title: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : "Place Order",
                  onTap: () {
                    if (!isLoading) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              OrderDetailsPage(cartItems: cartItems),
                        ),
                      );
                    }
                  },
                  width: MediaQuery.of(context).size.width * 0.9,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
