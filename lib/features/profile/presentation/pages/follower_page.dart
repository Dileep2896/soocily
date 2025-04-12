import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soocily/features/profile/presentation/components/user_tile.dart';
import 'package:soocily/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:soocily/responsive/constrained_scaffold.dart';

class FollowerPage extends StatelessWidget {
  final List<String> followers;
  final List<String> following;

  const FollowerPage(
      {super.key, required this.followers, required this.following});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ConstrainedScaffold(
        appBar: AppBar(
          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'Followers'),
              Tab(text: 'Following'),
            ],
          ),
        ),
        body: TabBarView(children: [
          _buildUserList(followers, 'No followers yet', context),
          _buildUserList(following, 'Not following anyone yet', context),
        ]),
      ),
    );
  }

  // build user list, given a list of user ids
  Widget _buildUserList(
      List<String> userIds, String emptyMessage, BuildContext context) {
    if (userIds.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: userIds.length,
      itemBuilder: (context, index) {
        final userId = userIds[index];
        return FutureBuilder(
            future: context.read<ProfileCubit>().getUserProfile(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final userProfile = snapshot.data;
                return UserTile(user: userProfile!);
              } else {
                return const Center(child: Text('No data found'));
              }
            });
      },
    );
  }
}
