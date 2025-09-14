import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_care/consts/firebase_consts.dart';
import 'package:pet_care/screen/petOwnerDashboard/homeScreen/components/bookAppointment.dart';
import 'package:pet_care/screen/petOwnerDashboard/homeScreen/petDetailsScreen.dart';
import 'package:pet_care/screen/petOwnerDashboard/homeScreen/components/blogDetails.dart';
import 'package:pet_care/screen/petOwnerDashboard/storeScreen/components/item_details.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// ------------------- ViewAllScreen -------------------

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
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    double spacing = 16;
    double itemWidth =
        (screenWidth - (crossAxisCount + 1) * spacing) / crossAxisCount;
    double itemHeight = 350;
    double aspectRatio = itemWidth / itemHeight;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (context, index) => itemBuilder(items[index]),
        ),
      ),
    );
  }
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

  // ------------------- AppBar -------------------
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

  // ------------------- Hero Section -------------------
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
              child: Image.asset('assets/images/pet123.png', height: 140),
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

  // ------------------- Section Heading with View All -------------------
  Widget sectionHeading(
    String title,
    List<Map<String, dynamic>> items,
    Widget Function(Map<String, dynamic>) itemBuilder,
  ) =>
      Padding(
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
                  color: Color.fromARGB(255, 84, 37, 165),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

  // ------------------- Cards -------------------
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
                onPressed: () {
                  if (!_isLoggedIn()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please login to adopt an animal")),
                    );
                    return;
                  }
                  _navigateToPetDetails(animal);
                },
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
                  if (!_isLoggedIn()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please login to buy Product")),
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
                child: const Text("Buy Product"),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );

  Widget _vetCard(Map<String, dynamic> vet) => Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _imageBuilder(vet["profilePic"], 140, Icons.person),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vet["name"] ?? "Unnamed Vet",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(vet["speciality"] ?? "Veterinarian",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(height: 8),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_isLoggedIn()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Please login to book appointment")),
                          );
                          return;
                        }
                        _bookAppointment(vet);
                      },
                      style: _buttonStyle(),
                      child: const Text("Book Appointment"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  // ------------------- Carousel Builder -------------------
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

  // ------------------- Helper Methods -------------------
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

            // ------------------- Veterinarians -------------------
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

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

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

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

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

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

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

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget vetsCarousel(List<Map<String, dynamic>> vets) => SizedBox(
        height: 300,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: vets.length,
          itemBuilder: (context, index) => _vetCard(vets[index]),
        ),
      );

  Widget animalCarousel(List<Map<String, dynamic>> animals) => SizedBox(
        height: 360,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: animals.length,
          itemBuilder: (context, index) => _animalCard(animals[index]),
        ),
      );

  Widget productsCarousel(List<Map<String, dynamic>> products) => SizedBox(
        height: 360,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: products.length,
          itemBuilder: (context, index) => _productCard(products[index]),
        ),
      );

  Widget blogsCarousel(List<Map<String, dynamic>> blogs) => SizedBox(
        height: 360,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: blogs.length,
          itemBuilder: (context, index) =>
              _blogCard(blogs[index]['data'], blogs[index]['id']),
        ),
      );
}
