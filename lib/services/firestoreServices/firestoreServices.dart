import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_care/consts/firebase_consts.dart';

class Firestoreservices {
  static getpetByowner(uid) {
    return FirebaseFirestore.instance
        .collection(petCollection)
        .where("owner_id", isEqualTo: uid)
        .snapshots();
  }

  static deletepet(id) {
    return FirebaseFirestore.instance
        .collection(petCollection)
        .doc(id)
        .delete();
  }

  static getAnimalbyShelterOwner(uid) {
    return FirebaseFirestore.instance
        .collection(animalCollection)
        .where("shelter_id", isEqualTo: uid)
        .snapshots();
  }

  static getproductByshelter(uid) {
    return FirebaseFirestore.instance
        .collection(productCollection)
        .where("shelter_id", isEqualTo: uid)
        .snapshots();
  }
}
