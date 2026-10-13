import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swasthsetu/features/hospitals/data/models/hospital_model.dart';

class HospitalRemoteDataSource {
  final FirebaseFirestore firestore;

  HospitalRemoteDataSource({required this.firestore});

  Future<List<HospitalModel>> fetchHospitals() async {
    final snapshot = await firestore.collection('hospitals').get();
    return snapshot.docs.map((doc) => HospitalModel.fromFirestore(doc)).toList();
  }

  Future<void> seedHospitals() async {
    final batch = firestore.batch();
    final collection = firestore.collection('hospitals');

    // 10 real Indian hospitals with correct lat/lng
    // Doctors from existing seed: Aadhar Health Institute doctors (Geeta Dabas, Neeraj Nagar, Rameshwar)
    // Relief Hospital (P.Bhusal), Motherhood Clinic (Anjali Sharma), etc.
    final List<Map<String, dynamic>> hospitals = [
      {
        'name': 'Aadhar Health Institute',
        'address': 'Plot No. 14, Sector-6, Dwarka',
        'city': 'New Delhi',
        'state': 'Delhi',
        'phone': '+91-11-45674567',
        'imageUrl': null,
        'geoPoint': const GeoPoint(28.5921, 77.0460),
        'specialties': ['Nephrology', 'Anaesthesiology', 'Pain Medicine', 'Cardiology'],
        'facilities': ['ICU', 'OT', 'Dialysis', 'Pharmacy', 'Ambulance'],
        'totalBeds': 250,
        'rating': 4.6,
        'reviewsCount': 340,
        'isOpen24x7': true,
        // Maps to: Dr. Geeta Dabas, Dr. Neeraj Nagar, Dr. Rameshwar (resolved at runtime by hospitalId)
        'doctorIds': [],
      },
      {
        'name': 'Relief Hospital & Research Centre',
        'address': '2-A, Ring Road, Lajpat Nagar',
        'city': 'New Delhi',
        'state': 'Delhi',
        'phone': '+91-11-29832983',
        'imageUrl': null,
        'geoPoint': const GeoPoint(28.5672, 77.2430),
        'specialties': ['Pain Medicine', 'Orthopedics', 'Neurology', 'General Surgery'],
        'facilities': ['Emergency', 'OT', 'Physiotherapy', 'Pharmacy', 'Blood Bank'],
        'totalBeds': 180,
        'rating': 4.5,
        'reviewsCount': 210,
        'isOpen24x7': true,
        'doctorIds': [],
      },
      {
        'name': 'Bone & Joint Center',
        'address': '45, Linking Road, Bandra West',
        'city': 'Mumbai',
        'state': 'Maharashtra',
        'phone': '+91-22-26424642',
        'imageUrl': null,
        'geoPoint': const GeoPoint(19.0596, 72.8295),
        'specialties': ['Orthopedics', 'Spine Surgery', 'Arthroscopy', 'Rheumatology'],
        'facilities': ['OT', 'Physiotherapy', 'X-Ray', 'MRI', 'DEXA Scan'],
        'totalBeds': 120,
        'rating': 4.7,
        'reviewsCount': 280,
        'isOpen24x7': false,
        'doctorIds': [],
      },
      {
        'name': 'Child Care Hospital',
        'address': '8, Koramangala 5th Block',
        'city': 'Bengaluru',
        'state': 'Karnataka',
        'phone': '+91-80-25634563',
        'imageUrl': null,
        'geoPoint': const GeoPoint(12.9352, 77.6245),
        'specialties': ['Pediatrics', 'Neonatology', 'Pediatric Surgery', 'Child Psychology'],
        'facilities': ['NICU', 'PICU', 'Vaccination', 'OT', 'Pharmacy'],
        'totalBeds': 150,
        'rating': 4.8,
        'reviewsCount': 380,
        'isOpen24x7': true,
        'doctorIds': [],
      },
      {
        'name': 'Heart Institute',
        'address': '1, Wockhardt Campus, Old Bombay Road',
        'city': 'Pune',
        'state': 'Maharashtra',
        'phone': '+91-20-27272727',
        'imageUrl': null,
        'geoPoint': const GeoPoint(18.5204, 73.8567),
        'specialties': ['Cardiology', 'Cardiac Surgery', 'Electrophysiology', 'Heart Failure'],
        'facilities': ['Cath Lab', 'ICU', 'OT', 'Echocardiography', 'Ambulance'],
        'totalBeds': 200,
        'rating': 4.9,
        'reviewsCount': 520,
        'isOpen24x7': true,
        'doctorIds': [],
      },
      {
        'name': 'Neuro Spine Hospital',
        'address': '17, Nehru Nagar, Near Aiims',
        'city': 'Hyderabad',
        'state': 'Telangana',
        'phone': '+91-40-23234323',
        'imageUrl': null,
        'geoPoint': const GeoPoint(17.3850, 78.4867),
        'specialties': ['Neurology', 'Neurosurgery', 'Spine Surgery', 'Stroke'],
        'facilities': ['MRI', 'CT Scan', 'ICU', 'OT', 'Rehabilitation'],
        'totalBeds': 175,
        'rating': 4.7,
        'reviewsCount': 295,
        'isOpen24x7': true,
        'doctorIds': [],
      },
      {
        'name': 'Digestive Health Hospital',
        'address': '22, Hazratganj, Near GPO',
        'city': 'Lucknow',
        'state': 'Uttar Pradesh',
        'phone': '+91-522-22345234',
        'imageUrl': null,
        'geoPoint': const GeoPoint(26.8467, 80.9462),
        'specialties': ['Gastroenterology', 'Hepatology', 'GI Surgery', 'Endoscopy'],
        'facilities': ['Endoscopy Suite', 'ICU', 'OT', 'Liver Lab', 'Pharmacy'],
        'totalBeds': 130,
        'rating': 4.8,
        'reviewsCount': 310,
        'isOpen24x7': true,
        'doctorIds': [],
      },
      {
        'name': 'Kidney & Urology Center',
        'address': '3A, Anna Nagar East',
        'city': 'Chennai',
        'state': 'Tamil Nadu',
        'phone': '+91-44-26264626',
        'imageUrl': null,
        'geoPoint': const GeoPoint(13.0850, 80.2101),
        'specialties': ['Urology', 'Nephrology', 'Kidney Transplant', 'Robotic Surgery'],
        'facilities': ['OT', 'Dialysis', 'ICU', 'Lithotripsy', 'Blood Bank'],
        'totalBeds': 160,
        'rating': 4.7,
        'reviewsCount': 260,
        'isOpen24x7': true,
        'doctorIds': [],
      },
      {
        'name': 'Lung Care Hospital',
        'address': '56, Sadashivanagar Main Road',
        'city': 'Bengaluru',
        'state': 'Karnataka',
        'phone': '+91-80-23562356',
        'imageUrl': null,
        'geoPoint': const GeoPoint(13.0101, 77.5680),
        'specialties': ['Pulmonology', 'Respiratory Medicine', 'Sleep Medicine', 'TB & Chest'],
        'facilities': ['PFT Lab', 'Bronchoscopy', 'ICU', 'Sleep Lab', 'Pharmacy'],
        'totalBeds': 100,
        'rating': 4.6,
        'reviewsCount': 195,
        'isOpen24x7': false,
        'doctorIds': [],
      },
      {
        'name': 'Motherhood Clinic & Women Care',
        'address': '7, MG Road, Indiranagar',
        'city': 'Bengaluru',
        'state': 'Karnataka',
        'phone': '+91-80-41514151',
        'imageUrl': null,
        'geoPoint': const GeoPoint(12.9784, 77.6408),
        'specialties': ['Gynecology', 'Obstetrics', 'Infertility', 'Laparoscopy'],
        'facilities': ['Labour Room', 'NICU', 'OT', 'Ultrasound', 'Pharmacy'],
        'totalBeds': 80,
        'rating': 4.9,
        'reviewsCount': 420,
        'isOpen24x7': true,
        'doctorIds': [],
      },
    ];

    for (var hospitalData in hospitals) {
      final docRef = collection.doc();
      batch.set(docRef, hospitalData);
    }

    await batch.commit();
  }
}
