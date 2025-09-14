
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.deepPurple[900],
        foregroundColor: whiteColor,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        actions: _currentIndex == 0 ? _buildAppBarActions() : null,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return "Shelter Animals";
      case 1:
        return "Products Store";
      case 2:
        return "Blog Posts";
      default:
        return "Shelter Dashboard";
    }
  }

  List<Widget> _buildAppBarActions() {
    return [
      IconButton(
        icon: const Icon(Icons.logout, size: 24),
        tooltip: 'Logout',
        onPressed: () => authentication.logOut(context),
      ),
    ];
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      backgroundColor: Colors.white,
      selectedItemColor: Colors.deepPurple[900],
      unselectedItemColor: Colors.grey[600],
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      elevation: 4,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.pets),
          label: 'Animals',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: 'Store',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.article),
          label: 'Blogs',
        ),
      ],
    );
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
          child: const Icon(Icons.add, color: whiteColor, size: 28),
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
          child: const Icon(Icons.add, color: whiteColor, size: 28),
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
          child: const Icon(Icons.add, color: whiteColor, size: 28),
        );
      default:
        return null;
    }
  }
}

// Animals Page (previously the main content)
class AnimalsPage extends StatelessWidget {
  const AnimalsPage({super.key});

  Future<void> _deleteAnimal(String animalId, BuildContext context) async {
    // Show confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this animal?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      try {
        await FirebaseFirestore.instance
            .collection('animals')
            .doc(animalId)
            .delete();

        // Close the loading dialog
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Animal deleted successfully"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        // Close the loading dialog
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error deleting animal: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestoreservices.getAnimalbyShelterOwner(currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pets,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  "No animals available yet",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  "Add your first animal by tapping the + button",
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        
        var animals = snapshot.data!.docs;
        
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: animals.length,
          itemBuilder: (context, index) {
            var animal = animals[index];
            var animalData = animal.data() as Map<String, dynamic>;
            
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.deepPurple[100],
                  ),
                  child: animalData['animal_image'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            base64Decode(animalData['animal_image']),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.pets,
                                size: 30,
                                color: Colors.deepPurple[900],
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.pets,
                          size: 30,
                          color: Colors.deepPurple[900],
                        ),
                ),
                title: Text(
                  animalData['animal_name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      "Age: ${animalData['animal_age']} • ${animalData['animal_gender']}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (animalData['adoption_status'] == 'Adopted')
                                ? Colors.red[100]
                                : Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            animalData['adoption_status'] ?? 'Available',
                            style: TextStyle(
                              color: (animalData['adoption_status'] == 'Adopted')
                                  ? Colors.red[800]
                                  : Colors.green[800],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[700]),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UpdateAnimal(
                            animalData: animalData,
                            animalId: animal.id,
                          ),
                        ),
                      );
                    } else if (value == 'delete') {
                      await _deleteAnimal(animal.id, context);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Text("Edit"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text("Delete"),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}