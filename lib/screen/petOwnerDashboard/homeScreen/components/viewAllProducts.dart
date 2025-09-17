import 'package:flutter/material.dart';

class ViewAllProducts extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final Widget Function(Map<String, dynamic>) itemBuilder;

  const ViewAllProducts({
    super.key,
    required this.products,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Products"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.62,
          ),
          itemBuilder: (context, index) => itemBuilder(products[index]),
        ),
      ),
    );
  }
}
