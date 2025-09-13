import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_care/consts/colors.dart';
import 'package:pet_care/consts/styles.dart';
import 'package:pet_care/screen/user/storeScreen/components/item_details.dart';

const categoriesList = [
  {"title": "All", "icon": Icons.list_alt},
  {"title": "Food", "icon": Icons.fastfood},
  {"title": "Toys", "icon": Icons.toys},
  {"title": "Clothes", "icon": Icons.checkroom},
];

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  String selectedCategory = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Pet Store',
          style: TextStyle(fontFamily: bold, color: Colors.black, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Modern Horizontal Category Scroll
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: categoriesList.length,
              itemBuilder: (context, index) {
                var category = categoriesList[index];
                bool isSelected =
                    selectedCategory == category["title"] as String;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.deepOrange : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color:
                          isSelected ? Colors.deepOrange : Colors.grey.shade300,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(isSelected ? 0.3 : 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedCategory = category["title"] as String;
                      });
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          category["icon"] as IconData,
                          size: 28,
                          color: isSelected ? Colors.white : Colors.deepOrange,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            category["title"] as String,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: semibold,
                              fontSize: 14,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Products Grid
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: selectedCategory == "All"
                  ? FirebaseFirestore.instance
                      .collection("products")
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection("products")
                      .where("p_category", isEqualTo: selectedCategory)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Products Found",
                      style: TextStyle(fontFamily: semibold, fontSize: 16),
                    ),
                  );
                }

                var products = snapshot.data!.docs;

                return GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  physics: const BouncingScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 280,
                  ),
                  itemBuilder: (context, index) {
                    var product = products[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ItemDetails(
                              title: product["p_name"],
                              data: product,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20)),
                                child: Image.memory(
                                  base64Decode(product["p_image"]),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product["p_name"],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontFamily: semibold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Rs ${product["p_price"]}",
                                    style: const TextStyle(
                                        fontFamily: bold,
                                        fontSize: 16,
                                        color: redColor),
                                  ),
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
          ),
        ],
      ),
    );
  }
}
