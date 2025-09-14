import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_care/animation/fadeAnimation.dart';
import 'package:pet_care/consts/firebase_consts.dart';
import 'package:pet_care/screen/login_register_screen/ForgetScreen.dart';
import 'package:pet_care/screen/shelterDashboard/shelterScreen.dart';
import 'package:pet_care/screen/petOwnerDashboard/homeScreen/homeNav.dart';
import 'package:pet_care/screen/vetDashboard/vetScreen.dart';
import 'package:pet_care/screen/login_register_screen/registerScreen.dart';
import 'package:pet_care/screen/widgets/custom_form.dart';
import 'package:pet_care/services/authServices/authentication.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _FancyLoginScreenState();
}

class _FancyLoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Authentication _authService = Authentication();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> signInUser() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    setState(() => isLoading = true);

    await _authService
        .signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    )
        .then((value) async {
      if (value != null) {
        String userId = value.user!.uid;
        DocumentSnapshot userDoc =
            await firestore.collection(userCollection).doc(userId).get();

        if (userDoc.exists) {
          String role = userDoc['role'];

          switch (role) {
            case "pet":
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Home()));
              break;
            case "shelter":
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const ShelterScreen()));
              break;
            case "vet":
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const VetScreen()));
              break;
            default:
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const Home()));
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Successful")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Failed")),
        );
      }
    });

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Background Image Animation
            Container(
              height: 400,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 0,
                    height: 400,
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
                    height: 300,
                    width: width + 15,
                    child: FadeAnimation(
                      1,
                      Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/bg1.png' ''),
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            // Login Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeAnimation(
                    1.5,
                    const Text(
                      "Login",
                      style: TextStyle(
                          color: Color.fromRGBO(49, 39, 79, 1),
                          fontWeight: FontWeight.bold,
                          fontSize: 30),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Email + Password Fields
                  FadeAnimation(
                    1.7,
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(196, 135, 198, .3),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          )
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          CustomTextField(
                              controller: _emailController,
                              hint: "Email",
                              keyboardType: TextInputType.emailAddress),
                          CustomTextField(
                              controller: _passwordController,
                              hint: "Password",
                              keyboardType: TextInputType.visiblePassword,
                              obscure: true),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Forgot Password
                  FadeAnimation(
                    1.7,
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ForgetScreen()),
                          );
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                              color: Color.fromRGBO(196, 135, 198, 1)),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Login Button
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
                                color: Colors.white)
                            : TextButton(
                                onPressed: signInUser,
                                child: const Text(
                                  "Login",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Sign Up Link
                  FadeAnimation(
                    2,
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          "Don't have an account?",
                          style:
                              TextStyle(color: Color.fromRGBO(49, 39, 79, .6)),
                        ),
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
}
