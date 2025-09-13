import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_care/animation/fadeAnimation.dart';
import 'package:pet_care/consts/firebase_consts.dart';
import 'package:pet_care/screen/login_register_screen/ForgetScreen.dart';
import 'package:pet_care/screen/login_register_screen/registerScreen.dart';
import 'package:pet_care/screen/shelterDashboard/shelterScreen.dart';
import 'package:pet_care/screen/user/homeScreen/homeNav.dart';
import 'package:pet_care/screen/vetDashboard/vetScreen.dart';
import 'package:pet_care/screen/widgets/custom_form.dart';
import 'package:pet_care/screen/widgets/snackBar.dart';
import 'package:pet_care/services/authServices/authentication.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final Authentication _authService = Authentication();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

 Future<void> signInUser() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    AppNotifier.showSnack(context, message: "Please enter email and password", isError: true);
    return;
  }

  setState(() => isLoading = true);

  try {
    final userCredential = await _authService.signIn(
      email: email,
      password: password,
    );

    if (userCredential.user != null) {
      final uid = userCredential.user!.uid;
      final doc = await firestore.collection(userCollection).doc(uid).get();

      if (doc.exists) {
        final role = doc['role'] as String;

        Widget nextScreen;
        switch (role) {
          case "vet":
            nextScreen = const VetScreen();
            break;
          case "shelter":
            nextScreen = const ShelterScreen();
            break;
          default:
            nextScreen = const Home();
        }

        AppNotifier.showSnack(context, message: "Login Successful!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => nextScreen),
        );
      } else {
        AppNotifier.showSnack(context, message: "User data not found!", isError: true);
      }
    }
  } on FirebaseAuthException catch (e) {
    AppNotifier.handleAuthError(context, e);
  } catch (e) {
    AppNotifier.handleError(context, e);
  } finally {
    setState(() => isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Background
            SizedBox(
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
                            image: AssetImage('assets/images/bg1.png'),
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                    ),
                  )
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
                      "Login",
                      style: TextStyle(
                        color: Color.fromRGBO(49, 39, 79, 1),
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

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
                            keyboardType: TextInputType.emailAddress,
                          ),
                          CustomTextField(
                            controller: _passwordController,
                            hint: "Password",
                            obscure: true,
                            keyboardType: TextInputType.visiblePassword,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  FadeAnimation(
                    1.7,
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const ForgetScreen()),
                          );
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: Color.fromRGBO(196, 135, 198, 1)),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

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
                            ? const CircularProgressIndicator(color: Colors.white)
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

                  FadeAnimation(
                    2,
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          "Don't have an account?",
                          style: TextStyle(color: Color.fromRGBO(49, 39, 79, .6)),
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
