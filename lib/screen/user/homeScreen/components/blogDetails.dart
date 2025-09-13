import 'dart:convert';
import 'package:flutter/material.dart';

class BlogDetailScreen extends StatelessWidget {
  final Map<String, dynamic> blog;
  final String blogId;

  const BlogDetailScreen({super.key, required this.blog, required this.blogId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(blog["title"] ?? "Blog Detail"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blog Image
            if (blog["image"] != null)
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: MemoryImage(base64Decode(blog["image"])),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Category
            if (blog["category"] != null)
              Chip(
                label: Text(
                  blog["category"].toString().toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.deepOrange,
              ),
            const SizedBox(height: 16),

            // Title
            Text(
              blog["title"] ?? "Untitled Blog",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Date and Author
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 4),
                Text(blog["date"] ?? "Unknown date"),
                const SizedBox(width: 16),
                const Icon(Icons.person, size: 16),
                const SizedBox(width: 4),
                Text(blog["author"] ?? "Unknown author"),
              ],
            ),
            const SizedBox(height: 24),

            // Content
            Text(
              blog["content"] ?? "No content available",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
