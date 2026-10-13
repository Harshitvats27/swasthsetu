import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class Seeder {
  static Future<void> seedDatabase() async {
    final firestore = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'default',
    );

    try {
      debugPrint('Fetching all doctors and hospitals...');
      // 1. Fetch existing doctors and hospitals
      final doctorsSnapshot = await firestore.collection('doctors').get();
      final hospitalsSnapshot = await firestore.collection('hospitals').get();

      if (doctorsSnapshot.docs.isEmpty) {
        debugPrint('No doctors found to link.');
        return;
      }
      
      if (hospitalsSnapshot.docs.isEmpty) {
        debugPrint('No hospitals found. Creating dummy hospitals...');
        // Create 1 Big Hospital, 1 Small Clinic just in case
        await firestore.collection('hospitals').doc('h_big_1').set({
          'name': 'Apollo Hospitals',
          'address': 'Apollo Hospitals, Jubilee Hills',
          'city': 'Hyderabad',
          'state': 'Telangana',
          'phone': '+91 40 2360 7777',
          'geoPoint': const GeoPoint(17.4165, 78.4069),
          'specialties': ['Cardiology', 'Neurology', 'Orthopedics'],
          'facilities': ['ICU', 'Emergency', 'Pharmacy'],
          'totalBeds': 350,
          'rating': 4.8,
          'reviewsCount': 1200,
          'isOpen24x7': true,
          'doctorIds': [],
        });
        
        await firestore.collection('hospitals').doc('h_small_1').set({
          'name': 'City Care Clinic',
          'address': 'Madhapur',
          'city': 'Hyderabad',
          'state': 'Telangana',
          'phone': '+91 9876543210',
          'geoPoint': const GeoPoint(17.4483, 78.3915),
          'specialties': ['General Physician', 'Pediatrics'],
          'facilities': ['Pharmacy'],
          'totalBeds': 10,
          'rating': 4.5,
          'reviewsCount': 120,
          'isOpen24x7': false,
          'doctorIds': [],
        });
      }

      // Re-fetch after potential creation
      final finalHospitalsSnapshot = await firestore.collection('hospitals').get();
      
      // Shuffle doctors so we don't pick the same ones in order
      final allDoctors = doctorsSnapshot.docs.toList();
      allDoctors.shuffle(Random());
      
      int doctorIndex = 0;

      for (var hospitalDoc in finalHospitalsSnapshot.docs) {
        final hospitalId = hospitalDoc.id;
        final hospitalData = hospitalDoc.data();
        final isBigHospital = (hospitalData['totalBeds'] ?? 0) > 50;
        
        // Randomly assign 5-8 doctors to big hospitals, 1-3 to small clinics
        final numDoctorsToAssign = isBigHospital ? Random().nextInt(4) + 5 : Random().nextInt(3) + 1;
        
        List<String> assignedDoctorIds = [];
        
        for (int i = 0; i < numDoctorsToAssign; i++) {
          if (doctorIndex >= allDoctors.length) {
            break; // Ran out of doctors
          }
          
          final docToAssign = allDoctors[doctorIndex];
          assignedDoctorIds.add(docToAssign.id);
          
          // Update doctor to point to this hospital
          await firestore.collection('doctors').doc(docToAssign.id).update({
            'hospitalId': hospitalId,
            'isHospital': isBigHospital,
            'clinicName': hospitalData['name'],
            'clinicGeoPoint': hospitalData['geoPoint'],
          });
          
          doctorIndex++;
        }
        
        // Update hospital to include these doctors
        await firestore.collection('hospitals').doc(hospitalId).update({
          'doctorIds': assignedDoctorIds,
        });
        
        debugPrint('Assigned ${assignedDoctorIds.length} doctors to hospital ${hospitalData['name']}');
      }
      
      debugPrint('Auto-linking complete!');
      
    } catch (e) {
      debugPrint('Error during auto-linking: $e');
    }
  }
}
