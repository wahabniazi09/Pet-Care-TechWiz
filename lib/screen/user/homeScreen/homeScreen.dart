import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_care/consts/firebase_consts.dart';
import 'package:pet_care/screen/user/homeScreen/petDetailsScreen.dart';
import 'package:pet_care/screen/user/homeScreen/components/blogDetails.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToPetDetails(Map<String, dynamic> animal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetDetailsScreen(animal: animal),
      ),
    );
  }

  void _navigateToBlogDetail(Map<String, dynamic> blog, String blogId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlogDetailScreen(blog: blog, blogId: blogId),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: _isSearching ? 4 : 0,
      pinned: true,
      floating: true,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Search pets, products, blogs...",
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(Icons.close,
                      color: Color.fromARGB(255, 84, 37, 165)),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                    });
                  },
                ),
              ),
              style: const TextStyle(fontSize: 16),
              onSubmitted: (value) {
                print("Searching for: $value");
              },
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/pet_logo.png", height: 40),
                Center(
                  child: const Text(
                    "PetCare",
                    style: TextStyle(
                      color: Color.fromARGB(255, 84, 37, 165),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
      centerTitle: false,
      leading: _isSearching
          ? IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: Color.fromARGB(255, 84, 37, 165)),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                });
              },
            )
          : null,
      actions: [
        if (!_isSearching)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.grey[100],
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
                icon: const Icon(Icons.search,
                    color: Color.fromARGB(255, 84, 37, 165)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return SliverToBoxAdapter(
      child: Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A89CC), Color(0xFF4A69BB)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              bottom: 0,
              child: Image.asset('assets/images/1_img.png', height: 140),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 24, top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Find Your Perfect Pet",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Adopt a loving companion today",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 16),
                  Chip(
                    backgroundColor: Colors.white,
                    label: Text(
                      "Explore Now",
                      style: TextStyle(
                        color: Color.fromARGB(255, 84, 37, 165),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionHeading(String title, VoidCallback onViewAll) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF333333),
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: const Text(
                "View All",
                style: TextStyle(
                  color: Color.fromARGB(255, 84, 37, 165),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

  // Adoption Carousel
  Widget animalCarousel() => _carouselBuilder(
        collection: animalCollection,
        emptyIcon: Icons.pets,
        emptyText: "No animals available",
        cardBuilder: (item) => _animalCard(item),
      );

  // Blogs Carousel
  Widget blogsCarousel() => _carouselBuilder(
        collection: "blogs",
        emptyIcon: Icons.article,
        emptyText: "No blogs available",
        cardBuilder: (item) => _blogCard(item['data'], item['id']),
        customMap: (doc) =>
            {'id': doc.id, 'data': doc.data() as Map<String, dynamic>},
      );

  // Products Carousel
  Widget productsCarousel() => _carouselBuilder(
        collection: "products",
        emptyIcon: Icons.shopping_bag,
        emptyText: "No products available",
        cardBuilder: (item) => _productCard(item),
      );

  Widget _carouselBuilder({
    required String collection,
    required IconData emptyIcon,
    required String emptyText,
    required Widget Function(dynamic item) cardBuilder,
    dynamic Function(QueryDocumentSnapshot)? customMap,
  }) {
    return SizedBox(
      height: 360,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(collection).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromARGB(255, 84, 37, 165)),
              ),
            );
          }

          final items = snapshot.data!.docs
              .map((doc) => customMap != null
                  ? customMap(doc)
                  : doc.data() as Map<String, dynamic>)
              .toList();

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(emptyIcon, size: 50, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(emptyText, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) => cardBuilder(items[index]),
          );
        },
      ),
    );
  }

  // 🔹 Animal Card
  Widget _animalCard(Map<String, dynamic> animal) => Container(
        width: 260,
        margin: const EdgeInsets.only(right: 16),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _imageBuilder(animal["animal_image"], 180, Icons.pets),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(animal["animal_name"] ?? "Unknown",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(animal["breed"] ?? "Mixed Breed",
                      style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 14, color: Colors.deepOrange),
                      const SizedBox(width: 4),
                      Text(animal["location"] ?? "Unknown location",
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _navigateToPetDetails(animal),
                icon: const Icon(Icons.favorite_border),
                label: const Text("Adopt Now"),
                style: _buttonStyle(),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );

  Widget _blogCard(Map<String, dynamic> blog, String blogId) => GestureDetector(
        onTap: () => _navigateToBlogDetail(blog, blogId),
        child: Container(
          width: 240,
          margin: const EdgeInsets.only(right: 16),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _imageBuilder(blog["image"], 140, Icons.article),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (blog["category"] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 84, 37, 165),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          blog["category"].toString().toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    Text(blog["title"] ?? "Untitled Blog",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(blog["date"] ?? "Unknown date",
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 11)),
                        const SizedBox(width: 12),
                        Icon(Icons.person, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(blog["author"] ?? "Unknown author",
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                        blog["excerpt"] ??
                            "Read this interesting blog post about pet care...",
                        style: TextStyle(
                            color: Colors.grey[700], fontSize: 12, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _navigateToBlogDetail(blog, blogId),
                        style: _buttonStyle(),
                        child: const Text("Read More",
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _productCard(Map<String, dynamic> product) => Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _imageBuilder(product["p_image"], 160, Icons.shopping_bag),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product["p_name"] ?? "Unnamed Product",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(product["p_category"] ?? "General",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(height: 6),
                  Text("\$${product["p_price"] ?? "0"}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                          fontSize: 15)),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  print("Product tapped: ${product["p_name"]}");
                },
                style: _buttonStyle(),
                child: const Text("Buy Now"),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3)),
        ],
      );

  Widget _imageBuilder(
      String? base64Img, double height, IconData fallbackIcon) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: base64Img != null
          ? Image.memory(base64Decode(base64Img),
              height: height, width: double.infinity, fit: BoxFit.cover)
          : Container(
              height: height,
              width: double.infinity,
              color: Colors.grey[100],
              child: Center(
                  child: Icon(fallbackIcon, size: 40, color: Colors.grey[400])),
            ),
    );
  }

  ButtonStyle _buttonStyle() => ElevatedButton.styleFrom(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            _buildHeroSection(),
            SliverToBoxAdapter(child: sectionHeading("Adoption", () {})),
            SliverToBoxAdapter(child: animalCarousel()),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),
            SliverToBoxAdapter(child: sectionHeading("Pet Products", () {})),
            SliverToBoxAdapter(child: productsCarousel()),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),
            SliverToBoxAdapter(child: sectionHeading("Pet Care Blogs", () {})),
            SliverToBoxAdapter(child: blogsCarousel()),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
