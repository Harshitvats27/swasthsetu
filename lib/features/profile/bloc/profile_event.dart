part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {
  const LoadProfileEvent({required this.uid});
  final String uid;

  @override
  List<Object?> get props => [uid];
}

class SaveProfileEvent extends ProfileEvent {
  const SaveProfileEvent({
    required this.uid,
    required this.name,
    this.email,
    this.dateOfBirth,
    this.bloodGroup,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.existingConditions,
    this.allergies,
    this.emergencyContacts,
    this.profilePictureUrl,
  });

  final String uid;
  final String name;
  final String? email;
  final String? dateOfBirth;
  final String? bloodGroup;
  final int? age;
  final String? gender;
  final double? height;
  final double? weight;
  final List<String>? existingConditions;
  final List<String>? allergies;
  final List<Map<String, dynamic>>? emergencyContacts;
  final String? profilePictureUrl;

  @override
  List<Object?> get props => [
        uid,
        name,
        email,
        dateOfBirth,
        bloodGroup,
        age,
        gender,
        height,
        weight,
        existingConditions,
        allergies,
        emergencyContacts,
        profilePictureUrl,
      ];
}
