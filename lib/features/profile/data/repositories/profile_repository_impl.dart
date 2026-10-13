import 'package:dartz/dartz.dart';
import 'package:swasthsetu/core/errors/failures.dart';
import 'package:swasthsetu/features/auth/data/models/user_model.dart';
import 'package:swasthsetu/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:swasthsetu/features/profile/data/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({required ProfileRemoteDataSource remote})
      : _remote = remote;

  final ProfileRemoteDataSource _remote;

  @override
  Future<Either<Failure, UserModel>> getProfile({required String uid}) async {
    try {
      final data = await _remote.getProfile(uid);
      if (data != null) {
        // We construct a UserModel, normally we would need the doc.id for uid, 
        // but we already have uid, so we inject it.
        data['uid'] = uid;
        // The factory takes a DocumentSnapshot, but we can adapt it or just build it.
        // Actually, let's just construct it manually since fromFirestore needs a DocumentSnapshot.
        return Right(UserModel(
          uid: uid,
          phone: data['phone'] as String? ?? '',
          name: data['name'] as String?,
          email: data['email'] as String?,
          profilePictureUrl: data['profilePictureUrl'] as String?,
          dateOfBirth: data['dateOfBirth'] as String?,
          bloodGroup: data['bloodGroup'] as String?,
          age: data['age'] as int?,
          gender: data['gender'] as String?,
          height: (data['height'] as num?)?.toDouble(),
          weight: (data['weight'] as num?)?.toDouble(),
          existingConditions: (data['existingConditions'] as List<dynamic>?)?.map((e) => e as String).toList(),
          allergies: (data['allergies'] as List<dynamic>?)?.map((e) => e as String).toList(),
          emergencyContacts: (data['emergencyContacts'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
          isProfileComplete: data['isProfileComplete'] as bool? ?? false,
        ));
      }
      return const Left(NotFoundFailure(message: 'Profile not found'));
    } catch (e, stack) {
      return Left(ServerFailure(message: e.toString(), stackTrace: stack));
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateProfile({
    required String uid,
    String? name,
    String? email,
    String? dateOfBirth,
    String? bloodGroup,
    int? age,
    String? gender,
    double? height,
    double? weight,
    List<String>? existingConditions,
    List<String>? allergies,
    List<Map<String, dynamic>>? emergencyContacts,
    String? profilePictureUrl,
    bool? isProfileComplete,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (dateOfBirth != null) updateData['dateOfBirth'] = dateOfBirth;
      if (bloodGroup != null) updateData['bloodGroup'] = bloodGroup;
      if (age != null) updateData['age'] = age;
      if (gender != null) updateData['gender'] = gender;
      if (height != null) updateData['height'] = height;
      if (weight != null) updateData['weight'] = weight;
      if (existingConditions != null) updateData['existingConditions'] = existingConditions;
      if (allergies != null) updateData['allergies'] = allergies;
      if (emergencyContacts != null) updateData['emergencyContacts'] = emergencyContacts;
      if (profilePictureUrl != null) updateData['profilePictureUrl'] = profilePictureUrl;
      if (isProfileComplete != null) updateData['isProfileComplete'] = isProfileComplete;

      await _remote.updateProfile(uid, updateData);
      
      return getProfile(uid: uid);
    } catch (e, stack) {
      return Left(ServerFailure(message: e.toString(), stackTrace: stack));
    }
  }
}
