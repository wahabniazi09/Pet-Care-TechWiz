import 'package:flutter/material.dart';
import 'package:pet_care/screen/login_register_screen/loginScreen.dart';
import 'package:pet_care/screen/login_register_screen/registerScreen.dart';
import 'package:pet_care/screen/widgets/ownButton.dart';

class Profilescreen extends StatelessWidget {
  const Profilescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Screen"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 40,
              child: Ownbutton(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                title: 'Login',
                width: MediaQuery.of(context).size.width - 20,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 40,
              child: Ownbutton(
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterScreen()));
                },
                title: 'Register',
                width: MediaQuery.of(context).size.width - 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
