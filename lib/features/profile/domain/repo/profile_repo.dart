import 'package:soocily/features/profile/domain/entities/profile_user.dart';

abstract class ProfileRepo {
  Future<ProfileUser> fetchUserProfile(String uid);
  Future<void> updateUserProfile(ProfileUser user);
  Future<void> toggleFollow(String currentUid, String followerUid);
}
