import 'package:flutter/material.dart';

class ViewAllVets extends StatelessWidget {
  final List<Map<String, dynamic>> vets;
  final Widget Function(Map<String, dynamic>) itemBuilder;

  const ViewAllVets({
    super.key,
    required this.vets,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final crossAxisCount = screenWidth < 600 ? 2 : 3;

    final childAspectRatio =
        (screenWidth / crossAxisCount) / (screenHeight * 0.35);

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Veterinarians"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: vets.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio, // ✅ dynamic ratio
          ),
          itemBuilder: (context, index) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    maxHeight: constraints.maxHeight,
                  ),
                  child: itemBuilder(vets[index]),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
