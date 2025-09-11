import 'package:flutter/material.dart';
import 'package:pet_care/consts/colors.dart';
import 'package:pet_care/consts/styles.dart';
import 'package:pet_care/screen/user/storeScreen/components/storeDetails.dart';

const categoriesList = [
  {"title": "Food", "image": "assets/images/food.png"},
  {"title": "Toys", "image": "assets/images/toys.png"},
  {"title": "Clothes", "image": "assets/images/accessories.png"},
];

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Store',
          style: TextStyle(fontFamily: bold, color: Colors.black),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        physics: const BouncingScrollPhysics(),
        itemCount: categoriesList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: 180,
        ),
        itemBuilder: (context, index) {
          var category = categoriesList[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StoreDetails(title: category["title"]!),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: whiteColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(category["image"]!, width: 80, height: 80),
                  const SizedBox(height: 12),
                  Text(
                    category["title"]!,
                    style: const TextStyle(fontFamily: semibold, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
