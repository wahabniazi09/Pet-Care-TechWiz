import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_care/screen/user/ProfileScreen/orderScreen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, int> quantities = {}; // Local quantity state
  bool isLoading = false; // For button loading state

  Future<void> placeOrderWithDetails(
      List<QueryDocumentSnapshot> cartItems) async {
    if (user == null || cartItems.isEmpty) return;

    String? name;
    String? address;
    String? phone;

    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();

    bool submitted = false;

    // Show dialog to collect user details
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Enter your details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name")),
              TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Address")),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Phone"),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                name = nameController.text.trim();
                address = addressController.text.trim();
                phone = phoneController.text.trim();
                if (name!.isNotEmpty &&
                    address!.isNotEmpty &&
                    phone!.isNotEmpty) {
                  submitted = true;
                  Navigator.pop(ctx);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("All fields are required!")));
                }
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );

    if (!submitted) return;

    setState(() => isLoading = true); // Start loading

    try {
      final ordersRef = FirebaseFirestore.instance.collection("orders");

      for (var item in cartItems) {
        final data = item.data() as Map<String, dynamic>;

        int quantity = quantities[item.id] ?? 1;
        double price = (data["p_price"] ?? 0) is double
            ? data["p_price"]
            : double.tryParse(data["p_price"].toString()) ?? 0.0;
        String image = data["p_image"] ?? '';

        // Add order to Firestore
        await ordersRef.add({
          "user_id": user!.uid,
          "p_id": data["p_id"] ?? '',
          "p_name": data["p_name"] ?? '',
          "p_price": price,
          "p_image": image,
          "quantity": quantity,
          "name": name,
          "address": address,
          "phone": phone,
          "ordered_at": FieldValue.serverTimestamp(),
        });

        // Remove from cart
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .collection("cart")
            .doc(data["p_id"])
            .delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully!")),
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const OrdersScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error placing order: $e")),
      );
    } finally {
      setState(() => isLoading = false); // Stop loading
    }
  }

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
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          var cartItems = snapshot.data!.docs;
          if (cartItems.isEmpty)
            return const Center(child: Text("Your cart is empty"));

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
                child: ElevatedButton(
                  onPressed:
                      isLoading ? null : () => placeOrderWithDetails(cartItems),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text("Place Order"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
