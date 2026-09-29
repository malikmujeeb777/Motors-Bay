import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:motorsbay1/SRC/Data/AppData/app_preferences.dart';
import 'package:motorsbay1/SRC/Data/AppData/data.dart';
import 'package:motorsbay1/SRC/Data/AppData/pref_keys.dart';

mixin AppInitializer {
  Future init() async {
    developer.log('Starting app initialization', name: 'AppInitializer');
    try {
      // Try to recover from any corrupted SharedPreferences data
      await _resetCorruptedPrefsIfNeeded();
      
      // Wait for user data initialization to complete
      await _user();
      
      developer.log('App initialization completed successfully', name: 'AppInitializer');
    } catch (e) {
      developer.log('Error during app initialization: $e', name: 'AppInitializer');
      // Fall back to clearing all data if there's an unrecoverable error
      await _emergencyDataReset();
    }
  }

  // Method to handle SharedPreferences initialization and user data loading
  static Future _user() async {
    developer.log('Initializing user data', name: 'AppInitializer');
    try {
      await _initializeSharedPrefs();
      String? token = await SharedPrefs.getLoginToken();
      developer.log("User token retrieved: ${token != null ? 'Found' : 'Not found'}", name: 'AppInitializer');
      
      var userData = await SharedPrefs.getUserData();
      developer.log("User data retrieved: ${userData != null ? 'Found' : 'Not found'}", name: 'AppInitializer');
    } catch (e) {
      developer.log("Error initializing user data: $e", name: 'AppInitializer');
      throw e; // Re-throw to be caught by the main init method
    }
  }

  static Future<void> _initializeSharedPrefs() async {
    developer.log('Initializing SharedPreferences', name: 'AppInitializer');
    try {
      await SharedPrefs.init();
      String? token = await SharedPrefs.getLoginToken();
      developer.log('User token retrieved: ${token != null ? 'Found' : 'Not found'}', name: 'AppInitializer');
      
      var userData = await SharedPrefs.getUserData();
      developer.log('User data retrieved: ${userData != null ? 'Found' : 'Not found'}', name: 'AppInitializer');
      
      developer.log('SharedPreferences initialized successfully', name: 'AppInitializer');
    } catch (e) {
      developer.log('Error initializing SharedPreferences: $e', name: 'AppInitializer');
      rethrow;
    }
  }

  // Method to detect and fix corrupted SharedPreferences
  static Future _resetCorruptedPrefsIfNeeded() async {
    developer.log('Checking for corrupted preferences', name: 'AppInitializer');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Set<String> keys = prefs.getKeys();
      developer.log('Found ${keys.length} SharedPreferences keys', name: 'AppInitializer');

      for (String key in keys) {
        try {
          if (key == PrefsKeys.USER_KEY || key == 'user' || key == PrefsKeys.TOKEN_KEY) {
            String? value = prefs.getString(key);
            if (value != null) {
              developer.log('Checking key $key for corruption', name: 'AppInitializer');
              
              // Check for pigeon data
              if (value.contains('pigeon')) {
                developer.log('Found pigeon data in $key - removing', name: 'AppInitializer');
                await prefs.remove(key);
                continue;
              }

              // Validate JSON
              try {
                if (key == PrefsKeys.USER_KEY || key == 'user') {
                  json.decode(value);
                  developer.log('Key $key contains valid JSON', name: 'AppInitializer');
                }
              } catch (e) {
                developer.log('Key $key contains invalid JSON - removing: $e', name: 'AppInitializer');
                await prefs.remove(key);
              }
            }
          }
        } catch (e) {
          developer.log('Error processing key $key: $e', name: 'AppInitializer');
        }
      }
      developer.log('Corrupted preferences check completed', name: 'AppInitializer');
    } catch (e) {
      developer.log('Error checking corrupted preferences: $e', name: 'AppInitializer');
    }
  }
  
  // Emergency reset if all else fails
  static Future _emergencyDataReset() async {
    developer.log('Starting emergency data reset', name: 'AppInitializer');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      developer.log("Emergency data reset completed", name: 'AppInitializer');
    } catch (e) {
      developer.log("Failed even emergency data reset: $e", name: 'AppInitializer');
    }
  }
}