import 'package:flutter/material.dart';

class ViewAllAnimals extends StatelessWidget {
  final List<Map<String, dynamic>> animals;
  final Widget Function(Map<String, dynamic>) itemBuilder;

  const ViewAllAnimals({
    super.key,
    required this.animals,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Mobile screens => 2 columns, Tablets/Desktop => 3 columns
    final crossAxisCount = screenWidth < 600 ? 2 : 3;

    // Responsive childAspectRatio (width / height)
    final childAspectRatio =
        (screenWidth / crossAxisCount) / (screenHeight * 0.45);

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Animals"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: animals.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio, // ✅ responsive
          ),
          itemBuilder: (context, index) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    maxHeight: constraints.maxHeight,
                  ),
                  child: itemBuilder(animals[index]),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
