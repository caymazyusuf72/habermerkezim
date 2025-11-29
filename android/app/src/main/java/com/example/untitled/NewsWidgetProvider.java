package com.example.untitled;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.widget.RemoteViews;

import com.example.untitled.MainActivity;

/**
 * Haber Merkezi Android Widget Provider
 * Son haberleri home screen'de gösterir
 */
public class NewsWidgetProvider extends AppWidgetProvider {
    
    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }
    
    static void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        // Widget layout'unu yükle
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.news_widget);
        
        // HomeWidget paketinden verileri al
        try {
            // SharedPreferences veya HomeWidget'dan veri çekme
            // Bu örnekte basit bir yapı kullanıyoruz
            // Gerçek uygulamada home_widget paketi SharedPreferences kullanır
            
            // Önce direkt title ve description'ı al (en güvenilir yöntem)
            String title = getWidgetData(context, "title");
            String description = getWidgetData(context, "description");
            String link = getWidgetData(context, "link");
            String imageUrl = getWidgetData(context, "imageUrl");
            String count = getWidgetData(context, "count");
            
            android.util.Log.d("NewsWidget", "Direct data - Title: " + (title != null && title.length() > 30 ? title.substring(0, 30) + "..." : title));
            android.util.Log.d("NewsWidget", "Direct data - Description: " + (description != null && description.length() > 30 ? description.substring(0, 30) + "..." : description));
            
            // Mevcut index'i al
            String currentIndexStr = getWidgetData(context, "currentIndex");
            int currentIndex = 0;
            try {
                currentIndex = Integer.parseInt(currentIndexStr != null && !currentIndexStr.isEmpty() ? currentIndexStr : "0");
            } catch (NumberFormatException e) {
                currentIndex = 0;
            }
            
            // Tüm haberleri al (kaydırma için)
            String articlesJson = getWidgetData(context, "articles");
            String[] articles = new String[0];
            if (articlesJson != null && !articlesJson.isEmpty()) {
                articles = articlesJson.split("\\|\\|\\|");
                android.util.Log.d("NewsWidget", "Articles array length: " + articles.length);
                
                // Eğer articles'tan veri varsa ve direkt title boşsa, articles'tan al
                if ((title == null || title.isEmpty()) && articles.length > 0 && currentIndex < articles.length) {
                    String[] articleData = articles[currentIndex].split("\\|");
                    if (articleData.length >= 3) {
                        title = articleData[0];
                        description = articleData.length > 1 ? articleData[1] : "";
                        link = articleData.length > 2 ? articleData[2] : "";
                        android.util.Log.d("NewsWidget", "Using data from articles array");
                    }
                }
            }
            
            // Ana haber başlığını ayarla (marquee efekti için)
            // Eğer title boşsa, articles'tan al
            if ((title == null || title.isEmpty() || title.equals("Haber başlığı")) && articles.length > 0 && currentIndex < articles.length) {
                String[] articleData = articles[currentIndex].split("\\|");
                if (articleData.length >= 3) {
                    title = articleData[0];
                    description = articleData.length > 1 ? articleData[1] : "";
                    link = articleData.length > 2 ? articleData[2] : "";
                    android.util.Log.d("NewsWidget", "Using data from articles array, index: " + currentIndex);
                }
            }
            
            if (title != null && !title.isEmpty() && !title.equals("Haber başlığı")) {
                views.setTextViewText(R.id.widget_title, title);
                // Marquee efekti için focusable yap
                views.setViewVisibility(R.id.widget_title, android.view.View.VISIBLE);
                android.util.Log.d("NewsWidget", "✅ Title set: " + (title.length() > 50 ? title.substring(0, 50) + "..." : title));
            } else {
                views.setTextViewText(R.id.widget_title, "Haberler yükleniyor...");
                android.util.Log.w("NewsWidget", "⚠️ Title is empty or default");
            }
            
            // "SON DAKİKA" rozetini göster/gizle
            if (title != null && !title.isEmpty() && !title.equals("Haber başlığı") && !title.equals("Haberler yükleniyor...")) {
                views.setViewVisibility(R.id.widget_breaking_badge, android.view.View.VISIBLE);
            } else {
                views.setViewVisibility(R.id.widget_breaking_badge, android.view.View.GONE);
            }
            
            // Widget'a tıklandığında haber detayına git
            if (link != null && !link.isEmpty()) {
                Intent clickIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(link));
                PendingIntent clickPendingIntent = PendingIntent.getActivity(
                    context, 0, clickIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
                );
                views.setOnClickPendingIntent(R.id.widget_container, clickPendingIntent);
            } else {
                // Link yoksa uygulamayı aç
                Intent intent = new Intent(context, MainActivity.class);
                PendingIntent pendingIntent = PendingIntent.getActivity(
                    context, 0, intent, 
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
                );
                views.setOnClickPendingIntent(R.id.widget_container, pendingIntent);
            }
            
            // Sonraki haber butonu
            Intent nextIntent = new Intent(context, NewsWidgetProvider.class);
            nextIntent.setAction("com.example.untitled.ACTION_NEXT");
            nextIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId);
            PendingIntent nextPendingIntent = PendingIntent.getBroadcast(
                context, 3, nextIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );
            views.setOnClickPendingIntent(R.id.widget_next_btn, nextPendingIntent);
            
            // Duraklat/Oynat butonu
            Intent playPauseIntent = new Intent(context, NewsWidgetProvider.class);
            playPauseIntent.setAction("com.example.untitled.ACTION_PLAY_PAUSE");
            playPauseIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId);
            PendingIntent playPausePendingIntent = PendingIntent.getBroadcast(
                context, 4, playPauseIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );
            views.setOnClickPendingIntent(R.id.widget_play_pause_btn, playPausePendingIntent);
            
            // Duraklat/Oynat durumunu kontrol et ve ikonu ayarla
            String isPausedStr = getWidgetData(context, "isPaused");
            boolean isPaused = "true".equals(isPausedStr);
            if (isPaused) {
                views.setImageViewResource(R.id.widget_play_pause_btn, android.R.drawable.ic_media_play);
            } else {
                views.setImageViewResource(R.id.widget_play_pause_btn, android.R.drawable.ic_media_pause);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        // Widget'ı güncelle
        appWidgetManager.updateAppWidget(appWidgetId, views);
    }
    
    /**
     * HomeWidget / shared_preferences ile kaydedilen veriyi okur.
     *
     * HomeWidget.saveWidgetData<String>('title', ...) çağrıları, Android tarafında
     * genellikle "FlutterSharedPreferences" isimli SharedPreferences içinde
     * "flutter.title" şeklinde bir key ile saklanır.
     */
    private static String getWidgetData(Context context, String key) {
        try {
            // Önce shared_preferences'in kullandığı dosyadan okumayı dene
            android.content.SharedPreferences flutterPrefs = context.getSharedPreferences(
                "FlutterSharedPreferences",
                Context.MODE_PRIVATE
            );

            String fullKey = "flutter." + key;
            String value = flutterPrefs.getString(fullKey, null);

            if (value != null && !value.isEmpty()) {
                android.util.Log.d("NewsWidget", "Key: " + fullKey + " found in FlutterSharedPreferences, length: " + value.length());
                return value;
            }

            // Eski/direkt key ile de dene (geri uyumluluk)
            value = flutterPrefs.getString(key, null);
            if (value != null && !value.isEmpty()) {
                android.util.Log.d("NewsWidget", "Key: " + key + " found in FlutterSharedPreferences (direct), length: " + value.length());
                return value;
            }

            // Son çare: appGroupId ile oluşturulmuş özel prefs adını dene
            android.content.SharedPreferences groupPrefs = context.getSharedPreferences(
                "group.com.habermerkezi.widget",
                Context.MODE_PRIVATE
            );
            value = groupPrefs.getString(key, "");
            if (value != null && !value.isEmpty()) {
                android.util.Log.d("NewsWidget", "Key: " + key + " found in group prefs, length: " + value.length());
                return value;
            }

            android.util.Log.w("NewsWidget", "Key: " + key + " not found in any SharedPreferences");
            return "";
        } catch (Exception e) {
            android.util.Log.e("NewsWidget", "Error getting widget data for key: " + key, e);
            return "";
        }
    }
    
    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);
        
        if (intent.getAction() == null) return;
        
        // Sonraki haber butonuna tıklandığında
        if (intent.getAction().equals("com.example.untitled.ACTION_NEXT")) {
            int appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID);
            
            // Mevcut index'i ve makale listesini oku
            String currentIndexStr = getWidgetData(context, "currentIndex");
            String articlesJson = getWidgetData(context, "articles");
            int currentIndex = 0;
            try {
                currentIndex = Integer.parseInt(currentIndexStr);
            } catch (NumberFormatException e) {
                currentIndex = 0;
            }
            
            int totalArticles = articlesJson != null && !articlesJson.isEmpty() 
                ? articlesJson.split("\\|\\|\\|").length 
                : 0;
            
            // Sonraki habere geç (döngüsel)
            currentIndex = (currentIndex + 1) % totalArticles;
            if (totalArticles == 0) currentIndex = 0;
            
            // Yeni index'i kaydet - Flutter tarafında okunacak şekilde "flutter.currentIndex"
            try {
                android.content.SharedPreferences flutterPrefs = context.getSharedPreferences(
                    "FlutterSharedPreferences",
                    Context.MODE_PRIVATE
                );
                flutterPrefs.edit()
                    .putString("flutter.currentIndex", String.valueOf(currentIndex))
                    .apply();
            } catch (Exception e) {
                android.util.Log.e("NewsWidget", "Error saving currentIndex", e);
            }
            
            // Widget'ı güncelle
            AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
        // Duraklat/Oynat butonuna tıklandığında
        else if (intent.getAction().equals("com.example.untitled.ACTION_PLAY_PAUSE")) {
            int appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID);
            
            // Mevcut durumu al (getWidgetData kullanarak)
            String isPausedStr = getWidgetData(context, "isPaused");
            if (isPausedStr == null || isPausedStr.isEmpty()) {
                isPausedStr = "false";
            }
            
            // Durumu tersine çevir
            boolean isPaused = "true".equals(isPausedStr);
            String newPausedState = isPaused ? "false" : "true";
            
            // Yeni durumu kaydet (hem flutter. prefix ile hem de direkt)
            try {
                android.content.SharedPreferences flutterPrefs = context.getSharedPreferences(
                    "FlutterSharedPreferences",
                    Context.MODE_PRIVATE
                );
                flutterPrefs.edit()
                    .putString("flutter.isPaused", newPausedState)
                    .putString("isPaused", newPausedState)
                    .apply();
                
                // Group prefs'e de kaydet
                android.content.SharedPreferences groupPrefs = context.getSharedPreferences(
                    "group.com.habermerkezi.widget",
                    Context.MODE_PRIVATE
                );
                groupPrefs.edit().putString("isPaused", newPausedState).apply();
            } catch (Exception e) {
                android.util.Log.e("NewsWidget", "Error saving isPaused", e);
            }
            
            // Widget'ı güncelle
            AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
        // Widget güncelleme isteği geldiğinde
        else if (intent.getAction().equals(AppWidgetManager.ACTION_APPWIDGET_UPDATE)) {
            AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
            ComponentName thisWidget = new ComponentName(context, NewsWidgetProvider.class);
            int[] appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget);
            onUpdate(context, appWidgetManager, appWidgetIds);
        }
    }
}

