package com.example.untitled;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.widget.RemoteViews;

/**
 * Çoklu haber kartı widget'ı - en son 3 haberi listeler
 */
public class NewsListWidgetProvider extends AppWidgetProvider {

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }

    static void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.news_list_widget);

        try {
            String articlesJson = NewsWidgetProvider_getWidgetData(context, "articles");
            String[] articles = new String[0];
            if (articlesJson != null && !articlesJson.isEmpty()) {
                articles = articlesJson.split("\\|\\|\\|");
            }

            // İlk 3 haberi göster
            setItem(context, views, R.id.widget_list_title_1, articles, 0, appWidgetId);
            setItem(context, views, R.id.widget_list_title_2, articles, 1, appWidgetId);
            setItem(context, views, R.id.widget_list_title_3, articles, 2, appWidgetId);

        } catch (Exception e) {
            e.printStackTrace();
        }

        appWidgetManager.updateAppWidget(appWidgetId, views);
    }

    private static void setItem(Context context, RemoteViews views, int textViewId, String[] articles, int index, int appWidgetId) {
        if (articles.length > index) {
            String[] articleData = articles[index].split("\\|");
            String title = articleData.length > 0 ? articleData[0] : "";
            String link = articleData.length > 2 ? articleData[2] : "";

            views.setTextViewText(textViewId, title.isEmpty() ? "Haber bulunamadı" : title);

            if (link != null && !link.isEmpty()) {
                Intent clickIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(link));
                PendingIntent clickPendingIntent = PendingIntent.getActivity(
                    context, 100 + index, clickIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
                );
                views.setOnClickPendingIntent(textViewId, clickPendingIntent);
            }
        } else {
            views.setTextViewText(textViewId, "");
        }
    }

    // NewsWidgetProvider içindeki getWidgetData'nın sade kopyası (static helper)
    private static String NewsWidgetProvider_getWidgetData(Context context, String key) {
        try {
            android.content.SharedPreferences flutterPrefs = context.getSharedPreferences(
                "FlutterSharedPreferences",
                Context.MODE_PRIVATE
            );

            String fullKey = "flutter." + key;
            String value = flutterPrefs.getString(fullKey, null);
            if (value != null && !value.isEmpty()) {
                return value;
            }

            value = flutterPrefs.getString(key, null);
            if (value != null && !value.isEmpty()) {
                return value;
            }

            android.content.SharedPreferences groupPrefs = context.getSharedPreferences(
                "group.com.habermerkezi.widget",
                Context.MODE_PRIVATE
            );
            value = groupPrefs.getString(key, "");
            if (value != null && !value.isEmpty()) {
                return value;
            }

            return "";
        } catch (Exception e) {
            android.util.Log.e("NewsListWidget", "Error getting widget data for key: " + key, e);
            return "";
        }
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);

        if (intent.getAction() == null) return;

        if (intent.getAction().equals(AppWidgetManager.ACTION_APPWIDGET_UPDATE)) {
            AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
            ComponentName thisWidget = new ComponentName(context, NewsListWidgetProvider.class);
            int[] appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget);
            onUpdate(context, appWidgetManager, appWidgetIds);
        }
    }
}


