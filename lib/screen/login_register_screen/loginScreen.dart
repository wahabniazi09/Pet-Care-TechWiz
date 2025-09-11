import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_care/consts/consts.dart';
import 'package:pet_care/screen/petOwnerDashboard/petHome/petNav.dart';
import 'package:pet_care/screen/shelterDashboard/shelterScreen.dart';
import 'package:pet_care/screen/user/homeScreen/homeNav.dart';
import 'package:pet_care/screen/login_register_screen/ForgetScreen.dart';
import 'package:pet_care/screen/login_register_screen/registerScreen.dart';
import 'package:pet_care/screen/vetDashboard/vetScreen.dart';
import 'package:pet_care/screen/widgets/custom_form.dart';
import 'package:pet_care/screen/widgets/ownButton.dart';
import 'package:pet_care/services/authServices/authentication.dart';
import 'package:pet_care/services/validationServices/validation_services.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isObscure = true;
  bool isLoding = false;
  final Authentication authentication = Authentication();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Home()));
            },
          )),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Welcome Back!",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Log in to your account to continue",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 40),
                Column(
                  children: [
                    CustomTextField(
                        validator: validateEmail,
                        hint: 'Enter Your Email',
                        label: 'Email',
                        controller: emailController,
                        ispass: false),
                    const SizedBox(height: 10),
                    CustomTextField(
                        validator: validatePassword,
                        hint: 'Enter Your Password',
                        label: 'Password',
                        ispass: true,
                        controller: passwordController),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ForgetScreen()));
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: isLoding
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : Ownbutton(
                              title: 'Login',
                              onTap: signInUser,
                              width: MediaQuery.of(context).size.width,
                            ),
                    ),
                    const SizedBox(height: 10),
                    // Forgot Password Button
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const RegisterScreen()));
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void signInUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      isLoding = true;
    });
    await authentication
        .signIn(email: emailController.text, password: passwordController.text)
        .then((value) async {
      if (value != null) {
        String userId = value.user!.uid;
        DocumentSnapshot userDoc =
            await firestore.collection(userCollection).doc(userId).get();
        if (userDoc.exists) {
          String role = userDoc['role'];
          setState(() {
            currentUser = value.user;
          });
          switch (role) {
            case "pet":
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PetNav()),
              );
              break;
            case "shelter":
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ShelterScreen()),
              );
              break;
            case "vet":
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const VetScreen()),
              );
              break;
            default:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
              );
          }
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Login Successful')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Login Failed')));
      }
    });
    setState(() {
      isLoding = false;
    });
  }
}
