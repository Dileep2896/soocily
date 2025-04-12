import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  final int postCount;
  final int followersCount;
  final int followingCount;
  final void Function()? onTap;

  const ProfileStats({
    super.key,
    required this.postCount,
    required this.followersCount,
    required this.followingCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var textStyleForCount = TextStyle(
      color: Theme.of(context).colorScheme.inversePrimary,
      fontSize: 20,
    );

    var textStyleForLabel = TextStyle(
      color: Theme.of(context).colorScheme.primary,
    );

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                postCount.toString(),
                style: textStyleForCount,
              ),
              const SizedBox(height: 5),
              Text(
                'Posts',
                style: textStyleForLabel,
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                followersCount.toString(),
                style: textStyleForCount,
              ),
              const SizedBox(height: 5),
              Text(
                'Followers',
                style: textStyleForLabel,
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                followingCount.toString(),
                style: textStyleForCount,
              ),
              const SizedBox(height: 5),
              Text(
                'Following',
                style: textStyleForLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
