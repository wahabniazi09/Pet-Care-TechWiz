import 'package:flutter/material.dart';
import 'package:pet_care/consts/images.dart';
import 'package:pet_care/screen/petOwnerDashboard/petAppoinments.dart/petAppoinment.dart';
import 'package:pet_care/screen/petOwnerDashboard/petBlogs.dart/petBlogs.dart';
import 'package:pet_care/screen/petOwnerDashboard/petHealthAndTips/petHealthAndTips.dart';
import 'package:pet_care/screen/petOwnerDashboard/petScreen.dart';
import 'package:pet_care/screen/petOwnerDashboard/petStore/petStore.dart';

class PetNav extends StatefulWidget {
  const PetNav({super.key});

  @override
  State<PetNav> createState() => _PetNavState();
}

class _PetNavState extends State<PetNav> {
  int currentNavIndex = 0;

  var navListItem = [
    BottomNavigationBarItem(
        icon: Image.asset(icHome, width: 25), label: 'Home'),
    BottomNavigationBarItem(
        icon: Image.asset(icAppointment, width: 25), label: 'Appoinments'),
    BottomNavigationBarItem(
        icon: Image.asset(ichealthtrack, width: 25), label: 'Health Track'),
    BottomNavigationBarItem(
        icon: Image.asset(icstore, width: 25), label: 'pet Store'),
    BottomNavigationBarItem(
        icon: Image.asset(icblogs, width: 25), label: 'blogs'),
  ];

  var navBody = [
    PetScreen(),
    Petappoinment(),
    Pethealthandtips(),
    Petstore(),
    Petblogs()
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
