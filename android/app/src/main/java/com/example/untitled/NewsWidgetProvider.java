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
            
            // Ana haber başlığı
            String title = getWidgetData(context, "title");
            String description = getWidgetData(context, "description");
            String link = getWidgetData(context, "link");
            String imageUrl = getWidgetData(context, "imageUrl");
            String count = getWidgetData(context, "count");
            
            // İkinci ve üçüncü haberler
            String title2 = getWidgetData(context, "title2");
            String link2 = getWidgetData(context, "link2");
            String title3 = getWidgetData(context, "title3");
            String link3 = getWidgetData(context, "link3");
            
            // Mevcut index'i al
            String currentIndexStr = getWidgetData(context, "currentIndex");
            int currentIndex = 0;
            try {
                currentIndex = Integer.parseInt(currentIndexStr != null ? currentIndexStr : "0");
            } catch (NumberFormatException e) {
                currentIndex = 0;
            }
            
            // Tüm haberleri al
            String articlesJson = getWidgetData(context, "articles");
            String[] articles = articlesJson != null && !articlesJson.isEmpty() 
                ? articlesJson.split("\\|\\|\\|") 
                : new String[0];
            
            // Mevcut haberi göster
            if (articles.length > 0 && currentIndex < articles.length) {
                String[] articleData = articles[currentIndex].split("\\|");
                if (articleData.length >= 3) {
                    title = articleData[0];
                    description = articleData.length > 1 ? articleData[1] : "";
                    link = articleData.length > 2 ? articleData[2] : "";
                }
            }
            
            // Ana haber başlığını ayarla
            if (title != null && !title.isEmpty() && !title.equals("Haber başlığı")) {
                views.setTextViewText(R.id.widget_title, title);
                android.util.Log.d("NewsWidget", "Title set: " + title.substring(0, Math.min(50, title.length())));
            } else {
                // Eğer articles'tan veri yoksa, direkt title ve description'ı kullan
                String directTitle = getWidgetData(context, "title");
                String directDesc = getWidgetData(context, "description");
                
                if (directTitle != null && !directTitle.isEmpty()) {
                    views.setTextViewText(R.id.widget_title, directTitle);
                    android.util.Log.d("NewsWidget", "Direct title set: " + directTitle.substring(0, Math.min(50, directTitle.length())));
                } else {
                    views.setTextViewText(R.id.widget_title, "Haber başlığı");
                }
                
                if (directDesc != null && !directDesc.isEmpty()) {
                    String shortDesc = directDesc.length() > 120 
                        ? directDesc.substring(0, 120) + "..." 
                        : directDesc;
                    views.setTextViewText(R.id.widget_description, shortDesc);
                    android.util.Log.d("NewsWidget", "Direct description set");
                } else {
                    views.setTextViewText(R.id.widget_description, "Haberler yükleniyor...");
                }
                return; // Direkt verileri kullandık, devam etme
            }
            
            // Açıklama
            if (description != null && !description.isEmpty()) {
                // Açıklamayı kısalt (max 120 karakter)
                String shortDesc = description.length() > 120 
                    ? description.substring(0, 120) + "..." 
                    : description;
                views.setTextViewText(R.id.widget_description, shortDesc);
                android.util.Log.d("NewsWidget", "Description set");
            } else {
                views.setTextViewText(R.id.widget_description, "Haberler yükleniyor...");
                android.util.Log.w("NewsWidget", "Description is empty");
            }
            
            // İndikatör (1/3 gibi)
            if (articles.length > 0) {
                String indicator = (currentIndex + 1) + "/" + articles.length;
                views.setTextViewText(R.id.widget_indicator, indicator);
            } else {
                views.setTextViewText(R.id.widget_indicator, "");
            }
            
            // Widget'a tıklandığında uygulamayı aç
            Intent intent = new Intent(context, MainActivity.class);
            if (link != null && !link.isEmpty()) {
                intent.setData(Uri.parse(link));
            }
            PendingIntent pendingIntent = PendingIntent.getActivity(
                context, 0, intent, 
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent);
            
            // Sonraki haber butonu
            Intent nextIntent = new Intent(context, NewsWidgetProvider.class);
            nextIntent.setAction("com.example.untitled.ACTION_NEXT");
            nextIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId);
            PendingIntent nextPendingIntent = PendingIntent.getBroadcast(
                context, 3, nextIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );
            views.setOnClickPendingIntent(R.id.widget_next_btn, nextPendingIntent);
            
            // Beğen butonu
            Intent favoriteIntent = new Intent(context, MainActivity.class);
            favoriteIntent.setAction("com.example.untitled.ACTION_FAVORITE");
            favoriteIntent.putExtra("link", link);
            PendingIntent favoritePendingIntent = PendingIntent.getActivity(
                context, 4, favoriteIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );
            views.setOnClickPendingIntent(R.id.widget_favorite_btn, favoritePendingIntent);
            
            // Kaydet butonu
            Intent bookmarkIntent = new Intent(context, MainActivity.class);
            bookmarkIntent.setAction("com.example.untitled.ACTION_BOOKMARK");
            bookmarkIntent.putExtra("link", link);
            PendingIntent bookmarkPendingIntent = PendingIntent.getActivity(
                context, 5, bookmarkIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );
            views.setOnClickPendingIntent(R.id.widget_bookmark_btn, bookmarkPendingIntent);
            
            // Paylaş butonu
            if (link != null && !link.isEmpty()) {
                Intent shareIntent = new Intent(Intent.ACTION_SEND);
                shareIntent.setType("text/plain");
                shareIntent.putExtra(Intent.EXTRA_SUBJECT, title != null ? title : "Haber");
                shareIntent.putExtra(Intent.EXTRA_TEXT, link);
                PendingIntent sharePendingIntent = PendingIntent.getActivity(
                    context, 6, Intent.createChooser(shareIntent, "Paylaş"),
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
                );
                views.setOnClickPendingIntent(R.id.widget_share_btn, sharePendingIntent);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        // Widget'ı güncelle
        appWidgetManager.updateAppWidget(appWidgetId, views);
    }
    
    /**
     * HomeWidget paketinin kullandığı SharedPreferences'tan veri çeker
     */
    private static String getWidgetData(Context context, String key) {
        try {
            // home_widget paketi 'group.com.habermerkezi.widget' adında SharedPreferences kullanır
            // AppGroupId ile aynı olmalı
            android.content.SharedPreferences prefs = context.getSharedPreferences(
                "group.com.habermerkezi.widget", 
                Context.MODE_PRIVATE
            );
            String value = prefs.getString(key, "");
            // Debug için log
            android.util.Log.d("NewsWidget", "Key: " + key + ", Value: " + (value != null && value.length() > 50 ? value.substring(0, 50) + "..." : value));
            return value != null ? value : "";
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
            android.content.SharedPreferences prefs = context.getSharedPreferences(
                "group.com.habermerkezi.widget", 
                Context.MODE_PRIVATE
            );
            String currentIndexStr = prefs.getString("currentIndex", "0");
            int currentIndex = 0;
            try {
                currentIndex = Integer.parseInt(currentIndexStr);
            } catch (NumberFormatException e) {
                currentIndex = 0;
            }
            
            // Toplam haber sayısını al
            String articlesJson = prefs.getString("articles", "");
            int totalArticles = articlesJson != null && !articlesJson.isEmpty() 
                ? articlesJson.split("\\|\\|\\|").length 
                : 0;
            
            // Sonraki habere geç (döngüsel)
            currentIndex = (currentIndex + 1) % totalArticles;
            if (totalArticles == 0) currentIndex = 0;
            
            // Yeni index'i kaydet
            prefs.edit().putString("currentIndex", String.valueOf(currentIndex)).apply();
            
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

