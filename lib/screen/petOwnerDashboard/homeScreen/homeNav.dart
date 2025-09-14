import 'package:flutter/material.dart';
import 'package:pet_care/consts/images.dart';
import 'package:pet_care/consts/theme_constant.dart';
import 'package:pet_care/screen/petOwnerDashboard/blogScreen/blogScreen.dart';
import 'package:pet_care/screen/petOwnerDashboard/storeScreen/storeScreen.dart';
import 'package:pet_care/screen/petOwnerDashboard/ProfileScreen/profileScreen.dart';
import 'package:pet_care/screen/petOwnerDashboard/homeScreen/homeScreen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentNavIndex = 0;

  final List<BottomNavigationBarItem> navListItem = [
    BottomNavigationBarItem(
      icon: Image.asset(icHome, width: 24, color: Colors.grey[600]),
      activeIcon: Image.asset(icHome, width: 24, color: AppTheme.primaryColor),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Image.asset(icCategories, width: 24, color: Colors.grey[600]),
      activeIcon: Image.asset(icCategories, width: 24, color: AppTheme.primaryColor),
      label: 'Store',
    ),
    BottomNavigationBarItem(
      icon: Image.asset(icCart, width: 24, color: Colors.grey[600]),
      activeIcon: Image.asset(icCart, width: 24, color: AppTheme.primaryColor),
      label: 'Blogs',
    ),
    BottomNavigationBarItem(
      icon: Image.asset(icProfile, width: 24, color: Colors.grey[600]),
      activeIcon: Image.asset(icProfile, width: 24, color: AppTheme.primaryColor),
      label: 'Profile',
    ),
  ];

  final List<Widget> navBody = [
    const HomeScreen(),
    const StoreScreen(),
    const BlogScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return WillPopScope(
      onWillPop: () async {
        if (currentNavIndex != 0) {
          setState(() {
            currentNavIndex = 0;
          });
          return false;
        } else {
          return false;
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(child: navBody.elementAt(currentNavIndex)),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: currentNavIndex,
            items: navListItem,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: Colors.grey[600],
            selectedLabelStyle: TextStyle(
              fontSize: isSmallScreen ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: isSmallScreen ? 10 : 12,
            ),
            iconSize: isSmallScreen ? 22 : 24,
            elevation: 8,
            onTap: (value) {
              setState(() {
                currentNavIndex = value;
              });
            },
          ),
        ),
      ),
    );
  }
}