package com.example.untitled;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.untitled/widget";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("handleWidgetAction")) {
                    String action = call.argument("action");
                    String link = call.argument("link");
                    handleWidgetAction(action, link);
                    result.success(true);
                } else {
                    result.notImplemented();
                }
            });
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        handleIntent(getIntent());
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        handleIntent(intent);
    }

    private void handleIntent(Intent intent) {
        if (intent == null) return;
        
        String action = intent.getAction();
        if (action == null) return;
        
        if (action.equals("com.example.untitled.ACTION_FAVORITE")) {
            String link = intent.getStringExtra("link");
            handleWidgetAction("favorite", link);
        } else if (action.equals("com.example.untitled.ACTION_BOOKMARK")) {
            String link = intent.getStringExtra("link");
            handleWidgetAction("bookmark", link);
        } else if (intent.getData() != null) {
            // Widget'tan haber linki ile açıldı
            Uri data = intent.getData();
            if (data != null) {
                // Flutter tarafına haber linkini gönder
            }
        }
    }

    private void handleWidgetAction(String action, String link) {
        // Flutter tarafına action ve link'i gönder
        // Bu işlem Flutter tarafında favorites_provider ve reading_list_provider ile yapılacak
    }
}
