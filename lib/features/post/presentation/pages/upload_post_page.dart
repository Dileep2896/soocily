import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soocily/features/auth/domain/entities/app_user.dart';
import 'package:soocily/features/auth/presentation/components/my_text_fields.dart';
import 'package:soocily/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:soocily/features/post/domain/entities/post.dart';
import 'package:soocily/features/post/presentation/cubits/post_cubit.dart';
import 'package:soocily/features/post/presentation/cubits/post_states.dart';
import 'package:soocily/responsive/constrained_scaffold.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  PlatformFile? imagePickedFile;

  Uint8List? webImage;

  final textContoller = TextEditingController();

  AppUser? currentUser;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;
        if (kIsWeb) {
          webImage = imagePickedFile!.bytes;
        }
      });
    }
  }

  // create and upload post
  void uploadPost() {
    if (imagePickedFile == null || textContoller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image and enter text'),
        ),
      );
      return;
    }

    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: textContoller.text,
      imageUrl: '',
      timestamp: DateTime.now(),
      likes: [],
      comments: [],
    );

    final postCubit = context.read<PostCubit>();
    if (kIsWeb) {
      postCubit.createPost(newPost, imageBytes: imagePickedFile?.bytes);
    } else {
      postCubit.createPost(newPost, imagePath: imagePickedFile?.path);
    }
  }

  @override
  void dispose() {
    textContoller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(
      builder: (context, state) {
        if (state is PostsLoadingState) {
          return const ConstrainedScaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return buildUploadPage();
      },
      listener: (context, state) {
        if (state is PostsErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
            ),
          );
        }

        if (state is PostsLoadedState) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget buildUploadPage() {
    return ConstrainedScaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: uploadPost,
          ),
        ],
      ),
      body: Column(
        children: [
          // image preview for web
          if (kIsWeb && webImage != null)
            Image.memory(
              webImage!,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

          // image preview for mobile
          if (!kIsWeb && imagePickedFile != null)
            Image.file(
              File(imagePickedFile!.path!),
              width: double.infinity,
              fit: BoxFit.cover,
            ),

          if (imagePickedFile == null) // pich image button
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 300,
                width: double.infinity,
                color: Theme.of(context).colorScheme.secondary,
                child: imagePickedFile == null
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.image,
                                size: 40,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Tap to pick an image",
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : null,
              ),
            ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MyTextFields(
              controller: textContoller,
              hintText: "Caption",
              obscureText: false,
            ),
          )
        ],
      ),
    );
  }
}
