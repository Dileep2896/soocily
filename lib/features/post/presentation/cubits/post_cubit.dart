import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soocily/features/post/domain/entities/comment.dart';
import 'package:soocily/features/post/domain/entities/post.dart';
import 'package:soocily/features/post/domain/repo/post_repo.dart';
import 'package:soocily/features/post/presentation/cubits/post_states.dart';
import 'package:soocily/features/storage/domain/storage_repo.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo postRepo;
  final StorageRepo storageRepo;

  PostCubit({
    required this.postRepo,
    required this.storageRepo,
  }) : super(PostsInitialState());

  // create post
  Future<void> createPost(Post post,
      {String? imagePath, Uint8List? imageBytes}) async {
    String? imageUrl;

    try {
      // handle images upload for mobile platforms (using file path)
      if (imagePath != null) {
        emit(PostsUploadingState());
        imageUrl = await storageRepo.uploadPostImageMobile(imagePath, post.id);
      }

      // handle images upload for web platforms (using file bytes)
      else if (imageBytes != null) {
        emit(PostsUploadingState());
        imageUrl = await storageRepo.uploadPostImageWeb(imageBytes, post.id);
      }

      final newPost = post.copyWith(imageUrl: imageUrl);

      postRepo.createPost(newPost);

      fetchAllPosts();
    } catch (e) {
      emit(PostsErrorState(e.toString()));
    }
  }

  // fetch all posts
  Future<void> fetchAllPosts() async {
    emit(PostsLoadingState());

    try {
      final posts = await postRepo.fetchAllPosts();
      emit(PostsLoadedState(posts));
    } catch (e) {
      emit(PostsErrorState("Failed to fetch all posts: ${e.toString()}"));
    }
  }

  // delete post
  Future<void> deletePost(String postId) async {
    emit(PostsLoadingState());

    try {
      await postRepo.deletePost(postId);
    } catch (e) {
      emit(PostsErrorState("Failed to delete post: ${e.toString()}"));
    }
  }

  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      await postRepo.toggleLikePost(postId, userId);
    } catch (e) {
      emit(PostsErrorState("Failed to toggle like: ${e.toString()}"));
    }
  }

  Future<void> addCommentToPost(String postId, Comment comment) async {
    try {
      await postRepo.addCommentToPost(postId, comment);
      await fetchAllPosts();
    } catch (e) {
      emit(PostsErrorState("Failed to add comment: ${e.toString()}"));
    }
  }

  Future<void> deleteCommentFromPost(String postId, String commentId) async {
    try {
      await postRepo.deleteCommentFromPost(postId, commentId);
      await fetchAllPosts();
    } catch (e) {
      emit(PostsErrorState("Failed to delete comment: ${e.toString()}"));
    }
  }
}
