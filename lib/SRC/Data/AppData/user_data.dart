
import 'package:motorsbay1/SRC/Domain/models/user_profile_model.dart';

mixin UserData {
  static String? userToken;

  static ProfileModel? userData;
  static bool? isLoginWithGoogle;

  // static Map<String, dynamic>? userHeaderData;
  //
  // set userHeader(Map<String, dynamic>? userHeader) =>
  //     userHeaderData = userHeader;

  set token(String? token) => userToken = token;
  set isGoogle(bool? isGoogle) => isLoginWithGoogle = isGoogle;

  set user(ProfileModel? userModel) => userData = userModel;

  ProfileModel? get user => userData;

  String? get token => userToken;

  bool? get isGoogle => isLoginWithGoogle;

// Map<String, dynamic>? get userHeader => userHeaderData;
}
