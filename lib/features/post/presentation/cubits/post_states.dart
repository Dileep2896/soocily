import 'package:soocily/features/post/domain/entities/post.dart';

abstract class PostState {}

// initial state
class PostsInitialState extends PostState {}

// loading state
class PostsLoadingState extends PostState {}

// uploading state
class PostsUploadingState extends PostState {}

// error state
class PostsErrorState extends PostState {
  final String error;

  PostsErrorState(this.error);
}

// loaded state
class PostsLoadedState extends PostState {
  final List<Post> posts;

  PostsLoadedState(this.posts);
}
