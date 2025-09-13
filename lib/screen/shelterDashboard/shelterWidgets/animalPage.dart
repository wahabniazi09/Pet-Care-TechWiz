import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_care/consts/colors.dart';
import 'package:pet_care/consts/firebase_consts.dart';
import 'package:pet_care/screen/shelterDashboard/addoptAnimal/addAnimal.dart';
import 'package:pet_care/screen/shelterDashboard/addoptAnimal/updateAnimal.dart';
import 'package:pet_care/screen/shelterDashboard/blogScreen/addblog.dart';
import 'package:pet_care/screen/shelterDashboard/blogScreen/blogHome.dart';
import 'package:pet_care/screen/shelterDashboard/shelterStore/shelterProductdetails.dart';
import 'package:pet_care/services/authServices/authentication.dart';
import 'package:pet_care/services/firestoreServices/firestoreServices.dart';

class ShelterScreen extends StatefulWidget {
  const ShelterScreen({super.key});

  @override
  State<ShelterScreen> createState() => _ShelterScreenState();
}

class _ShelterScreenState extends State<ShelterScreen> {
  final Authentication authentication = Authentication();
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AnimalsPage(),
    const ShelterProductDetails(),
    const BlogHome(),
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
        actions: _currentIndex == 0 ? _buildAppBarActions() : null,
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
        items: const [
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
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return "Shelter Dashboard";
      case 1:
        return "Products";
      case 2:
        return "Blogs";
      default:
        return "Shelter Dashboard";
    }
  }

  List<Widget> _buildAppBarActions() {
    return [
      IconButton(
        icon: const Icon(Icons.logout),
        onPressed: () => authentication.logOut(context),
      ),
    ];
  }

  Widget? _buildFloatingActionButton() {
    switch (_currentIndex) {
      case 0:
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
      case 1:
        return FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ShelterProductDetails()),
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

// Animals Page (previously the main content)
class AnimalsPage extends StatelessWidget {
  const AnimalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestoreservices.getAnimalbyShelterOwner(currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No animals available for adoption yet.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          );
        }
        var animals = snapshot.data!.docs;
        return ListView.builder(
          itemCount: animals.length,
          itemBuilder: (context, index) {
            var animal = animals[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: animal['animal_image'] != null
                    ? CircleAvatar(
                        backgroundImage: MemoryImage(
                          const Base64Decoder().convert(animal['animal_image']),
                        ),
                      )
                    : const CircleAvatar(
                        child: Icon(Icons.pets),
                      ),
                title: Text(
                  animal['animal_name'] ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                    "Age: ${animal['animal_age']}, Gender: ${animal['animal_gender']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      animal['adoption_status'] ?? 'Available',
                      style: TextStyle(
                        color: (animal['adoption_status'] == 'Adopted')
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => UpdateAnimal(
                                      animalData:
                                          animal.data() as Map<String, dynamic>,
                                      animalId: animal.id)));
                        } else if (value == 'delete') {
                          // _deleteAnimal(animal.id);
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blue),
                                SizedBox(width: 8),
                                Text("Edit"),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text("Delete"),
                              ],
                            ),
                          ),
                        ];
                      },
                      icon: const Icon(Icons.more_vert),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
