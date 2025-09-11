import 'dart:convert';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    var product = widget.data;

    List<String> images = [];
    if (product["p_image"] != null && product["p_image"] is List) {
      images = List<String>.from(product["p_image"]);
    } else if (product["p_image"] != null) {
      images = [product["p_image"]];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontFamily: bold)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Image.memory(
                    base64Decode(images[index]),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product["p_name"] ?? "No name",
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: semibold,
                      color: darkFontGrey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Rs: ${product["p_price"] ?? 0}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: bold,
                      color: redColor,
                    ),
                  ),
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
                      if (quantity > 1) {
                        setState(() => quantity--);
                      }
                    },
                    icon: const Icon(Icons.remove),
                  ),
                  Text("$quantity",
                      style: const TextStyle(
                          fontSize: 16, fontFamily: bold, color: darkFontGrey)),
                  IconButton(
                    onPressed: () {
                      if (quantity <
                          (int.tryParse(product["p_quantity"].toString()) ??
                              1)) {
                        setState(() => quantity++);
                      }
                    },
                    icon: const Icon(Icons.add),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "${product["p_quantity"] ?? 0} available",
                    style: const TextStyle(
                        fontFamily: semibold, color: textfieldGrey),
                  ),
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
                  Text(
                    product["p_desc"] ?? "No description provided.",
                    style: const TextStyle(
                      fontFamily: semibold,
                      color: darkFontGrey,
                    ),
                  ),
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
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Added $quantity item(s) to cart")),
            );
          },
          child: const Text(
            "Add To Cart",
            style: TextStyle(
              fontFamily: bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
