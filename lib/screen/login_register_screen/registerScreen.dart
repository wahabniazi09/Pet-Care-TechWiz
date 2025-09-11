import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_care/consts/firebase_consts.dart';
import 'package:pet_care/screen/petOwnerDashboard/petHome/petNav.dart';
import 'package:pet_care/screen/shelterDashboard/shelterScreen.dart';
import 'package:pet_care/screen/user/homeScreen/homeNav.dart';
import 'package:pet_care/screen/login_register_screen/loginScreen.dart';
import 'package:pet_care/screen/vetDashboard/vetScreen.dart';
import 'package:pet_care/screen/widgets/custom_form.dart';
import 'package:pet_care/screen/widgets/ownButton.dart';
import 'package:pet_care/services/authServices/authentication.dart';
import 'package:pet_care/services/validationServices/validation_services.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.black), // Change icon if needed
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const Home()));
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
                  "Sign Up to your account to continue",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 40),
                Column(
                  children: [
                    CustomTextField(
                      hint: 'Enter Name',
                      label: 'Name',
                      ispass: false,
                      controller: nameController,
                      validator: validateName,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      ispass: false,
                      hint: 'Enter Email',
                      label: 'Email',
                      controller: emailController,
                      validator: validateEmail,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      ispass: false,
                      hint: 'Enter Phone Number',
                      label: 'Phone Number',
                      controller: phoneController,
                      validator: validatePhoneNumber,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      ispass: false,
                      hint: 'Enter Address',
                      label: 'Address',
                      controller: addressController,
                      validator: validateAddress,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      ispass: true,
                      hint: 'Enter Password',
                      label: 'Password',
                      controller: passwordController,
                      validator: validatePassword,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField(
                      value: selectedRole,
                      decoration: const InputDecoration(
                          labelText: 'Role', border: OutlineInputBorder()),
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
                    const SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Ownbutton(
                              title: 'Sign Up',
                              width: MediaQuery.of(context).size.width,
                              onTap: signUpUser,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Loginscreen()));
                        },
                        child: const Text(
                          "Login",
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

  void signUpUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          isLoading = true;
        });

        UserCredential? userCredential = await authentication.signUp(
          email: emailController.text,
          password: passwordController.text,
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
              switchRoleScreeen = const PetNav();
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => switchRoleScreeen),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup Failed: ${e.toString()}')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
