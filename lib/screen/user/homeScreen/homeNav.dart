import 'package:flutter/material.dart';
import 'package:pet_care/consts/images.dart';
import 'package:pet_care/screen/user/CartScreen/cartScreen.dart';
import 'package:pet_care/screen/user/storeScreen/storeScreen.dart';
import 'package:pet_care/screen/user/ProfileScreen/profileScreen.dart';
import 'package:pet_care/screen/user/homeScreen/homeScreen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentNavIndex = 0;

  var navListItem = [
    BottomNavigationBarItem(
        icon: Image.asset(icHome, width: 25), label: 'Home'),
    BottomNavigationBarItem(
        icon: Image.asset(icCategories, width: 25), label: 'Store'),
    BottomNavigationBarItem(
        icon: Image.asset(icCart, width: 25), label: 'Blogs'),
    BottomNavigationBarItem(
        icon: Image.asset(icProfile, width: 25), label: 'Profile'),
  ];

  var navBody = [
    HomeScreen(),
    StoreScreen(),
    Cartscreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          body: Column(
            children: [
              Expanded(child: navBody.elementAt(currentNavIndex)),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentNavIndex,
            items: navListItem,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.red,
            onTap: (value) {
              setState(() {
                currentNavIndex = value;
              });
            },
          ),
        ),
        onWillPop: () async {
          if (currentNavIndex != 0) {
            setState(() {
              currentNavIndex = 0;
            });
            return false;
          } else {
            return false;
          }
        });
  }
}
