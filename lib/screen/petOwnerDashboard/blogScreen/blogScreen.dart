import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:pet_care/consts/theme_constant.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  static const List<String> blogList = [
    'assets/images/poster1.jpg',
    'assets/images/poster2.jpg',
    'assets/images/poster3.jpg',
    'assets/images/poster4.jpg',
  ];

  Widget _buildBlogCard({
    required String text,
    required String imagePath,
    bool imageLeft = true,
    required BuildContext context,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // future detail screen navigation
        },
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
          child: isSmallScreen
              ? Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        imagePath,
                        width: double.infinity,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                )
              : Row(
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
                    SizedBox(width: isSmallScreen ? 8 : 12),
                    Expanded(
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    if (!imageLeft) SizedBox(width: isSmallScreen ? 8 : 12),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Blogs",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          children: [
            SizedBox(
              height: isSmallScreen ? 160 : 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Swiper(
                  itemCount: blogList.length,
                  autoplay: true,
                  pagination: const SwiperPagination(
                    builder: DotSwiperPaginationBuilder(
                      color: Colors.white54,
                      activeColor: Colors.white,
                      size: 8,
                      activeSize: 10,
                    ),
                  ),
                  itemBuilder: (context, index) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          blogList[index],
                          fit: BoxFit.cover,
                        ),
                        Container(
                          color: Colors.black.withOpacity(0.25),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
                            child: Text(
                              "Pet Blog ${index + 1}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black,
                                    blurRadius: 4,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: isSmallScreen ? 16 : 20),

            Text(
              'Welcome to Pet-Care Blogs 🐾',
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: isSmallScreen ? 16 : 20),

            // Blogs cards
            _buildBlogCard(
              text:
                  'We are a passionate team of pet lovers dedicated to bringing you helpful guides, care tips, and the latest trends in pet wellness.',
              imagePath: 'assets/images/fdog.jpg',
              imageLeft: true,
              context: context,
            ),
            _buildBlogCard(
              text:
                  'From nutrition advice to grooming hacks, our blogs cover everything you need to keep your furry friends happy and healthy.',
              imagePath: 'assets/images/fdog1.jpg',
              imageLeft: false,
              context: context,
            ),
            _buildBlogCard(
              text:
                  'Join our community and explore inspiring pet stories, expert care recommendations, and more.',
              imagePath: 'assets/images/fdog2.jpg',
              imageLeft: true,
              context: context,
            ),
            _buildBlogCard(
              text:
                  'We are constantly updating our content so that you always get the freshest tips for your pets.',
              imagePath: 'assets/images/fcdog3.jfif',
              imageLeft: false,
              context: context,
            ),
            _buildBlogCard(
              text:
                  'Stay tuned for new articles, exciting pet facts, and useful information for every pet parent.',
              imagePath: 'assets/images/fcdog4.jfif',
              imageLeft: true,
              context: context,
            ),
            SizedBox(height: isSmallScreen ? 60 : 80),
          ],
        ),
      ),
    );
  }
}