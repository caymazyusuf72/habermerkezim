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
     * HomeWidget paketinin kullandığı SharedPreferences'tan veri çeker
     * home_widget paketi genellikle "flutter.home_widget" key'ini kullanır
     */
    private static String getWidgetData(Context context, String key) {
        try {
            // Önce flutter.home_widget key'ini dene (home_widget paketinin varsayılan key'i)
            android.content.SharedPreferences prefs1 = context.getSharedPreferences(
                "flutter.home_widget", 
                Context.MODE_PRIVATE
            );
            String value1 = prefs1.getString(key, "");
            
            // Eğer bulunamazsa AppGroupId key'ini dene
            if (value1 == null || value1.isEmpty()) {
                android.content.SharedPreferences prefs2 = context.getSharedPreferences(
                    "group.com.habermerkezi.widget", 
                    Context.MODE_PRIVATE
                );
                String value2 = prefs2.getString(key, "");
                
                if (value2 != null && !value2.isEmpty()) {
                    android.util.Log.d("NewsWidget", "Key: " + key + " found in AppGroupId, Value length: " + value2.length());
                    return value2;
                }
            } else {
                android.util.Log.d("NewsWidget", "Key: " + key + " found in flutter.home_widget, Value length: " + value1.length());
                return value1;
            }
            
            // Debug için log
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
            
            // Mevcut index'i al
            android.content.SharedPreferences prefs1 = context.getSharedPreferences(
                "flutter.home_widget", 
                Context.MODE_PRIVATE
            );
            String currentIndexStr = prefs1.getString("currentIndex", "");
            
            if (currentIndexStr == null || currentIndexStr.isEmpty()) {
                android.content.SharedPreferences prefs2 = context.getSharedPreferences(
                    "group.com.habermerkezi.widget", 
                    Context.MODE_PRIVATE
                );
                currentIndexStr = prefs2.getString("currentIndex", "0");
            }
            int currentIndex = 0;
            try {
                currentIndex = Integer.parseInt(currentIndexStr);
            } catch (NumberFormatException e) {
                currentIndex = 0;
            }
            
            // Toplam haber sayısını al
            String articlesJson = prefs1.getString("articles", "");
            if (articlesJson == null || articlesJson.isEmpty()) {
                android.content.SharedPreferences prefs2 = context.getSharedPreferences(
                    "group.com.habermerkezi.widget", 
                    Context.MODE_PRIVATE
                );
                articlesJson = prefs2.getString("articles", "");
            }
            
            int totalArticles = articlesJson != null && !articlesJson.isEmpty() 
                ? articlesJson.split("\\|\\|\\|").length 
                : 0;
            
            // Sonraki habere geç (döngüsel)
            currentIndex = (currentIndex + 1) % totalArticles;
            if (totalArticles == 0) currentIndex = 0;
            
            // Yeni index'i kaydet (her iki SharedPreferences'a da)
            prefs1.edit().putString("currentIndex", String.valueOf(currentIndex)).apply();
            android.content.SharedPreferences prefs2 = context.getSharedPreferences(
                "group.com.habermerkezi.widget", 
                Context.MODE_PRIVATE
            );
            prefs2.edit().putString("currentIndex", String.valueOf(currentIndex)).apply();
            
            // Widget'ı güncelle
            AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
        // Duraklat/Oynat butonuna tıklandığında
        else if (intent.getAction().equals("com.example.untitled.ACTION_PLAY_PAUSE")) {
            int appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID);
            
            // Mevcut durumu al
            android.content.SharedPreferences prefs1 = context.getSharedPreferences(
                "flutter.home_widget", 
                Context.MODE_PRIVATE
            );
            String isPausedStr = prefs1.getString("isPaused", "false");
            
            if (isPausedStr == null || isPausedStr.isEmpty()) {
                android.content.SharedPreferences prefs2 = context.getSharedPreferences(
                    "group.com.habermerkezi.widget", 
                    Context.MODE_PRIVATE
                );
                isPausedStr = prefs2.getString("isPaused", "false");
            }
            
            // Durumu tersine çevir
            boolean isPaused = "true".equals(isPausedStr);
            String newPausedState = isPaused ? "false" : "true";
            
            // Yeni durumu kaydet
            prefs1.edit().putString("isPaused", newPausedState).apply();
            android.content.SharedPreferences prefs2 = context.getSharedPreferences(
                "group.com.habermerkezi.widget", 
                Context.MODE_PRIVATE
            );
            prefs2.edit().putString("isPaused", newPausedState).apply();
            
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

