import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soocily/features/profile/domain/entities/profile_user.dart';
import 'package:soocily/features/profile/domain/repo/profile_repo.dart';

class FirebaseProfileRepo implements ProfileRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<ProfileUser> fetchUserProfile(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      final userData = userDoc.data()!;

      final followers = List<String>.from(userData['followers'] ?? []);
      final following = List<String>.from(userData['following'] ?? []);

      return ProfileUser(
        uid: uid,
        email: userData['email'],
        name: userData['name'],
        bio: userData['bio'] ?? "",
        profileImageUrl: userData['profileImageUrl'].toString(),
        followers: followers,
        following: following,
      );
    }
    throw Exception('User not found');
  }

  @override
  Future<void> updateUserProfile(ProfileUser updatedProfile) async {
    try {
      await _firestore.collection('users').doc(updatedProfile.uid).update({
        'bio': updatedProfile.bio,
        'profileImageUrl': updatedProfile.profileImageUrl,
      });
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<void> toggleFollow(String currentUid, String followerUid) async {
    try {
      final currentUserDoc =
          await _firestore.collection('users').doc(currentUid).get();
      final followerUserDoc =
          await _firestore.collection('users').doc(followerUid).get();

      if (!currentUserDoc.exists || !followerUserDoc.exists) {
        throw Exception('User not found');
      }

      final currentUserData = currentUserDoc.data()!;

      final List<String> currentFollowing =
          List<String>.from(currentUserData['following'] ?? []);

      if (currentFollowing.contains(followerUid)) {
        // Unfollow
        await _firestore.collection('users').doc(currentUid).update({
          'following': FieldValue.arrayRemove([followerUid]),
        });
        await _firestore.collection('users').doc(followerUid).update({
          'followers': FieldValue.arrayRemove([currentUid]),
        });
      } else {
        // Follow
        await _firestore.collection('users').doc(currentUid).update({
          'following': FieldValue.arrayUnion([followerUid]),
        });
        await _firestore.collection('users').doc(followerUid).update({
          'followers': FieldValue.arrayUnion([currentUid]),
        });
      }
    } catch (e) {
      throw Exception('Failed to toggle follow: $e');
    }
  }
}
