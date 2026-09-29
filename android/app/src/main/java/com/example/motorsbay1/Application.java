package com.example.motorsbay1;

import androidx.multidex.MultiDexApplication;
import androidx.webkit.WebViewCompat;
import android.os.Build;
import android.content.Context;
import android.webkit.WebView;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;

public class Application extends MultiDexApplication {
    @Override
    public void onCreate() {
        super.onCreate();
        
        // Initialize WebView for better 3D model loading
        initializeWebView();
    }

    private void initializeWebView() {
        try {
            // Enable WebView debugging in debug builds
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                WebView.setWebContentsDebuggingEnabled(true);
            }
            
            // Pre-warm WebView to improve initial loading time
            new WebView(this).destroy();
            
            // Configure WebView data directory
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                String dataDirectoryPath = getApplicationContext().getDataDir().getPath();
                android.webkit.WebView.setDataDirectorySuffix("flutter_webview");
            }
        } catch (Exception e) {
            // Log error but don't crash
            e.printStackTrace();
        }
    }
    
    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        // Enable multidex support for Android versions < 5.0
        androidx.multidex.MultiDex.install(this);
    }
} 