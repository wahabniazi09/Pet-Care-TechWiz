import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pet_care/screen/petOwnerDashboard/homeScreen/components/addoptionFormScreen.dart';

class PetDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> animal;

  const PetDetailsScreen({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(animal["animal_name"] ?? "Pet Details"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet Image
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey[200],
              ),
              child: animal["animal_image"] != null
                  ? Image.memory(
                      base64Decode(animal["animal_image"]),
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child:
                          Icon(Icons.pets, size: 100, color: Colors.grey[400]),
                    ),
            ),
            const SizedBox(height: 20),

            // Pet Name and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  animal["animal_name"] ?? "Unknown",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  backgroundColor: animal["adoption_status"] == "Adopted"
                      ? Colors.green
                      : Colors.deepOrange,
                  label: Text(
                    animal["adoption_status"] ?? "Unknown",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Breed and Age
            Text(
              "${animal["breed"] ?? "Mixed Breed"} • Age:  ${animal["animal_age"] ?? "Unknown age"}",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),

            // Details Section
            const Text(
              "Details",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Details Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _detailItem("Gender", animal["animal_gender"] ?? "Unknown",
                    Icons.transgender),
                _detailItem(
                    "Size", animal["size"] ?? "Unknown", Icons.straighten),
                _detailItem(
                    "Color", animal["color"] ?? "Unknown", Icons.color_lens),
                _detailItem("Location", animal["location"] ?? "Unknown",
                    Icons.location_on),
              ],
            ),
            const SizedBox(height: 20),

            // Description
            const Text(
              "About",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              animal["description"] ?? "No description available.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),

            // Adopt Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdoptionFormScreen(animal: animal),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Adopt Now",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _detailItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepOrange),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
