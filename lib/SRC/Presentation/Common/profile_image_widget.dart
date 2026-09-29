import 'dart:io';

import 'package:motorsbay1/exports.dart';


final ValueNotifier profileImageNew = ValueNotifier<File?>(null);

class ProfileImageWidget extends StatelessWidget {
  ProfileImageWidget({
    super.key,
    required this.isEdit,
    this.profileImage,
  });
  final String? profileImage;
  final bool isEdit;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(BuildContext context, bool isCamera) async {
    try {
      XFile? pickedFile;
      if (isCamera) {
        bool hasPermission =
        await ApplicationPermissions().getCameraPermission();
        if (hasPermission) {
          pickedFile = await _picker.pickImage(source: ImageSource.camera);
        }
      } else {
        bool hasPermission =
        await ApplicationPermissions().getGalleryPermission();
        if (hasPermission) {
          pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        }
      }
      if (pickedFile != null) {
        profileImageNew.value = File(pickedFile.path);
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
        print('No image selected.');
      }
    } catch (e) {
      Navigator.pop(context);
      print('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SizedBox(
          height: 120,
          width: 120,
          child: ValueListenableBuilder(
              valueListenable: profileImageNew,
              builder: (context, value, child) {
                return Stack(
                  children: [
                    Center(
                      child: Container(
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.surface,
                          border: Border.all(color: Colors.white, width: 2),
                          image: value == null
                              ? DecorationImage(
                            image: AssetImage("assets/images/car14.png"),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: ClipOval(
                          child: value != null
                              ? Image.file(
                            value,
                            fit: BoxFit.cover,
                            width: 110,
                            height: 110,
                          )
                              : profileImage == null
                              ? Image.asset("assets/images/car14.png")
                              : CachedImage(
                            url: profileImage ?? "",
                            isCircle: true,
                          ),
                        ),
                      ),
                    ),
                    if (isEdit)
                      InkWell(
                        onTap: () {
                        },
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary,
                            ),
                            child: AssetImageWidget(url: "assets/icons/camera.svg")
                                .padAll(3),
                          ).padAll(10),
                        ),
                      )
                  ],
                );
              })),
    );
  }
}
