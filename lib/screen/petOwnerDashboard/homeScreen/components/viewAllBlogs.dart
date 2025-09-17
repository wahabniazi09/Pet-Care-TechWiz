import 'package:flutter/material.dart';

class ViewAllBlogs extends StatelessWidget {
  final List<Map<String, dynamic>> blogs;
  final Widget Function(Map<String, dynamic>, String) itemBuilder;

  const ViewAllBlogs(
      {super.key, required this.blogs, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 1 : 2; // Blogs are usually wide

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Blogs"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: blogs.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            final blog = blogs[index];
            return itemBuilder(blog['data'], blog['id']);
          },
        ),
      ),
    );
  }
}
