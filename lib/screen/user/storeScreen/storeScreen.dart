import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_care/consts/styles.dart';
import 'package:pet_care/consts/theme_constant.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Pet Store',
          style: TextStyle(
            fontFamily: bold, 
            color: AppTheme.primaryColor, 
            fontSize: 22
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
      ),
      body: Column(
        children: [
          // Modern Horizontal Category Scroll
          SizedBox(
            height: isSmallScreen ? 80 : 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16, 
                vertical: isSmallScreen ? 8 : 12
              ),
              itemCount: categoriesList.length,
              itemBuilder: (context, index) {
                var category = categoriesList[index];
                bool isSelected =
                    selectedCategory == category["title"] as String;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.only(right: isSmallScreen ? 8 : 12),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16, 
                    vertical: isSmallScreen ? 8 : 10
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
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
                          size: isSmallScreen ? 24 : 28,
                          color: isSelected ? Colors.white : AppTheme.primaryColor,
                        ),
                        SizedBox(width: isSmallScreen ? 6 : 8),
                        Flexible(
                          child: Text(
                            category["title"] as String,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: semibold,
                              fontSize: isSmallScreen ? 12 : 14,
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
          SizedBox(height: isSmallScreen ? 6 : 8),

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
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No Products Found",
                      style: TextStyle(
                        fontFamily: semibold, 
                        fontSize: isSmallScreen ? 14 : 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                }

                var products = snapshot.data!.docs;

                return GridView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16, 
                    vertical: isSmallScreen ? 8 : 12
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isSmallScreen ? 2 : 2,
                    mainAxisSpacing: isSmallScreen ? 12 : 16,
                    crossAxisSpacing: isSmallScreen ? 12 : 16,
                    mainAxisExtent: isSmallScreen ? 250 : 280,
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
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16)),
                                child: product["p_image"] != null && 
                                        product["p_image"].toString().isNotEmpty
                                    ? Image.memory(
                                        base64Decode(product["p_image"]),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      )
                                    : Container(
                                        color: Colors.grey[200],
                                        child: Icon(
                                          Icons.shopping_bag,
                                          size: 40,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 8 : 12, 
                                vertical: isSmallScreen ? 8 : 10
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product["p_name"],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: semibold, 
                                      fontSize: isSmallScreen ? 13 : 15
                                    ),
                                  ),
                                  SizedBox(height: isSmallScreen ? 4 : 6),
                                  Text(
                                    "Rs ${product["p_price"]}",
                                    style: TextStyle(
                                      fontFamily: bold,
                                      fontSize: isSmallScreen ? 14 : 16,
                                      color: AppTheme.primaryColor,
                                    ),
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