import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soocily/features/auth/presentation/components/my_text_fields.dart';
import 'package:soocily/features/profile/domain/entities/profile_user.dart';
import 'package:soocily/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:soocily/features/profile/presentation/cubit/profile_state.dart';
import 'package:soocily/responsive/constrained_scaffold.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileUser profileUser;

  const EditProfilePage({super.key, required this.profileUser});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  PlatformFile? imagePickedFile;

  Uint8List? webImage;

  final bioTextController = TextEditingController();

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

  void updateProfile() {
    final profileCubit = context.read<ProfileCubit>();

    final String uid = widget.profileUser.uid;
    final imageMobilePath = kIsWeb ? null : imagePickedFile?.path;
    final imageWebBytes = kIsWeb ? imagePickedFile?.bytes : null;
    final String? newBio =
        bioTextController.text.isNotEmpty ? bioTextController.text : null;

    if (imagePickedFile != null || newBio != null) {
      profileCubit.updateProfile(
        uid: uid,
        newBio: newBio,
        imageMobilePath: imageMobilePath,
        imageWebBytes: imageWebBytes,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const ConstrainedScaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Uploading...'),
                ],
              ),
            ),
          );
        } else if (state is ProfileLoaded) {
          final profile = state.profile;
          bioTextController.text = profile.bio;
          return ConstrainedScaffold(
            appBar: AppBar(
              title: const Text('Edit Profile'),
              foregroundColor: Theme.of(context).colorScheme.primary,
              actions: [
                IconButton(
                  onPressed: () {
                    // Save changes
                    updateProfile();
                  },
                  icon: const Icon(Icons.save),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // profile picture
                  Center(
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: (!kIsWeb && imagePickedFile != null)
                          ? Image.file(
                              File(imagePickedFile!.path!),
                              fit: BoxFit.cover,
                            )
                          : (kIsWeb && webImage != null)
                              ? Image.memory(
                                  webImage!,
                                  fit: BoxFit.cover,
                                )
                              : CachedNetworkImage(
                                  imageUrl: widget.profileUser.profileImageUrl,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.person,
                                    size: 72,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  imageBuilder: (context, imageProvider) =>
                                      Image(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Center(
                    child: ElevatedButton.icon(
                      onPressed: pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                      ),
                      icon: Icon(
                        Icons.image,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      label: Text(
                        "Pick Image",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text('Bio'),

                  const SizedBox(height: 5),

                  MyTextFields(
                    controller: bioTextController,
                    hintText: widget.profileUser.bio,
                    obscureText: false,
                  ),
                ],
              ),
            ),
          );
        } else {
          return ConstrainedScaffold(
            body: Center(
              child: Text(
                'Error loading profile',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          );
        }
      },
      listener: (context, state) {
        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        } else if (state is ProfileLoaded) {
          Navigator.pop(context);
        }
      },
    );
  }
}
