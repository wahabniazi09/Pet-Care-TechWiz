import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Orders")),
        body: const Center(child: Text("Please login to see orders")),
      );
    }

    final ordersRef = FirebaseFirestore.instance
        .collection("orders")
        .where("user_id", isEqualTo: user.uid)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersRef,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var orders = snapshot.data!.docs;
          if (orders.isEmpty) {
            return const Center(
              child: Text("No orders yet",
                  style: TextStyle(fontSize: 16, color: Colors.black54)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var item = orders[index];
              int quantity = item["quantity"] is int
                  ? item["quantity"]
                  : int.tryParse(item["quantity"].toString()) ?? 1;
              double price = item["p_price"] is double
                  ? item["p_price"]
                  : double.tryParse(item["p_price"].toString()) ?? 0.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade100, Colors.teal.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: item["p_image"] != null &&
                                item["p_image"].toString().isNotEmpty
                            ? Image.memory(
                                base64Decode(item["p_image"]),
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.image,
                                    size: 36, color: Colors.grey),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["p_name"] ?? "Unknown Item",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text("Rs $price x $quantity",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black87)),
                            Text("Name: ${item["name"] ?? '-'}",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black54)),
                            Text("Address: ${item["address"] ?? '-'}",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black54)),
                            Text("Phone: ${item["phone"] ?? '-'}",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black54)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection("orders")
                              .doc(item.id)
                              .delete();
                        },
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
