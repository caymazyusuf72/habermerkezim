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
 * Medium Widget (4x2) — 3 haber listesi
 * Material Design 3 card tasarımı, header, haber resimleri ve tümünü gör butonu
 */
public class NewsWidgetMedium extends AppWidgetProvider {
    private static final String TAG = "NewsWidgetMedium";
    private static final String ACTION_REFRESH = "com.example.untitled.ACTION_MEDIUM_REFRESH";

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }

    static void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.widget_medium);

        try {
            String[][] articles = WidgetDataHelper.getArticles(context);

            // 3 haberi doldur
            setNewsItem(context, views, articles, 0,
                R.id.widget_medium_title1, R.id.widget_medium_source1, R.id.widget_medium_time1,
                R.id.widget_medium_item1, appWidgetId);

            setNewsItem(context, views, articles, 1,
                R.id.widget_medium_title2, R.id.widget_medium_source2, R.id.widget_medium_time2,
                R.id.widget_medium_item2, appWidgetId);

            setNewsItem(context, views, articles, 2,
                R.id.widget_medium_title3, R.id.widget_medium_source3, R.id.widget_medium_time3,
                R.id.widget_medium_item3, appWidgetId);

            // Yenile butonu
            Intent refreshIntent = new Intent(context, NewsWidgetMedium.class);
            refreshIntent.setAction(ACTION_REFRESH);
            refreshIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId);
            PendingIntent refreshPendingIntent = PendingIntent.getBroadcast(
                context, appWidgetId + 200, refreshIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );
            views.setOnClickPendingIntent(R.id.widget_medium_refresh, refreshPendingIntent);

            // Tümünü Gör butonu — uygulamayı aç
            Intent seeAllIntent = new Intent(context, MainActivity.class);
            PendingIntent seeAllPendingIntent = PendingIntent.getActivity(
                context, appWidgetId + 300, seeAllIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );
            views.setOnClickPendingIntent(R.id.widget_medium_see_all, seeAllPendingIntent);

        } catch (Exception e) {
            Log.e(TAG, "Error updating medium widget", e);
        }

        appWidgetManager.updateAppWidget(appWidgetId, views);
    }

    private static void setNewsItem(Context context, RemoteViews views, String[][] articles, int index,
            int titleId, int sourceId, int timeId, int containerId, int appWidgetId) {
        if (articles.length > index) {
            String[] article = articles[index];
            String title = WidgetDataHelper.getTitle(article);
            String link = WidgetDataHelper.getLink(article);
            String source = WidgetDataHelper.getSourceFromData(context, index);
            String time = WidgetDataHelper.getTimeFromData(context, index);

            views.setTextViewText(titleId, title.isEmpty() ? "Haber bulunamadı" : title);

            if (source != null && !source.isEmpty()) {
                views.setTextViewText(sourceId, source);
            }
            if (time != null && !time.isEmpty()) {
                views.setTextViewText(timeId, " · " + time);
            }

            // Tıklama — deep link
            if (link != null && !link.isEmpty()) {
                Intent clickIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(link));
                PendingIntent clickPendingIntent = PendingIntent.getActivity(
                    context, appWidgetId + 100 + index, clickIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
                );
                views.setOnClickPendingIntent(containerId, clickPendingIntent);
            }
        } else {
            views.setTextViewText(titleId, "");
            views.setViewVisibility(containerId, View.GONE);
        }
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);
        if (intent.getAction() == null) return;

        if (intent.getAction().equals(ACTION_REFRESH) ||
            intent.getAction().equals(AppWidgetManager.ACTION_APPWIDGET_UPDATE)) {
            AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
            ComponentName thisWidget = new ComponentName(context, NewsWidgetMedium.class);
            int[] appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget);
            onUpdate(context, appWidgetManager, appWidgetIds);
        }
    }
}