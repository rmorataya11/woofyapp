import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';
import '../utils/api_exceptions.dart';

class ProfileState {
  final Profile? profile;
  final UserPreferences? preferences;
  final bool isLoading;
  final String? errorMessage;

  ProfileState({
    this.profile,
    this.preferences,
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    Profile? profile,
    UserPreferences? preferences,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      preferences: preferences ?? this.preferences,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  factory ProfileState.initial() {
    return ProfileState();
  }

  factory ProfileState.loading() {
    return ProfileState(isLoading: true);
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileService _profileService = ProfileService();

  ProfileNotifier() : super(ProfileState.initial());

  Future<void> loadProfile() async {
    state = ProfileState.loading();

    try {
      final profile = await _profileService.getMyProfile();
      final preferences = await _profileService.getMyPreferences();

      state = ProfileState(
        profile: profile,
        preferences: preferences,
        isLoading: false,
      );
    } catch (e) {
      state = ProfileState(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? location,
    String? bio,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final updatedProfile = await _profileService.updateMyProfile(
        name: name,
        email: email,
        phone: phone,
        location: location,
        bio: bio,
      );

      state = ProfileState(
        profile: updatedProfile,
        preferences: state.preferences,
        isLoading: false,
      );

      return true;
    } on ValidationException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updatePreferences(UserPreferences preferences) async {
    state = state.copyWith(isLoading: true);

    try {
      final updatedPreferences = await _profileService.updateMyPreferences(
        preferences,
      );

      state = ProfileState(
        profile: state.profile,
        preferences: updatedPreferences,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> uploadAvatar(String filePath) async {
    state = state.copyWith(isLoading: true);

    try {
      final avatarUrl = await _profileService.uploadAvatar(filePath);

      if (state.profile != null) {
        state = ProfileState(
          profile: state.profile!.copyWith(avatarUrl: avatarUrl),
          preferences: state.preferences,
          isLoading: false,
        );
      }

      return true;
    } on ValidationException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteAvatar() async {
    state = state.copyWith(isLoading: true);

    try {
      await _profileService.deleteAvatar();

      if (state.profile != null) {
        state = ProfileState(
          profile: state.profile!.copyWith(avatarUrl: null),
          preferences: state.preferences,
          isLoading: false,
        );
      }

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  return ProfileNotifier();
});
