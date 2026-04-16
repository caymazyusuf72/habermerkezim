package com.example.untitled;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;
import android.view.View;
import android.widget.RemoteViews;

/**
 * Small Widget (2x1) — Tek haber başlığı
 * Gradient arka plan, uygulama ikonu, haber başlığı, kaynak ve zaman bilgisi
 */
public class NewsWidgetSmall extends AppWidgetProvider {
    private static final String TAG = "NewsWidgetSmall";

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }

    static void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.widget_small);

        try {
            // İlk haberi al
            String[] article = WidgetDataHelper.getArticle(context, 0);
            String title = WidgetDataHelper.getTitle(article);
            String link = WidgetDataHelper.getLink(article);
            String source = WidgetDataHelper.getSourceFromData(context, 0);
            String time = WidgetDataHelper.getTimeFromData(context, 0);

            // Başlık
            if (title != null && !title.isEmpty()) {
                views.setTextViewText(R.id.widget_small_title, title);
            } else {
                views.setTextViewText(R.id.widget_small_title, "Haberler yükleniyor…");
            }

            // Kaynak
            if (source != null && !source.isEmpty()) {
                views.setTextViewText(R.id.widget_small_source, source);
                views.setViewVisibility(R.id.widget_small_source, View.VISIBLE);
            }

            // Zaman
            if (time != null && !time.isEmpty()) {
                views.setTextViewText(R.id.widget_small_time, time);
                views.setViewVisibility(R.id.widget_small_time, View.VISIBLE);
                views.setViewVisibility(R.id.widget_small_dot, View.VISIBLE);
            }

            // Tıklama — deep link ile haber detaya gitme
            if (link != null && !link.isEmpty()) {
                Intent clickIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(link));
                PendingIntent clickPendingIntent = PendingIntent.getActivity(
                    context, appWidgetId, clickIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
                );
                views.setOnClickPendingIntent(R.id.widget_small_container, clickPendingIntent);
            } else {
                // Link yoksa uygulamayı aç
                Intent intent = new Intent(context, MainActivity.class);
                PendingIntent pendingIntent = PendingIntent.getActivity(
                    context, appWidgetId, intent,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
                );
                views.setOnClickPendingIntent(R.id.widget_small_container, pendingIntent);
            }

        } catch (Exception e) {
            Log.e(TAG, "Error updating small widget", e);
            views.setTextViewText(R.id.widget_small_title, "Haberler yükleniyor…");
        }

        appWidgetManager.updateAppWidget(appWidgetId, views);
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);
        if (intent.getAction() != null && intent.getAction().equals(AppWidgetManager.ACTION_APPWIDGET_UPDATE)) {
            AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
            ComponentName thisWidget = new ComponentName(context, NewsWidgetSmall.class);
            int[] appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget);
            onUpdate(context, appWidgetManager, appWidgetIds);
        }
    }
}