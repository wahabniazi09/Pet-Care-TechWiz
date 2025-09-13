import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_care/consts/firebase_consts.dart';
import 'package:pet_care/consts/styles.dart';
import 'package:pet_care/consts/theme_constant.dart';
import 'package:pet_care/screen/user/storeScreen/components/item_details.dart';

class StoreDetails extends StatelessWidget {
  final String title;
  const StoreDetails({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title, 
          style: TextStyle(
            fontFamily: bold,
            fontSize: isSmallScreen ? 18 : 20,
            color: AppTheme.primaryColor,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 1,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(productCollection)
            .where("p_category", isEqualTo: title)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
            physics: const BouncingScrollPhysics(),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isSmallScreen ? 2 : 2,
              mainAxisSpacing: isSmallScreen ? 8 : 12,
              crossAxisSpacing: isSmallScreen ? 8 : 12,
              mainAxisExtent: isSmallScreen ? 240 : 260,
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
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
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
                          horizontal: isSmallScreen ? 8 : 10, 
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
                                fontSize: isSmallScreen ? 13 : 14
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 4 : 6),
                            Text(
                              "Rs: ${product["p_price"]}",
                              style: TextStyle(
                                fontFamily: bold,
                                fontSize: isSmallScreen ? 14 : 15,
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
    );
  }
}