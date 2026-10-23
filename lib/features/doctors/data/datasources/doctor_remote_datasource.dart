import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swasthsetu/features/doctors/data/models/doctor_model.dart';

class DoctorRemoteDataSource {
  final FirebaseFirestore firestore;

  DoctorRemoteDataSource({required this.firestore});

  Future<List<DoctorModel>> fetchDoctors() async {
    final snapshot = await firestore.collection('doctors').get();
    return snapshot.docs.map((doc) => DoctorModel.fromFirestore(doc)).toList();
  }

  Future<List<DoctorModel>> searchDoctors(String query) async {
    final allDoctors = await fetchDoctors();
    final lowerQuery = query.toLowerCase().trim();
    if (lowerQuery.isEmpty) return allDoctors;

    final queryStem = lowerQuery.replaceAll(
      RegExp(r'(ologist|ology|iatrician|iatrics|ist|y)$'),
      '',
    );

    return allDoctors.where((doc) {
      final nameMatches = doc.name.toLowerCase().contains(lowerQuery);
      final clinicMatches = doc.clinicName.toLowerCase().contains(lowerQuery) ||
          (queryStem.length >= 4 && doc.clinicName.toLowerCase().contains(queryStem));

      final specMatches = doc.specializations.any((spec) {
        final s = spec.toLowerCase();
        if (s.contains(lowerQuery) || lowerQuery.contains(s)) return true;
        if (queryStem.length >= 4) {
          final specStem = s.replaceAll(
            RegExp(r'(ologist|ology|iatrician|iatrics|ist|y)$'),
            '',
          );
          if (s.contains(queryStem) || specStem.contains(queryStem)) {
            return true;
          }
        }
        return false;
      });

      return nameMatches || clinicMatches || specMatches;
    }).toList();
  }

