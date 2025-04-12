import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soocily/features/auth/presentation/components/my_text_fields.dart';
import 'package:soocily/features/profile/presentation/components/user_tile.dart';
import 'package:soocily/features/search/presentation/cubits/search_cubit.dart';
import 'package:soocily/features/search/presentation/cubits/search_state.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  final String hintText = 'Search users...';
  final bool obscureText = false;

  late final searchCubit = context.read<SearchCubit>();

  void onSearchChanged() {
    final query = searchController.text.trim();
    searchCubit.searchUsers(query);
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MyTextFields(
          controller: searchController,
          hintText: hintText,
          obscureText: obscureText,
        ),
      ),
      body: BlocBuilder<SearchCubit, SearchState>(builder: (context, state) {
        if (state is SearchLoadedState) {
          if (state.users.isEmpty) {
            return const Center(
              child: Text('No users found'),
            );
          }

          return ListView.builder(
            itemCount: state.users.length,
            itemBuilder: (context, index) {
              final user = state.users[index];
              return UserTile(
                user: user!,
              );
            },
          );
        } else if (state is SearchLoadingState) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is SearchErrorState) {
          return Center(
            child: Text(state.message),
          );
        }
        return const Center(
          child: Text('Search for users'),
        );
      }),
    );
  }
}
