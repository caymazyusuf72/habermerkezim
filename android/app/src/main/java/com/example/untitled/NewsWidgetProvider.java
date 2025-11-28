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
            
            // Ana haber başlığını ayarla
            if (title != null && !title.isEmpty()) {
                views.setTextViewText(R.id.widget_title, title);
            } else {
                views.setTextViewText(R.id.widget_title, "Son Haberler");
            }
            
            // Açıklama
            if (description != null && !description.isEmpty()) {
                // Açıklamayı kısalt (max 100 karakter)
                String shortDesc = description.length() > 100 
                    ? description.substring(0, 100) + "..." 
                    : description;
                views.setTextViewText(R.id.widget_description, shortDesc);
            } else {
                views.setTextViewText(R.id.widget_description, "Haberler yükleniyor...");
            }
            
            // Haber sayısı
            if (count != null && !count.isEmpty()) {
                views.setTextViewText(R.id.widget_count, count + " haber");
            }
            
            // İkinci haber
            if (title2 != null && !title2.isEmpty()) {
                String shortTitle2 = title2.length() > 50 ? title2.substring(0, 50) + "..." : title2;
                views.setTextViewText(R.id.widget_title2, shortTitle2);
                views.setViewVisibility(R.id.widget_title2, android.view.View.VISIBLE);
            } else {
                views.setViewVisibility(R.id.widget_title2, android.view.View.GONE);
            }
            
            // Üçüncü haber
            if (title3 != null && !title3.isEmpty()) {
                String shortTitle3 = title3.length() > 50 ? title3.substring(0, 50) + "..." : title3;
                views.setTextViewText(R.id.widget_title3, shortTitle3);
                views.setViewVisibility(R.id.widget_title3, android.view.View.VISIBLE);
            } else {
                views.setViewVisibility(R.id.widget_title3, android.view.View.GONE);
            }
            
            // Widget'a tıklandığında uygulamayı aç
            Intent intent = new Intent(context, MainActivity.class);
            PendingIntent pendingIntent = PendingIntent.getActivity(
                context, 0, intent, 
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent);
            
            // İkinci habere tıklandığında
            if (link2 != null && !link2.isEmpty()) {
                Intent intent2 = new Intent(Intent.ACTION_VIEW, Uri.parse(link2));
                PendingIntent pendingIntent2 = PendingIntent.getActivity(
                    context, 1, intent2,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
                );
                views.setOnClickPendingIntent(R.id.widget_title2, pendingIntent2);
            }
            
            // Üçüncü habere tıklandığında
            if (link3 != null && !link3.isEmpty()) {
                Intent intent3 = new Intent(Intent.ACTION_VIEW, Uri.parse(link3));
                PendingIntent pendingIntent3 = PendingIntent.getActivity(
                    context, 2, intent3,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
                );
                views.setOnClickPendingIntent(R.id.widget_title3, pendingIntent3);
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
            // home_widget paketi 'flutter.home_widget' adında SharedPreferences kullanır
            android.content.SharedPreferences prefs = context.getSharedPreferences(
                "flutter.home_widget", 
                Context.MODE_PRIVATE
            );
            return prefs.getString(key, "");
        } catch (Exception e) {
            return "";
        }
    }
    
    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);
        
        // Widget güncelleme isteği geldiğinde
        if (intent.getAction() != null && intent.getAction().equals(AppWidgetManager.ACTION_APPWIDGET_UPDATE)) {
            AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
            ComponentName thisWidget = new ComponentName(context, NewsWidgetProvider.class);
            int[] appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget);
            onUpdate(context, appWidgetManager, appWidgetIds);
        }
    }
}

