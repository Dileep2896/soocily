import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soocily/features/profile/domain/entities/profile_user.dart';
import 'package:soocily/features/profile/domain/repo/profile_repo.dart';
import 'package:soocily/features/profile/presentation/cubit/profile_state.dart';
import 'package:soocily/features/storage/domain/storage_repo.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final StorageRepo storageRepo;

  ProfileCubit({required this.profileRepo, required this.storageRepo})
      : super(ProfileInitial());

  Future<void> fetchProfile(String uid) async {
    emit(ProfileLoading());
    try {
      final profile = await profileRepo.fetchUserProfile(uid);
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<ProfileUser> getUserProfile(String uid) async {
    final user = await profileRepo.fetchUserProfile(uid);
    return user;
  }

  Future<void> updateProfile({
    required String uid,
    String? newBio,
    Uint8List? imageWebBytes,
    String? imageMobilePath,
  }) async {
    emit(ProfileLoading());
    try {
      final currentUser = await profileRepo.fetchUserProfile(uid);

      String? imageDownloadUrl;

      if (imageWebBytes != null || imageMobilePath != null) {
        // Upload the image and get the download URL
        if (imageWebBytes != null) {
          imageDownloadUrl = await storageRepo.uploadProfileImageWeb(
            imageWebBytes,
            uid,
          );
        } else if (imageMobilePath != null) {
          imageDownloadUrl = await storageRepo.uploadProfileImageMobile(
            imageMobilePath,
            uid,
          );
        }

        if (imageDownloadUrl == null) {
          emit(ProfileError(message: 'Failed to upload image'));
          return;
        }
      }

      final updatedProdile = currentUser.copyWith(
        bio: newBio ?? currentUser.bio,
        profileImageUrl: imageDownloadUrl ?? currentUser.profileImageUrl,
      );

      await profileRepo.updateUserProfile(updatedProdile);

      // Fetch the updated profile
      await fetchProfile(uid);
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> toggleFollow(String currentUserId, String targetUserId) async {
    try {
      await profileRepo.toggleFollow(currentUserId, targetUserId);
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }
}
