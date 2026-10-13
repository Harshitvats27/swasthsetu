import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swasthsetu/features/auth/data/models/user_model.dart';
import 'package:swasthsetu/features/profile/data/repositories/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required ProfileRepository repository})
      : _repository = repository,
        super(const ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<SaveProfileEvent>(_onSaveProfile);
  }

  final ProfileRepository _repository;

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await _repository.getProfile(uid: event.uid);
    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (user) => emit(ProfileLoaded(user: user)),
    );
  }

  Future<void> _onSaveProfile(
    SaveProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await _repository.updateProfile(
      uid: event.uid,
      name: event.name,
      email: event.email,
      dateOfBirth: event.dateOfBirth,
      bloodGroup: event.bloodGroup,
      age: event.age,
      gender: event.gender,
      height: event.height,
      weight: event.weight,
      existingConditions: event.existingConditions,
      allergies: event.allergies,
      emergencyContacts: event.emergencyContacts,
      profilePictureUrl: event.profilePictureUrl,
      isProfileComplete: true, // Marking complete once saved
    );

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (user) => emit(ProfileSaved(user: user)),
    );
  }
}
