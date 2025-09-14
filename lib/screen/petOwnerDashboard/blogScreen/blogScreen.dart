import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  Stream<QuerySnapshot> getBlogs() {
    return FirebaseFirestore.instance
        .collection('blogs')
        .where('author', isEqualTo: 'shelter')
        .snapshots();
  }

  Widget _buildBlogCard(
      Map<String, dynamic> data, bool imageLeft, BuildContext context) {
    final title = data['title'] ?? 'No Title';
    final excerpt = data['excerpt'] ?? '';
    final content = data['content'] ?? '';
    final imageBase64 = data['image'] ?? '';
    final date = data['date'] ?? '';

    final imageWidget = imageBase64.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              base64Decode(imageBase64),
              width: 100,
              height: 150,
              fit: BoxFit.cover,
            ),
          )
        : Container(width: 100, height: 150, color: Colors.grey[300]);

    final textColumn = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(excerpt,
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(date,
              style:
                  const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlogDetailScreen(
                      title: title,
                      content: content,
                      imageBase64: imageBase64,
                      date: date,
                    ),
                  ),
                );
              },
              child: const Text("Read More",
                  style: TextStyle(color: Colors.deepPurple)),
            ),
          ),
        ],
      ),
    );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: imageLeft
              ? [imageWidget, const SizedBox(width: 12), textColumn]
              : [textColumn, const SizedBox(width: 12), imageWidget],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Blogs", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getBlogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No blogs found."));
          }

          final blogs = snapshot.data!.docs;
          bool imageLeft = true;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: blogs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final card = _buildBlogCard(data, imageLeft, context);
                imageLeft = !imageLeft; // alternate image position
                return card;
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

class BlogDetailScreen extends StatelessWidget {
  final String title;
  final String content;
  final String imageBase64;
  final String date;

  const BlogDetailScreen({
    super.key,
    required this.title,
    required this.content,
    required this.imageBase64,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = imageBase64.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              base64Decode(imageBase64),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          )
        : Container(
            width: double.infinity, height: 200, color: Colors.grey[300]);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Blog Detail"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageWidget,
            const SizedBox(height: 16),
            Text(title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(date,
                style:
                    const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
            const SizedBox(height: 16),
            Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
