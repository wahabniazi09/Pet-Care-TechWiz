import 'package:flutter/material.dart';
import 'package:pet_care/consts/colors.dart';

class ViewAllScreen extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final Widget Function(Map<String, dynamic> item) itemBuilder;

  const ViewAllScreen({
    super.key,
    required this.title,
    required this.items,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final crossAxisCount = isSmallScreen ? 2 : 3;
    final spacing = isSmallScreen ? 12.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color.fromRGBO(49, 39, 79, 1),
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: whiteColor),
      ),
      body: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: GridView.builder(
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: isSmallScreen ? 0.7 : 0.8,
          ),
          itemBuilder: (context, index) => itemBuilder(items[index]),
        ),
      ),
    );
  }
}
