import 'package:soocily/features/post/domain/entities/comment.dart';
import 'package:soocily/features/post/domain/entities/post.dart';

abstract class PostRepo {
  Future<List<Post>> fetchAllPosts();

  Future<void> createPost(Post post);

  Future<List<Post>> fetchPostsByUserId(String userId);

  Future<void> deletePost(String id);

  Future<void> toggleLikePost(String postId, String userId);

  Future<void> addCommentToPost(String postId, Comment comment);

  Future<void> deleteCommentFromPost(String postId, String commentId);
}
