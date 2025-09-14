import 'package:flutter/material.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  static const BlogList = [
    'assets/images/poster1.jpg',
    'assets/images/poster2.jpg',
    'assets/images/poster3.jpg',
    'assets/images/poster4.jpg',
  ];

  Widget _buildBlogCard({
    required String text,
    required String imagePath,
    bool imageLeft = true,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              if (imageLeft)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    width: 100,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              if (!imageLeft) const SizedBox(width: 12),
              if (!imageLeft)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    width: 100,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          ),
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
        title: const Text(
          "Blogs",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Banner image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/poster1.jpg',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Welcome to Pet-Care Blogs 🐾',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Blog cards
            _buildBlogCard(
              text:
                  'We are a passionate team of pet lovers dedicated to bringing you helpful guides, care tips, and the latest trends in pet wellness.',
              imagePath: 'assets/images/fdog.jpg',
              imageLeft: true,
            ),
            _buildBlogCard(
              text:
                  'From nutrition advice to grooming hacks, our blogs cover everything you need to keep your furry friends happy and healthy.',
              imagePath: 'assets/images/fdog1.jpg',
              imageLeft: false,
            ),
            _buildBlogCard(
              text:
                  'Join our community and explore inspiring pet stories, expert care recommendations, and more.',
              imagePath: 'assets/images/fdog2.jpg',
              imageLeft: true,
            ),
            _buildBlogCard(
              text:
                  'We are constantly updating our content so that you always get the freshest tips for your pets.',
              imagePath: 'assets/images/fcdog3.jfif',
              imageLeft: false,
            ),
            _buildBlogCard(
              text:
                  'Stay tuned for new articles, exciting pet facts, and useful information for every pet parent.',
              imagePath: 'assets/images/fcdog4.jfif',
              imageLeft: true,
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
