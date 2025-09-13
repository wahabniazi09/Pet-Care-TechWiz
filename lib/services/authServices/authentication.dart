import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_care/consts/consts.dart';
import 'package:pet_care/screen/user/homeScreen/homeNav.dart';

class Authentication {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? get currentUser => auth.currentUser;


  Future<String?> getUserRole() async {
    if (currentUser == null) return null;
    final doc =
        await firestore.collection(userCollection).doc(currentUser!.uid).get();
    return doc.data()?['role'] as String?;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw e; 
    } catch (e) {
      rethrow;
    }
  }
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    try {
      return await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> storeUserData({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String role,
  }) async {
    final user = currentUser;
    if (user == null) return;

    final store = firestore.collection(userCollection).doc(user.uid);
    final doc = await store.get();

    if (!doc.exists) {
      await store.set({
        'id': user.uid,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> logOut(BuildContext context) async {
    try {
      await auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
        (route) => false,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      rethrow;
    }
  }
}
