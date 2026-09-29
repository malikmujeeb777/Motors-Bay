import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:motorsbay1/SRC/Data/AppData/data.dart';
import 'package:motorsbay1/SRC/Data/AppData/pref_keys.dart';
import 'package:motorsbay1/SRC/Domain/models/user_profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  // SharedPrefs._();

  /// reference of Shared Preferences
  static SharedPreferences? _preferences;

  /// Initialization of Shared Preferences
  static Future<void> init() async {
    developer.log('Initializing SharedPreferences', name: 'SharedPrefs');
    _preferences = await SharedPreferences.getInstance();
    developer.log('SharedPreferences initialized', name: 'SharedPrefs');
  }
  
  ///survey

  ///UserData stored in json
  ///userRawData will be in map<String,dynamic>
  static Future<bool> setUserLoginData({required Map<String, dynamic> userRawData}) async {
    developer.log('Setting user login data', name: 'SharedPrefs');
    try {
      // First validate the data
      if (userRawData.containsKey('id') && userRawData['id'] != null) {
        developer.log('User data contains valid ID', name: 'SharedPrefs');
      } else {
        developer.log('WARNING: User data missing or invalid ID', name: 'SharedPrefs');
      }

      // Convert to JSON string
      String userJson = json.encode(userRawData);
      developer.log('User data JSON created: ${userJson.substring(0, math.min(100, userJson.length))}...', name: 'SharedPrefs');

      // Save to both keys for compatibility
      bool result1 = await _preferences!.setString(PrefsKeys.USER_KEY, userJson);
      bool result2 = await _preferences!.setString('user', userJson);
      
      developer.log('User data saved to USER_KEY: $result1', name: 'SharedPrefs');
      developer.log('User data saved to user: $result2', name: 'SharedPrefs');

      return result1 && result2;
    } catch (e) {
      developer.log('Error saving user data: $e', name: 'SharedPrefs');
      return false;
    }
  }

  static Future setServiceProvider({required isServicePro}) async =>
      await _preferences?.setBool(
          PrefsKeys.isServiceProvider, isServicePro);

  ///store the login token when the user login
  static Future<bool> setLoginToken(String token) async {
    developer.log('Setting login token: $token', name: 'SharedPrefs');
    try {
      bool result = await _preferences!.setString(PrefsKeys.TOKEN_KEY, token);
      developer.log('Login token saved: $result', name: 'SharedPrefs');
      return result;
    } catch (e) {
      developer.log('Error saving login token: $e', name: 'SharedPrefs');
      return false;
    }
  }

  ///store userName of loged In user
  static Future setUserName(String name) async =>
      await _preferences!.setString(PrefsKeys.USER_NAME, name);

  ///store userName of loged In user
  static Future setLogInWithGoogle(bool isGoogle) async =>
      await _preferences!.setBool(PrefsKeys.Google_Account, isGoogle);

  /// get the stored UserToken
  static Future<String?> getLoginToken() async {
    developer.log('Getting login token', name: 'SharedPrefs');
    try {
      String? token = _preferences!.getString(PrefsKeys.TOKEN_KEY);
      developer.log('Login token retrieved: ${token != null ? 'exists' : 'null'}', name: 'SharedPrefs');
      return token;
    } catch (e) {
      developer.log('Error getting login token: $e', name: 'SharedPrefs');
      return null;
    }
  }

  /// get the stored UserToken
  static bool? getLogInWithGoogle() {
    Data.app.isGoogle = _preferences!.getBool(PrefsKeys.Google_Account);

    if (Data.app.isGoogle == true) {
      Data.app.isGoogle = Data.app.isGoogle;
    }
    return Data.app.isGoogle;
  }

  ///get user data future
  static Future<ProfileModel?> getUserData() async {
    developer.log('Getting user data', name: 'SharedPrefs');
    try {
      String? userJson;
      
      // First check the new standardized key
      if (_preferences!.containsKey(PrefsKeys.USER_KEY)) {
        userJson = _preferences!.getString(PrefsKeys.USER_KEY);
        developer.log('Found user data with PrefsKeys.USER_KEY', name: 'SharedPrefs');
      } 
      // Then fallback to the hardcoded key for backward compatibility
      else if (_preferences!.containsKey('user')) {
        userJson = _preferences!.getString("user");
        developer.log('Found user data with hardcoded user key', name: 'SharedPrefs');
      }
      
      if (userJson == null) {
        developer.log('No user data found', name: 'SharedPrefs');
        return null;
      }

      // Check for pigeon data
      if (userJson.contains('pigeon')) {
        developer.log('WARNING: Found pigeon data in user data', name: 'SharedPrefs');
        await _preferences!.remove(PrefsKeys.USER_KEY);
        await _preferences!.remove('user');
        return null;
      }

      try {
        Map<String, dynamic> userMap = json.decode(userJson);
        developer.log('User data parsed successfully', name: 'SharedPrefs');
        return ProfileModel.fromJson(userMap);
      } catch (e) {
        developer.log('Error parsing user data: $e', name: 'SharedPrefs');
        // Clean up corrupted data
        await _preferences!.remove(PrefsKeys.USER_KEY);
        await _preferences!.remove('user');
        return null;
      }
    } catch (e) {
      developer.log('Error getting user data: $e', name: 'SharedPrefs');
      return null;
    }
  }

  static bool? getIsServiceProvider() {


      final bool val =  _preferences!.getBool(PrefsKeys.isServiceProvider) ?? false;


    return val;
  }

  ///set user data
  static Future setUserData({required Map<String, dynamic> userRawData}) async {
    developer.log("Saving user data to SharedPreferences: ${jsonEncode(userRawData)}", name: 'SharedPrefs');
    // Save to both keys for backward compatibility
    await _preferences!.setString(PrefsKeys.USER_KEY, jsonEncode(userRawData));
    await _preferences!.setString('user', jsonEncode(userRawData));
    return true;
  }

  ///clear the user Data from shared preferences
  static Future<bool> clearUserData() async {
    developer.log('Clearing user data', name: 'SharedPrefs');
    try {
      await _preferences!.remove(PrefsKeys.USER_KEY);
      await _preferences!.remove('user');
      await _preferences!.remove(PrefsKeys.TOKEN_KEY);
      await _preferences!.remove(PrefsKeys.USER_NAME);
      await _preferences!.remove(PrefsKeys.Google_Account);
      developer.log('User data cleared successfully', name: 'SharedPrefs');
      return true;
    } catch (e) {
      developer.log('Error clearing user data: $e', name: 'SharedPrefs');
      return false;
    }
  }

  /// set the locale/language user selected
  static setLocale(localeVal) async {
    await _preferences?.setString(PrefsKeys.LOCALE_KEY, localeVal);
  }



  /// set the Current/user selected location
  static setCurrentLocation(currentLocation, int index) async {
    await _preferences?.setString(PrefsKeys.CURRENT_LOCATION, currentLocation);
    await _preferences?.setInt(PrefsKeys.LOCATION_INDEX, index);
  }

  /// Add static keys for direct access
  static String USER_KEY = PrefsKeys.USER_KEY;
  static String TOKEN_KEY = PrefsKeys.TOKEN_KEY;
  
  /// Helper to safely decode JSON strings
  static dynamic jsonDecode(String jsonString) {
    try {
      return json.decode(jsonString);
    } catch (e) {
      developer.log("Error decoding JSON: $e", name: 'SharedPrefs');
      return null;
    }
  }
}
