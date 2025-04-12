import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soocily/features/auth/domain/entities/app_user.dart';
import 'package:soocily/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:soocily/features/post/presentation/components/post_tile.dart';
import 'package:soocily/features/post/presentation/cubits/post_cubit.dart';
import 'package:soocily/features/post/presentation/cubits/post_states.dart';
import 'package:soocily/features/profile/presentation/components/bio_box.dart';
import 'package:soocily/features/profile/presentation/components/follow_button.dart';
import 'package:soocily/features/profile/presentation/components/profile_stats.dart';
import 'package:soocily/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:soocily/features/profile/presentation/cubit/profile_state.dart';
import 'package:soocily/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:soocily/features/profile/presentation/pages/follower_page.dart';
import 'package:soocily/responsive/constrained_scaffold.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  late AppUser? user = authCubit.currentUser;

  int postCount = 0;

  @override
  void initState() {
    super.initState();

    profileCubit.fetchProfile(widget.uid);
  }

  // FOLLOW, UNFOLLOW
  void followButtonPressed() {
    final profileState = profileCubit.state;
    if (profileState is! ProfileLoaded) {
      return;
    }

    final profileUser = profileState.profile;
    final isFollowing = profileUser.followers.contains(user!.uid);

    // optimistically update the UI
    setState(() {
      if (isFollowing) {
        profileUser.followers.remove(user!.uid);
      } else {
        profileUser.followers.add(user!.uid);
      }
    });

    profileCubit.toggleFollow(user!.uid, widget.uid).catchError((error) {
      setState(() {
        // revert the optimistic update
        if (isFollowing) {
          profileUser.followers.add(user!.uid);
        } else {
          profileUser.followers.remove(user!.uid);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isOwnPost = widget.uid == user?.uid;

    return BlocBuilder<ProfileCubit, ProfileState>(builder: (context, state) {
      if (state is ProfileLoading) {
        return const ConstrainedScaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else if (state is ProfileLoaded) {
        final profile = state.profile;
        return ConstrainedScaffold(
          appBar: AppBar(
            title: Text(profile.name),
            foregroundColor: Theme.of(context).colorScheme.primary,
            actions: [
              if (isOwnPost)
                IconButton(
                  onPressed: () {
                    // Navigate to edit profile page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(
                          profileUser: profile,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                )
            ],
          ),
          body: ListView(
            children: [
              Center(
                child: Text(
                  profile.email,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Displaying the profile image
              CachedNetworkImage(
                imageUrl: profile.profileImageUrl,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.person,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
                imageBuilder: (context, imageProvider) => Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              ProfileStats(
                postCount: postCount,
                followersCount: profile.followers.length,
                followingCount: profile.following.length,
                onTap: () {
                  // Navigate to followers page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FollowerPage(
                        followers: profile.followers,
                        following: profile.following,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              if (!isOwnPost)
                // Follow button
                FollowButton(
                  onPressed: followButtonPressed,
                  isFollowing: profile.followers.contains(user!.uid),
                ),

              const SizedBox(height: 25),

              // Displaying the bio
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Text(
                      "Bio",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              BioBox(bio: profile.bio),

              const SizedBox(height: 25),

              // Displaying the bio
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Text(
                      "Posts",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              BlocBuilder<PostCubit, PostState>(builder: (context, state) {
                // Loaded
                if (state is PostsLoadedState) {
                  final userPosts = state.posts
                      .where((post) => post.userId == profile.uid)
                      .toList();

                  postCount = userPosts.length;

                  return ListView.builder(
                    itemCount: postCount,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final post = userPosts[index];

                      return PostTile(
                        post: post,
                        onDelete: () =>
                            context.read<PostCubit>().deletePost(post.id),
                      );
                    },
                  );
                }

                // loading
                else if (state is PostsLoadingState) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return const Center(
                    child: Text("No posts found"),
                  );
                }
              })
            ],
          ),
        );
      } else if (state is ProfileError) {
        return ConstrainedScaffold(
          appBar: AppBar(
            title: const Text('Profile'),
          ),
          body: Center(child: Text(state.message)),
        );
      } else {
        return const Center(child: Text('No Profile Found'));
      }
    });
  }
}
