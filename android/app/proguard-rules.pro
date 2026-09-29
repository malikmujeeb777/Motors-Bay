# Flutter WebView rules
-keep class * extends androidx.webkit.WebViewClientCompat { *; }
-keepclassmembers class * extends androidx.webkit.WebViewClientCompat {
    <methods>;
}

# Keep JavaScript interfaces
-keepattributes JavascriptInterface
-keep class * extends android.webkit.JavascriptInterface { *; }
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# model_viewer_plus rules
-keep class com.google.ar.** { *; }
-keep class io.flutter.plugins.webviewflutter.** { *; }

# Don't obfuscate 3D model-related classes
-keep class org.khronos.** { *; }
-keep class com.google.android.filament.** { *; }

# Keep Flutter WebView platform interfaces
-keep class io.flutter.plugins.webviewflutter.** { *; }

# Keep GPU-related classes
-keep class android.opengl.** { *; }

# Flutter multidex support
-keep class androidx.multidex.** { *; }

# Keep native methods 
-keepclasseswithmembernames class * {
    native <methods>;
}

# For asset loading
-keepclassmembers class io.flutter.embedding.engine.loader.** { *; }

# General Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Don't warn about unused rules
-dontwarn org.khronos.**
-dontwarn com.google.ar.**
-dontwarn android.webkit.**
-dontwarn androidx.webkit.** 