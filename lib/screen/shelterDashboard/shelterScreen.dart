import 'package:flutter/material.dart';
import 'package:pet_care/consts/colors.dart';
import 'package:pet_care/screen/shelterDashboard/addoptAnimal/addAnimal.dart';
import 'package:pet_care/screen/shelterDashboard/blogScreen/addblog.dart';
import 'package:pet_care/screen/shelterDashboard/blogScreen/blogHome.dart';
import 'package:pet_care/screen/shelterDashboard/shelterHome/shelterHomePage.dart';
import 'package:pet_care/screen/shelterDashboard/shelterProfile/shelterProfile.dart';
import 'package:pet_care/screen/shelterDashboard/shelterStore/addProduct.dart';
import 'package:pet_care/screen/shelterDashboard/shelterStore/shelterProductdetails.dart';
import 'package:pet_care/screen/shelterDashboard/shelterWidgets/animalPage.dart';
import 'package:pet_care/services/authServices/authentication.dart';

class ShelterScreen extends StatefulWidget {
  const ShelterScreen({super.key});

  @override
  State<ShelterScreen> createState() => _ShelterScreenState();
}

class _ShelterScreenState extends State<ShelterScreen> {
  final Authentication authentication = Authentication();
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const AnimalsPage(),
    ShelterProductDetails(),
    const BlogHome(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple[900],
        foregroundColor: whiteColor,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.deepPurple[900],
        selectedItemColor: whiteColor,
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Animals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add),
            label: 'Blogs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return "Home";
      case 1:
        return "Animals";
      case 2:
        return "Products";
      case 3:
        return "Blogs";
      case 4:
        return "Profile";
      default:
        return "Dashboard";
    }
  }

  Widget? _buildFloatingActionButton() {
    switch (_currentIndex) {
      case 1:
        return FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddAnimal()),
            );
          },
          backgroundColor: Colors.deepPurple[900],
          child: const Icon(Icons.add, color: whiteColor),
        );
      case 2:
        return FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddProduct()),
            );
          },
          backgroundColor: Colors.deepPurple[900],
          child: const Icon(Icons.add, color: whiteColor),
        );
      case 3:
        return FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddBlogScreen()),
            );
          },
          backgroundColor: Colors.deepPurple[900],
          child: const Icon(Icons.add, color: whiteColor),
        );
      default:
        return null;
    }
  }
}
