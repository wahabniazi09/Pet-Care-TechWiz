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
      appBar: AppBar(title: const Text("My Orders")),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersRef,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          var orders = snapshot.data!.docs;
          if (orders.isEmpty) return const Center(child: Text("No orders yet"));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var item = orders[index];
              int quantity = item["quantity"] is int
                  ? item["quantity"]
                  : int.tryParse(item["quantity"].toString()) ?? 1;
              double price = item["p_price"] is double
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
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Rs $price x $quantity"),
                      Text("Name: ${item["name"] ?? '-'}"),
                      Text("Address: ${item["address"] ?? '-'}"),
                      Text("Phone: ${item["phone"] ?? '-'}"),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // Delete from top-level orders collection
                      FirebaseFirestore.instance
                          .collection("orders")
                          .doc(item.id)
                          .delete();
                    },
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
