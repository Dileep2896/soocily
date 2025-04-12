import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soocily/features/post/domain/entities/comment.dart';
import 'package:soocily/features/post/domain/entities/post.dart';
import 'package:soocily/features/post/domain/repo/post_repo.dart';

class FirebasePostRepo implements PostRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final CollectionReference postsCollection =
      FirebaseFirestore.instance.collection('posts');

  @override
  Future<void> createPost(Post post) {
    try {
      return postsCollection.doc(post.id).set(post.toJson());
    } catch (e) {
      throw Exception('Error creating post: $e');
    }
  }

  @override
  Future<void> deletePost(String id) async {
    await postsCollection.doc(id).delete();
  }

  @override
  Future<List<Post>> fetchAllPosts() async {
    try {
      final postsSnapshot =
          await postsCollection.orderBy('timestamp', descending: true).get();

      final List<Post> posts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return posts;
    } catch (e) {
      throw Exception('Error fetching posts: $e');
    }
  }

  @override
  Future<List<Post>> fetchPostsByUserId(String userId) async {
    try {
      final postsSnapshot =
          await postsCollection.where('userId', isEqualTo: userId).get();

      final userPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return userPosts;
    } catch (e) {
      throw Exception('Error fetching posts by userId: $e');
    }
  }

  @override
  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // check if the user has already liked the post
        final hasLiked = post.likes.contains(userId);

        if (hasLiked) {
          // remove the userId from the likes list
          post.likes.remove(userId);
        } else {
          // add the userId to the likes list
          post.likes.add(userId);
        }

        // update the post document with the new likes list
        await postsCollection.doc(postId).update({
          'likes': post.likes,
        });
      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      throw Exception('Error toggling like on post: $e');
    }
  }

  @override
  Future<void> addCommentToPost(String postId, Comment comment) async {
    try {
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // add the new comment to the comments list
        post.comments.add(comment);

        // update the post document with the new comments list
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((c) => c.toJson()).toList(),
        });
      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      throw Exception('Error adding comment to post: $e');
    }
  }

  @override
  Future<void> deleteCommentFromPost(String postId, String commentId) async {
    try {
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // add the new comment to the comments list
        post.comments.removeWhere((comment) => comment.id == commentId);

        // update the post document with the new comments list
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((c) => c.toJson()).toList(),
        });
      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      throw Exception('Error deleting comment to post: $e');
    }
  }
}
