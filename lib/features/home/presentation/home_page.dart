import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soocily/features/home/presentation/components/my_drawer.dart';
import 'package:soocily/features/post/presentation/components/post_tile.dart';
import 'package:soocily/features/post/presentation/cubits/post_cubit.dart';
import 'package:soocily/features/post/presentation/cubits/post_states.dart';
import 'package:soocily/features/post/presentation/pages/upload_post_page.dart';
import 'package:soocily/responsive/constrained_scaffold.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final postCubit = context.read<PostCubit>();

  @override
  void initState() {
    super.initState();
    fetchAllPosts();
  }

  void fetchAllPosts() {
    postCubit.fetchAllPosts();
  }

  void deletePost(String postId) {
    postCubit.deletePost(postId);
    fetchAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Handle notifications
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UploadPostPage(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: BlocBuilder<PostCubit, PostState>(builder: (context, state) {
        // loading
        if (state is PostsLoadingState || state is PostsUploadingState) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // loaded
        else if (state is PostsLoadedState) {
          final allPost = state.posts;
          if (allPost.isEmpty) {
            return const Center(
              child: Text('No posts available'),
            );
          }

          return ListView.builder(
            itemCount: state.posts.length,
            itemBuilder: (context, index) {
              final post = allPost[index];
              return PostTile(
                post: post,
                onDelete: () => deletePost(post.id),
              );
            },
          );
        }

        //error
        else if (state is PostsErrorState) {
          return Center(
            child: Text(state.error),
          );
        }

        // empty
        else {
          return const SizedBox();
        }
      }),
    );
  }
}
