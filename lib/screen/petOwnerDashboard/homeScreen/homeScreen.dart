import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_care/consts/firebase_consts.dart';
import 'package:pet_care/screen/petOwnerDashboard/homeScreen/components/bookAppointment.dart';
import 'package:pet_care/screen/petOwnerDashboard/homeScreen/petDetailsScreen.dart';
import 'package:pet_care/screen/petOwnerDashboard/homeScreen/components/blogDetails.dart';
import 'package:pet_care/screen/petOwnerDashboard/homeScreen/view_all_screen.dart';
import 'package:pet_care/screen/petOwnerDashboard/storeScreen/components/item_details.dart';

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

  bool _isLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
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

  void _bookAppointment(Map<String, dynamic> vet) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookAppointmentScreen(vet: vet)),
    );
  }

  Widget _buildAppBar() {
    final primaryColor = const Color.fromRGBO(49, 39, 79, 1);

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
                  icon: Icon(Icons.close, color: primaryColor),
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
                const SizedBox(width: 8),
                const Text(
                  "PetCare",
                  style: TextStyle(
                    color: Color.fromRGBO(49, 39, 79, 1),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
      centerTitle: false,
      leading: _isSearching
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: primaryColor),
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
                icon: Icon(Icons.search, color: primaryColor),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeroSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return SliverToBoxAdapter(
      child: Container(
        height: isSmallScreen ? 180 : 200,
        margin: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : 20,
            vertical: isSmallScreen ? 12 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(49, 39, 79, 1),
              Color.fromRGBO(196, 135, 198, 1),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
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
              child: Image.asset(
                'assets/images/pet123.png',
                height: isSmallScreen ? 100 : 140,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: isSmallScreen ? 16 : 24, top: isSmallScreen ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Find Your Perfect Pet",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 18 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Adopt a loving companion today",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Chip(
                    backgroundColor: Colors.white,
                    label: Text(
                      "Explore Now",
                      style: TextStyle(
                        color: const Color.fromRGBO(49, 39, 79, 1),
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 12 : 14,
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

  Widget sectionHeading(
    String title,
    List<Map<String, dynamic>> items,
    Widget Function(Map<String, dynamic>) itemBuilder,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 20,
          vertical: isSmallScreen ? 12 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF333333),
            ),
          ),
          TextButton(
            onPressed: () {
              if (items.isEmpty) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ViewAllScreen(
                    title: title,
                    items: items,
                    itemBuilder: itemBuilder,
                  ),
                ),
              );
            },
            child: const Text(
              "View All",
              style: TextStyle(
                color: Color.fromRGBO(49, 39, 79, 1),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _animalCard(Map<String, dynamic> animal) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      width: isSmallScreen ? 220 : 260,
      margin: EdgeInsets.only(right: isSmallScreen ? 12 : 16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _imageBuilder(
              animal["animal_image"], isSmallScreen ? 150 : 180, Icons.pets),
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(animal["animal_name"] ?? "Unknown",
                    style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(animal["breed"] ?? "Mixed Breed",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: isSmallScreen ? 12 : 14,
                    )),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: isSmallScreen ? 12 : 14,
                        color: Colors.deepOrange),
                    const SizedBox(width: 4),
                    Text(animal["location"] ?? "Unknown location",
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: isSmallScreen ? 10 : 12)),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                if (!_isLoggedIn()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please login to adopt an animal"),
                      backgroundColor: Color.fromRGBO(49, 39, 79, 1),
                    ),
                  );
                  return;
                }
                _navigateToPetDetails(animal);
              },
              icon: const Icon(Icons.favorite_border, size: 16),
              label: Text("Adopt Now",
                  style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
              style: _buttonStyle(),
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
        ],
      ),
    );
  }

  Widget _blogCard(Map<String, dynamic> blog, String blogId) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return GestureDetector(
      onTap: () => _navigateToBlogDetail(blog, blogId),
      child: Container(
        width: isSmallScreen ? 200 : 240,
        margin: EdgeInsets.only(right: isSmallScreen ? 12 : 16),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _imageBuilder(
                blog["image"], isSmallScreen ? 120 : 140, Icons.article),
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (blog["category"] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(49, 39, 79, 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        blog["category"].toString().toUpperCase(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 8 : 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  Text(blog["title"] ?? "Untitled Blog",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 13 : 15,
                          height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: isSmallScreen ? 10 : 12,
                          color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(blog["date"] ?? "Unknown date",
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isSmallScreen ? 9 : 11)),
                      const SizedBox(width: 8),
                      Icon(Icons.person,
                          size: isSmallScreen ? 10 : 12,
                          color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(blog["author"] ?? "Unknown author",
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isSmallScreen ? 9 : 11)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                      blog["excerpt"] ??
                          "Read this interesting blog post about pet care...",
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: isSmallScreen ? 10 : 12,
                          height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _navigateToBlogDetail(blog, blogId),
                      style: _buttonStyle(),
                      child: Text("Read More",
                          style: TextStyle(
                              fontSize: isSmallScreen ? 11 : 13,
                              fontWeight: FontWeight.w600)),
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

  Widget _productCard(Map<String, dynamic> product) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      width: isSmallScreen ? 190 : 220,
      margin: EdgeInsets.only(right: isSmallScreen ? 12 : 16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _imageBuilder(product["p_image"], isSmallScreen ? 140 : 160,
              Icons.shopping_bag),
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product["p_name"] ?? "Unnamed Product",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 14 : 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(product["p_category"] ?? "General",
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isSmallScreen ? 11 : 13)),
                const SizedBox(height: 6),
                Text("\$${product["p_price"] ?? "0"}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                        fontSize: isSmallScreen ? 13 : 15)),
              ],
            ),
          ),
          const Spacer(),
          Center(
            child: ElevatedButton(
              onPressed: () {
                if (!_isLoggedIn()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please login to buy Product"),
                      backgroundColor: Color.fromRGBO(49, 39, 79, 1),
                    ),
                  );
                  return;
                }
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ItemDetails(
                            title: product["p_name"], data: product)));
              },
              style: _buttonStyle(),
              child: Text("Buy Product",
                  style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
        ],
      ),
    );
  }

  Widget _vetCard(Map<String, dynamic> vet) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      width: isSmallScreen ? 190 : 220,
      margin: EdgeInsets.only(right: isSmallScreen ? 12 : 16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _imageBuilder(
              vet["photoUrl"], isSmallScreen ? 120 : 140, Icons.person),
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vet["name"] ?? "Unnamed Vet",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 14 : 16)),
                const SizedBox(height: 4),
                Text(vet["speciality"] ?? "Veterinarian",
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isSmallScreen ? 11 : 13)),
                const SizedBox(height: 8),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_isLoggedIn()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please login to book appointment"),
                            backgroundColor: Color.fromRGBO(49, 39, 79, 1),
                          ),
                        );
                        return;
                      }
                      _bookAppointment(vet);
                    },
                    style: _buttonStyle(),
                    child: Text("Book Appointment",
                        style: TextStyle(fontSize: isSmallScreen ? 11 : 13)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3)),
        ],
      );

  Widget _imageBuilder(
      String? imageData, double height, IconData fallbackIcon) {
    if (imageData == null || imageData.isEmpty) {
      return _fallbackWidget(height, fallbackIcon);
    }

    if (imageData.startsWith('data')) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Image.network(
          imageData,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _fallbackWidget(height, fallbackIcon),
        ),
      );
    }

    try {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Image.memory(
          base64Decode(imageData),
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _fallbackWidget(height, fallbackIcon),
        ),
      );
    } catch (e) {
      // If decoding fails, show fallback
      return _fallbackWidget(height, fallbackIcon);
    }
  }

  Widget _fallbackWidget(double height, IconData fallbackIcon) {
    return Container(
      height: height,
      width: double.infinity,
      color: Colors.grey[100],
      child: Center(
        child: Icon(fallbackIcon, size: 40, color: Colors.grey[400]),
      ),
    );
  }

  ButtonStyle _buttonStyle() => ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(49, 39, 79, 1),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            _buildHeroSection(),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .where("role", isEqualTo: "vet")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const SliverToBoxAdapter(child: SizedBox());
                final vets = snapshot.data!.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList();
                return SliverToBoxAdapter(
                  child: Column(
                    children: [
                      sectionHeading("Veterinarians", vets, _vetCard),
                      vets.isEmpty ? const SizedBox() : vetsCarousel(vets),
                    ],
                  ),
                );
              },
            ),

            SliverToBoxAdapter(
                child: SizedBox(height: isSmallScreen ? 16 : 24)),

            // ------------------- Adoption -------------------
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(animalCollection)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const SliverToBoxAdapter(child: SizedBox());
                final animals = snapshot.data!.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList();
                return SliverToBoxAdapter(
                  child: Column(
                    children: [
                      sectionHeading("Adoption", animals, _animalCard),
                      animals.isEmpty
                          ? const SizedBox()
                          : animalCarousel(animals),
                    ],
                  ),
                );
              },
            ),

            SliverToBoxAdapter(
                child: SizedBox(height: isSmallScreen ? 16 : 24)),

            // ------------------- Products -------------------
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection("products").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const SliverToBoxAdapter(child: SizedBox());
                final products = snapshot.data!.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList();
                return SliverToBoxAdapter(
                  child: Column(
                    children: [
                      sectionHeading("Pet Products", products, _productCard),
                      products.isEmpty
                          ? const SizedBox()
                          : productsCarousel(products),
                    ],
                  ),
                );
              },
            ),

            SliverToBoxAdapter(
                child: SizedBox(height: isSmallScreen ? 16 : 24)),

            // ------------------- Blogs -------------------
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection("blogs").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const SliverToBoxAdapter(child: SizedBox());
                final blogs = snapshot.data!.docs
                    .map((doc) => {
                          'id': doc.id,
                          'data': doc.data() as Map<String, dynamic>
                        })
                    .toList();
                return SliverToBoxAdapter(
                  child: Column(
                    children: [
                      sectionHeading("Pet Care Blogs", blogs,
                          (item) => _blogCard(item['data'], item['id'])),
                      blogs.isEmpty ? const SizedBox() : blogsCarousel(blogs),
                    ],
                  ),
                );
              },
            ),

            SliverToBoxAdapter(
                child: SizedBox(height: isSmallScreen ? 16 : 24)),
          ],
        ),
      ),
    );
  }

  Widget vetsCarousel(List<Map<String, dynamic>> vets) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return SizedBox(
      height: isSmallScreen ? 260 : 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
        itemCount: vets.length,
        itemBuilder: (context, index) => _vetCard(vets[index]),
      ),
    );
  }

  Widget animalCarousel(List<Map<String, dynamic>> animals) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return SizedBox(
      height: isSmallScreen ? 320 : 360,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
        itemCount: animals.length,
        itemBuilder: (context, index) => _animalCard(animals[index]),
      ),
    );
  }

  Widget productsCarousel(List<Map<String, dynamic>> products) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return SizedBox(
      height: isSmallScreen ? 320 : 360,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
        itemCount: products.length,
        itemBuilder: (context, index) => _productCard(products[index]),
      ),
    );
  }

  Widget blogsCarousel(List<Map<String, dynamic>> blogs) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return SizedBox(
      height: isSmallScreen ? 320 : 360,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
        itemCount: blogs.length,
        itemBuilder: (context, index) =>
            _blogCard(blogs[index]['data'], blogs[index]['id']),
      ),
    );
  }
}
