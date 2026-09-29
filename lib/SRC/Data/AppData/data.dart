

import 'package:motorsbay1/SRC/Data/AppData/app_initializer.dart';
import 'package:motorsbay1/SRC/Data/AppData/user_data.dart';

class Data with AppInitializer, UserData {
  Data._();

  // Static instance variable
  static final Data app = Data._();

  // Getter to access the instance
  factory Data() {
    return app;
  }
}
