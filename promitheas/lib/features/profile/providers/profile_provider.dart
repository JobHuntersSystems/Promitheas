import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promitheas/features/profile/repositories/profile_repository.dart';
import 'package:promitheas/features/profile/models/profile_model.dart';

class ProfileNotifier extends AsyncNotifier<ProfileModel> {
  
  @override
  Future<ProfileModel> build() async {
    return await ref.read(profileRepositoryProvider).fetchUserProfile();
  }

  Future<String?> updateProfile(ProfileModel updatedProfile) async {
    try {
      final updates = updatedProfile.toJson();

      await ref.read(profileRepositoryProvider).updateUserProfile(updates);
      
      state = AsyncData(updatedProfile); 
      
      return null;
    } catch (e) {
      return 'Error updating profile: $e';
    }
  }
}


final profileProvider = AsyncNotifierProvider<ProfileNotifier, ProfileModel>(
  ProfileNotifier.new,
);