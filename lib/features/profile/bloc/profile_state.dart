part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded({required this.user});
  final UserModel user;

  @override
  List<Object?> get props => [user];
}

class ProfileSaved extends ProfileState {
  const ProfileSaved({required this.user});
  final UserModel user;

  @override
  List<Object?> get props => [user];
}

class ProfileError extends ProfileState {
  const ProfileError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
