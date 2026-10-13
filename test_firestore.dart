import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
void main() {
  FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'default');
}
