import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_care/Animation/FadeAnimation.dart';
import 'package:pet_care/consts/firebase_consts.dart';
import 'package:pet_care/screen/shelterDashboard/shelterScreen.dart';
import 'package:pet_care/screen/login_register_screen/loginScreen.dart';
import 'package:pet_care/screen/petOwnerDashboard/homeScreen/homeNav.dart';
import 'package:pet_care/screen/vetDashboard/vetScreen.dart';
import 'package:pet_care/screen/widgets/custom_form.dart';
import 'package:pet_care/services/authServices/authentication.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  String selectedRole = "pet";
  bool isLoading = false;

  final Authentication authentication = Authentication();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 300,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      top: 0,
                      height: 200,
                      width: width,
                      child: FadeAnimation(
                        1,
                        Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/background.png'),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 45,
                      height: 400,
                      width: width + 15,
                      child: FadeAnimation(
                        1,
                        Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/bg1.png'),
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    FadeAnimation(
                      1.5,
                      const Text(
                        "Register",
                        style: TextStyle(
                          color: Color.fromRGBO(49, 39, 79, 1),
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeAnimation(
                      1.7,
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(196, 135, 198, .3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            CustomTextField(
                              controller: nameController,
                              hint: "Name",
                            ),
                            CustomTextField(
                              controller: emailController,
                              hint: "Email",
                              keyboardType: TextInputType.emailAddress,
                            ),
                            CustomTextField(
                              controller: phoneController,
                              hint: "Contact No.",
                              keyboardType: TextInputType.phone,
                            ),
                            CustomTextField(
                              controller: addressController,
                              hint: "Address",
                            ),
                            CustomTextField(
                              controller: passwordController,
                              hint: "Password",
                              obscure: true,
                            ),
                            FadeAnimation(
                              1.8,
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(color: Colors.grey)),
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: selectedRole,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Role',
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                  items: ["vet", "shelter", "pet"].map((role) {
                                    return DropdownMenuItem(
                                      value: role,
                                      child: Text(role),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedRole = newValue!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeAnimation(
                      1.9,
                      Container(
                        height: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 60),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: const Color.fromRGBO(49, 39, 79, 1),
                        ),
                        child: Center(
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : TextButton(
                                  onPressed: signUpUser,
                                  child: const Text(
                                    "Sign Up",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeAnimation(
                      2,
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Already have an account? Login",
                            style: TextStyle(
                              color: Color.fromRGBO(49, 39, 79, .6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void signUpUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          isLoading = true;
        });

        UserCredential? userCredential = await authentication.signUp(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        if (userCredential != null) {
          await authentication.storeUserData(
            name: nameController.text,
            email: emailController.text,
            phone: phoneController.text,
            address: addressController.text,
            role: selectedRole,
          );
          setState(() {
            currentUser = userCredential.user;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signup Successful')),
          );

          Widget switchRoleScreeen;

          switch (selectedRole) {
            case "vet":
              switchRoleScreeen = const VetScreen();
              break;
            case "shelter":
              switchRoleScreeen = const ShelterScreen();
              break;
            default:
              switchRoleScreeen = const Home();
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => switchRoleScreeen),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "This email is already registered. Please login instead."),
              backgroundColor: Colors.red,
            ),
          );
        } else if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text("Password is too weak. Please use a stronger password."),
              backgroundColor: Colors.red,
            ),
          );
        } else if (e.code == 'invalid-email') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid email address."),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Signup Failed: ${e.message}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Unexpected error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
