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
 * Haber Merkezi Ana Banner Widget Provider
 * Son haberleri home screen'de marquee ile gösterir
 * Sonraki haber ve duraklat/oynat butonları içerir
 */
public class NewsWidgetProvider extends AppWidgetProvider {
    private static final String TAG = "NewsWidgetProvider";
    private static final String ACTION_NEXT = "com.example.untitled.ACTION_NEXT";
    private static final String ACTION_PLAY_PAUSE = "com.example.untitled.ACTION_PLAY_PAUSE";

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }

    static void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.news_widget);

        try {
            // Mevcut index'i al
            String currentIndexStr = WidgetDataHelper.getWidgetData(context, "currentIndex");
            int currentIndex = 0;
            try {
                currentIndex = Integer.parseInt(currentIndexStr != null && !currentIndexStr.isEmpty() ? currentIndexStr : "0");
            } catch (NumberFormatException e) {
                currentIndex = 0;
            }

            // Makaleyi al
            String[][] articles = WidgetDataHelper.getArticles(context);
            String title = "";
            String link = "";

            if (articles.length > 0) {
                int safeIndex = currentIndex % articles.length;
                String[] article = articles[safeIndex];
                title = WidgetDataHelper.getTitle(article);
                link = WidgetDataHelper.getLink(article);
            } else {
                // Direkt key'lerden al (geriye uyumluluk)
                title = WidgetDataHelper.getWidgetData(context, "title");
                link = WidgetDataHelper.getWidgetData(context, "link");
            }

            // Başlık
            if (title != null && !title.isEmpty()) {
                views.setTextViewText(R.id.widget_title, title);
                views.setViewVisibility(R.id.widget_title, View.VISIBLE);
                views.setViewVisibility(R.id.widget_breaking_badge, View.VISIBLE);
            } else {
                views.setTextViewText(R.id.widget_title, "Haberler yükleniyor…");
                views.setViewVisibility(R.id.widget_breaking_badge, View.GONE);
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
                Intent intent = new Intent(context, MainActivity.class);
                PendingIntent pendingIntent = PendingIntent.getActivity(
                    context, 0, intent,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
                );
                views.setOnClickPendingIntent(R.id.widget_container, pendingIntent);
            }

            // Sonraki haber butonu
            Intent nextIntent = new Intent(context, NewsWidgetProvider.class);
            nextIntent.setAction(ACTION_NEXT);
            nextIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId);
            PendingIntent nextPendingIntent = PendingIntent.getBroadcast(
                context, 3, nextIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );
            views.setOnClickPendingIntent(R.id.widget_next_btn, nextPendingIntent);

            // Duraklat/Oynat butonu
            Intent playPauseIntent = new Intent(context, NewsWidgetProvider.class);
            playPauseIntent.setAction(ACTION_PLAY_PAUSE);
            playPauseIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId);
            PendingIntent playPausePendingIntent = PendingIntent.getBroadcast(
                context, 4, playPauseIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );
            views.setOnClickPendingIntent(R.id.widget_play_pause_btn, playPausePendingIntent);

            // Duraklat/Oynat ikonu
            String isPausedStr = WidgetDataHelper.getWidgetData(context, "isPaused");
            boolean isPaused = "true".equals(isPausedStr);
            if (isPaused) {
                views.setImageViewResource(R.id.widget_play_pause_btn, android.R.drawable.ic_media_play);
            } else {
                views.setImageViewResource(R.id.widget_play_pause_btn, android.R.drawable.ic_media_pause);
            }

        } catch (Exception e) {
            Log.e(TAG, "Error updating widget", e);
        }

        appWidgetManager.updateAppWidget(appWidgetId, views);
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);
        if (intent.getAction() == null) return;

        if (intent.getAction().equals(ACTION_NEXT)) {
            int appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID);

            String currentIndexStr = WidgetDataHelper.getWidgetData(context, "currentIndex");
            int currentIndex = 0;
            try {
                currentIndex = Integer.parseInt(currentIndexStr);
            } catch (NumberFormatException e) {
                currentIndex = 0;
            }

            String[][] articles = WidgetDataHelper.getArticles(context);
            int totalArticles = articles.length;
            currentIndex = totalArticles > 0 ? (currentIndex + 1) % totalArticles : 0;

            WidgetDataHelper.saveWidgetData(context, "currentIndex", String.valueOf(currentIndex));

            AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
            updateAppWidget(context, appWidgetManager, appWidgetId);

        } else if (intent.getAction().equals(ACTION_PLAY_PAUSE)) {
            int appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID);

            String isPausedStr = WidgetDataHelper.getWidgetData(context, "isPaused");
            boolean isPaused = "true".equals(isPausedStr);
            String newPausedState = isPaused ? "false" : "true";

            WidgetDataHelper.saveWidgetData(context, "isPaused", newPausedState);

            AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
            updateAppWidget(context, appWidgetManager, appWidgetId);

        } else if (intent.getAction().equals(AppWidgetManager.ACTION_APPWIDGET_UPDATE)) {
            AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
            ComponentName thisWidget = new ComponentName(context, NewsWidgetProvider.class);
            int[] appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget);
            onUpdate(context, appWidgetManager, appWidgetIds);
        }
    }
}
