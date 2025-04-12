import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soocily/features/auth/data/firebase_auth_repo.dart';
import 'package:soocily/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:soocily/features/auth/presentation/cubits/auth_states.dart';
import 'package:soocily/features/auth/presentation/pages/auth_page.dart';
import 'package:soocily/features/home/presentation/home_page.dart';
import 'package:soocily/features/post/data/firebase_post_repo.dart';
import 'package:soocily/features/post/presentation/cubits/post_cubit.dart';
import 'package:soocily/features/profile/data/firebase_profile_repo.dart';
import 'package:soocily/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:soocily/features/search/data/firebase_search_repo.dart';
import 'package:soocily/features/search/presentation/cubits/search_cubit.dart';
import 'package:soocily/features/storage/data/firebase_storage_repo.dart';
import 'package:soocily/themes/theme_cubit.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final firebaseAuthRepo = FirebaseAuthRepo();
  final firebaseProfileRepo = FirebaseProfileRepo();
  final firebaseStorageRepo = FirebaseStorageRepo();
  final firebasePostRepo = FirebasePostRepo();
  final firebaseSearchRepo = FirebaseSearchRepo();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) =>
                AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
          ),
          BlocProvider<ProfileCubit>(
            create: (context) => ProfileCubit(
              profileRepo: firebaseProfileRepo,
              storageRepo: firebaseStorageRepo,
            ),
          ),
          BlocProvider<PostCubit>(
            create: (context) => PostCubit(
              postRepo: firebasePostRepo,
              storageRepo: firebaseStorageRepo,
            ),
          ),
          BlocProvider<SearchCubit>(
            create: (context) => SearchCubit(
              searchRepo: firebaseSearchRepo,
            ),
          ),
          BlocProvider<ThemeCubit>(
            create: (context) => ThemeCubit(),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeData>(
            builder: (context, currentTheme) => MaterialApp(
                  title: 'Soocily',
                  theme: currentTheme,
                  debugShowCheckedModeBanner: false,
                  home: BlocConsumer<AuthCubit, AuthState>(
                    builder: (context, state) {
                      print(state);

                      if (state is Unauthenticated) {
                        return const AuthPage();
                      }

                      if (state is Authenticated) {
                        return const HomePage();
                      } else {
                        return Scaffold(
                          body: Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        );
                      }
                    },
                    listener: (context, state) {
                      if (state is AuthError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                          ),
                        );
                      }
                    },
                  ),
                )));
  }
}
