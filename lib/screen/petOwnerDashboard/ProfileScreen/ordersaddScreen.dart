import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_care/screen/petOwnerDashboard/ProfileScreen/orderScreen.dart';
import 'package:pet_care/screen/widgets/ownButton.dart';

class OrderDetailsPage extends StatefulWidget {
  final List<QueryDocumentSnapshot> cartItems;

  const OrderDetailsPage({super.key, required this.cartItems});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();

  bool isSubmitting = false;

  Future<void> submitOrder() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (user == null) return;

    setState(() => isSubmitting = true);

    try {
      final ordersRef = FirebaseFirestore.instance.collection("orders");

      for (var item in widget.cartItems) {
        final data = item.data() as Map<String, dynamic>;

        int quantity = data["quantity"] ?? 1;
        double price = (data["p_price"] ?? 0) is double
            ? data["p_price"]
            : double.tryParse(data["p_price"].toString()) ?? 0.0;
        String image = data["p_image"] ?? '';

        await ordersRef.add({
          "user_id": user!.uid,
          "p_id": data["p_id"] ?? '',
          "p_name": data["p_name"] ?? '',
          "p_price": price,
          "p_image": image,
          "quantity": quantity,
          "name": nameController.text.trim(),
          "address": addressController.text.trim(),
          "phone": phoneController.text.trim(),
          "ordered_at": FieldValue.serverTimestamp(),
        });

        await FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .collection("cart")
            .doc(data["p_id"])
            .delete();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order placed successfully!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OrdersScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error placing order: $e")),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Order Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Name is required" : null,
              ),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "Address"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Address is required" : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.isEmpty ? "Phone is required" : null,
              ),
              const SizedBox(height: 20),
              Ownbutton(
                title: isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : "Confirm Order",
                onTap: () {
                  isSubmitting ? null : submitOrder();
                },
                width: MediaQuery.of(context).size.width * 0.9,
              )
            ],
          ),
        ),
      ),
    );
  }
}
