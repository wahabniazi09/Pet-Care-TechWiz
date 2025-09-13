import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_care/consts/consts.dart';
import 'package:pet_care/screen/user/homeScreen/homeNav.dart';

class Authentication {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<UserCredential?> signIn(
      {required String email, required String password}) async {
    UserCredential? userCredential;
    try {
      userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      e.toString();
    }
    return userCredential;
  }

  Future<UserCredential?> signUp(
      {required String email, required String password}) async {
    UserCredential? userCredential;
    try {
      userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      e.toString();
    }
    return userCredential;
  }

  storeUserData(
      {required String name,
      required String email,
      required String phone,
      required String address,
      required String role}) async {
    final user = auth.currentUser;
    if (user == null) return;
    DocumentReference store =
        firestore.collection(userCollection).doc(user.uid);
    DocumentSnapshot doc = await store.get();
    if (!doc.exists) {
      await store.set({
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'role': role,
        'id': user.uid,
      });
    }
  }

  Future<void> logOut(BuildContext context) async {
    await auth.signOut();
    currentUser == null;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Home()));
  }

  Future<void> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow; // Rethrow the error so that we can handle it in the UI
    }
  }
}
