import 'package:dartz/dartz.dart';
import 'package:swasthsetu/core/errors/failures.dart';
import 'package:swasthsetu/features/auth/data/models/user_model.dart';

abstract class ProfileRepository {
  /// Fetches the user profile for the given [uid].
  Future<Either<Failure, UserModel>> getProfile({required String uid});

  /// Updates the user profile. Set [isProfileComplete] to true after the initial setup.
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
  });
}