  /// Seeds 20 doctors to Firestore.
  ///
  /// Doctors with [isHospital]=true carry a [hospitalName] tag so the hospital
  /// seed script can later link them by name (since Firestore IDs are generated
  /// at runtime). Independent clinic doctors carry a [clinicGeoPoint].
  Future<void> seedDoctors() async {
    final batch = firestore.batch();
    final collection = firestore.collection('doctors');

    // ── Hospital-affiliated doctors ──────────────────────────────────────────
    // These doctors work inside one of the seeded hospitals.
    // hospitalId field is intentionally left empty here; it will be populated
    // when the hospital seeding resolves actual Firestore IDs.
    // We tag with 'hospitalName' so they can be linked.

    final List<Map<String, dynamic>> samples = [
      // ── Aadhar Health Institute doctors ─────────────────────────────────────
      {
        'name': 'Dr. Geeta Dabas',
        'specializations': ['Nephrology'],
        'qualifications': ['MD', 'DM (Nephrology)'],
        'languages': ['English', 'Hindi'],
        'experienceYears': 15,
        'consultationFee': 500,
        'clinicName': 'Aadhar Health Institute',
        'isHospital': true,
        'hospitalName': 'Aadhar Health Institute', // used for linking
        'rating': 4.8,
        'reviewsCount': 120,
        'profilePictureUrl': null,
        'availabilitySlots': ['09:00 AM', '10:00 AM', '11:00 AM'],
      },
      {
        'name': 'Dr. Neeraj Nagar',
        'specializations': ['Anaesthesiology', 'Pain Medicine'],
        'qualifications': ['MBBS', 'MD'],
        'languages': ['English', 'Hindi'],
        'experienceYears': 12,
        'consultationFee': 400,
        'clinicName': 'Aadhar Health Institute',
        'isHospital': true,
        'hospitalName': 'Aadhar Health Institute',
        'rating': 4.5,
        'reviewsCount': 85,
        'profilePictureUrl': null,
        'availabilitySlots': ['02:00 PM', '03:00 PM', '04:00 PM'],
      },
      {
        'name': 'Dr. Rameshwar',
        'specializations': ['Anaesthesiology'],
        'qualifications': ['MBBS', 'MD'],
        'languages': ['English'],
        'experienceYears': 10,
        'consultationFee': 400,
        'clinicName': 'Aadhar Health Institute',
        'isHospital': true,
        'hospitalName': 'Aadhar Health Institute',
        'rating': 4.2,
        'reviewsCount': 50,
        'profilePictureUrl': null,
        'availabilitySlots': ['10:00 AM', '12:00 PM'],
      },

      // ── Relief Hospital doctors ──────────────────────────────────────────────
      {
        'name': 'Dr. P. Bhusal',
        'specializations': ['Pain Medicine'],
        'qualifications': ['MBBS', 'MD'],
        'languages': ['English', 'Hindi'],
        'experienceYears': 14,
        'consultationFee': 450,
        'clinicName': 'Relief Hospital & Research Centre',
        'isHospital': true,
        'hospitalName': 'Relief Hospital & Research Centre',
        'rating': 4.6,
        'reviewsCount': 110,
        'profilePictureUrl': null,
        'availabilitySlots': ['01:00 PM', '03:00 PM'],
      },
      {
        'name': 'Dr. Vikram Singh',
        'specializations': ['Orthopedics'],
        'qualifications': ['MBBS', 'MS (Ortho)'],
        'languages': ['English', 'Hindi', 'Punjabi'],
        'experienceYears': 20,
        'consultationFee': 700,
        'clinicName': 'Bone & Joint Center',
        'isHospital': true,
        'hospitalName': 'Bone & Joint Center',
        'rating': 4.7,
        'reviewsCount': 150,
        'profilePictureUrl': null,
        'availabilitySlots': ['04:00 PM', '05:30 PM', '07:00 PM'],
      },
      {
        'name': 'Dr. Rahul Verma',
        'specializations': ['Pediatrics'],
        'qualifications': ['MBBS', 'MD (Pediatrics)'],
        'languages': ['English', 'Hindi'],
        'experienceYears': 11,
        'consultationFee': 400,
        'clinicName': 'Child Care Hospital',
        'isHospital': true,
        'hospitalName': 'Child Care Hospital',
        'rating': 4.8,
        'reviewsCount': 180,
        'profilePictureUrl': null,
        'availabilitySlots': ['08:00 AM', '09:00 AM', '10:00 AM'],
      },
      {
        'name': 'Dr. Kavita Desai',
        'specializations': ['Cardiology'],
        'qualifications': ['MBBS', 'MD', 'DM (Cardiology)'],
        'languages': ['English', 'Marathi'],
        'experienceYears': 22,
        'consultationFee': 800,
        'clinicName': 'Heart Institute',
        'isHospital': true,
        'hospitalName': 'Heart Institute',
        'rating': 4.9,
        'reviewsCount': 250,
        'profilePictureUrl': null,
        'availabilitySlots': ['10:00 AM', '12:00 PM', '02:00 PM'],
      },
      {
        'name': 'Dr. Sanjay Gupta',
        'specializations': ['Neurology'],
        'qualifications': ['MBBS', 'MD', 'DM (Neurology)'],
        'languages': ['English', 'Hindi'],
        'experienceYears': 16,
        'consultationFee': 750,
        'clinicName': 'Neuro Spine Hospital',
        'isHospital': true,
        'hospitalName': 'Neuro Spine Hospital',
        'rating': 4.7,
        'reviewsCount': 140,
        'profilePictureUrl': null,
        'availabilitySlots': ['02:00 PM', '04:00 PM', '06:00 PM'],
      },
      {
        'name': 'Dr. Manoj Tiwari',
        'specializations': ['Gastroenterology'],
        'qualifications': ['MBBS', 'MD', 'DM'],
        'languages': ['English', 'Hindi', 'Bhojpuri'],
        'experienceYears': 19,
        'consultationFee': 650,
        'clinicName': 'Digestive Health Hospital',
        'isHospital': true,
        'hospitalName': 'Digestive Health Hospital',
        'rating': 4.8,
        'reviewsCount': 175,
        'profilePictureUrl': null,
        'availabilitySlots': ['11:00 AM', '01:00 PM', '03:00 PM'],
      },
      {
        'name': 'Dr. Rajesh Khanna',
        'specializations': ['Urology'],
        'qualifications': ['MBBS', 'MS', 'MCh'],
        'languages': ['English', 'Hindi'],
        'experienceYears': 17,
        'consultationFee': 700,
        'clinicName': 'Kidney & Urology Center',
        'isHospital': true,
        'hospitalName': 'Kidney & Urology Center',
        'rating': 4.7,
        'reviewsCount': 160,
        'profilePictureUrl': null,
        'availabilitySlots': ['03:00 PM', '05:00 PM', '07:00 PM'],
      },
      {
        'name': 'Dr. Sunita Rao',
        'specializations': ['Pulmonology'],
        'qualifications': ['MBBS', 'MD (Chest)'],
        'languages': ['English', 'Kannada', 'Hindi'],
        'experienceYears': 14,
        'consultationFee': 600,
        'clinicName': 'Lung Care Hospital',
        'isHospital': true,
        'hospitalName': 'Lung Care Hospital',
        'rating': 4.6,
        'reviewsCount': 115,
        'profilePictureUrl': null,
        'availabilitySlots': ['09:00 AM', '11:00 AM', '01:00 PM'],
      },
      {
        'name': 'Dr. Anjali Sharma',
        'specializations': ['Gynecology', 'Obstetrics'],
        'qualifications': ['MBBS', 'MS'],
        'languages': ['English', 'Hindi'],
        'experienceYears': 18,
        'consultationFee': 600,
        'clinicName': 'Motherhood Clinic & Women Care',
        'isHospital': true,
        'hospitalName': 'Motherhood Clinic & Women Care',
        'rating': 4.9,
        'reviewsCount': 200,
        'profilePictureUrl': null,
        'availabilitySlots': ['09:00 AM', '10:30 AM', '12:00 PM'],
      },

      // ── Independent clinic doctors (with clinicGeoPoint) ─────────────────────
      {
        'name': 'Dr. M.S. Jakhar',
        'specializations': ['Anaesthesiology'],
        'qualifications': ['MBBS', 'Diploma'],
        'languages': ['English', 'Hindi'],
        'experienceYears': 8,
        'consultationFee': 350,
        'clinicName': 'City Clinic',
        'isHospital': false,
        'clinicGeoPoint': const GeoPoint(28.6315, 77.2167), // Connaught Place, Delhi
        'rating': 4.1,
        'reviewsCount': 30,
        'profilePictureUrl': null,
        'availabilitySlots': ['09:00 AM', '11:00 AM'],
      },
      {
        'name': 'Dr. Sneha Patel',
        'specializations': ['Dermatology'],
        'qualifications': ['MBBS', 'MD'],
        'languages': ['English', 'Gujarati', 'Hindi'],
        'experienceYears': 9,
        'consultationFee': 500,
        'clinicName': 'Skin Glow Clinic',
        'isHospital': false,
        'clinicGeoPoint': const GeoPoint(19.1136, 72.8697), // Andheri, Mumbai
        'rating': 4.4,
        'reviewsCount': 90,
        'profilePictureUrl': null,
        'availabilitySlots': ['11:00 AM', '01:00 PM', '02:00 PM'],
      },
      {
        'name': 'Dr. Amit Kumar',
        'specializations': ['General Medicine'],
        'qualifications': ['MBBS', 'MD'],
        'languages': ['English', 'Hindi'],
        'experienceYears': 7,
        'consultationFee': 300,
        'clinicName': 'Family Clinic',
        'isHospital': false,
        'clinicGeoPoint': const GeoPoint(28.7041, 77.1025), // Rohini, Delhi
        'rating': 4.3,
        'reviewsCount': 60,
        'profilePictureUrl': null,
        'availabilitySlots': ['09:00 AM', '11:00 AM', '01:00 PM'],
      },
      {
        'name': 'Dr. Priya Reddy',
        'specializations': ['Ophthalmology'],
        'qualifications': ['MBBS', 'MS'],
        'languages': ['English', 'Telugu'],
        'experienceYears': 13,
        'consultationFee': 450,
        'clinicName': 'Vision Care',
        'isHospital': false,
        'clinicGeoPoint': const GeoPoint(17.4127, 78.4772), // Jubilee Hills, Hyderabad
        'rating': 4.6,
        'reviewsCount': 130,
        'profilePictureUrl': null,
        'availabilitySlots': ['10:00 AM', '11:30 AM', '01:00 PM'],
      },
      {
        'name': 'Dr. Neha Agarwal',
        'specializations': ['Endocrinology'],
        'qualifications': ['MBBS', 'MD', 'DM'],
        'languages': ['English', 'Hindi'],
        'experienceYears': 10,
        'consultationFee': 550,
        'clinicName': 'Diabetes Center',
        'isHospital': false,
        'clinicGeoPoint': const GeoPoint(26.8505, 80.9493), // Gomti Nagar, Lucknow
        'rating': 4.5,
        'reviewsCount': 95,
        'profilePictureUrl': null,
        'availabilitySlots': ['09:30 AM', '11:30 AM', '01:30 PM'],
      },
      {
        'name': 'Dr. Pooja Singh',
        'specializations': ['Psychiatry'],
        'qualifications': ['MBBS', 'MD (Psychiatry)'],
        'languages': ['English', 'Hindi'],
        'experienceYears': 8,
        'consultationFee': 500,
        'clinicName': 'Mind Wellness Clinic',
        'isHospital': false,
        'clinicGeoPoint': const GeoPoint(12.9716, 77.5946), // Indiranagar, Bengaluru
        'rating': 4.4,
        'reviewsCount': 80,
        'profilePictureUrl': null,
        'availabilitySlots': ['10:00 AM', '12:00 PM', '02:00 PM'],
      },
      {
        'name': 'Dr. Anil Kapoor',
        'specializations': ['ENT'],
        'qualifications': ['MBBS', 'MS (ENT)'],
        'languages': ['English', 'Hindi'],
        'experienceYears': 12,
        'consultationFee': 450,
        'clinicName': 'ENT Specialist Clinic',
        'isHospital': false,
        'clinicGeoPoint': const GeoPoint(13.0604, 80.2496), // T. Nagar, Chennai
        'rating': 4.5,
        'reviewsCount': 105,
        'profilePictureUrl': null,
        'availabilitySlots': ['10:30 AM', '12:30 PM', '02:30 PM'],
      },
      {
        'name': 'Dr. Divya Jain',
        'specializations': ['Dentistry'],
        'qualifications': ['BDS', 'MDS'],
        'languages': ['English', 'Hindi'],
        'experienceYears': 6,
        'consultationFee': 350,
        'clinicName': 'Smile Dental Care',
        'isHospital': false,
        'clinicGeoPoint': const GeoPoint(23.0225, 72.5714), // Navrangpura, Ahmedabad
        'rating': 4.3,
        'reviewsCount': 70,
        'profilePictureUrl': null,
        'availabilitySlots': ['09:00 AM', '10:00 AM', '11:00 AM'],
      },
    ];

    for (var docData in samples) {
      final docRef = collection.doc();
      batch.set(docRef, docData);
    }

    await batch.commit();
  }
}
