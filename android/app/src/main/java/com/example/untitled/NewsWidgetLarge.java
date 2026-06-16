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

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/**
 * Large Widget (4x4) — Haber kartları + büyük resim
 * Material Design 3 elevated card tasarımı
 * Üstte büyük ana haber kartı (resim + gradient overlay + başlık)
 * Altta 3 küçük haber satırı
 */
public class NewsWidgetLarge extends AppWidgetProvider {
    private static final String TAG = "NewsWidgetLarge";
    private static final String ACTION_REFRESH = "com.example.untitled.ACTION_LARGE_REFRESH";

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }

    static void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.widget_large);

        try {
            String[][] articles = WidgetDataHelper.getArticles(context);

            // Tarih
            SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy", new Locale("tr"));
            views.setTextViewText(R.id.widget_large_date, sdf.format(new Date()));

            // Ana haber (index 0)
            if (articles.length > 0) {
                String[] mainArticle = articles[0];
                String title = WidgetDataHelper.getTitle(mainArticle);
                String link = WidgetDataHelper.getLink(mainArticle);
                String source = WidgetDataHelper.getSourceFromData(context, 0);
                String time = WidgetDataHelper.getTimeFromData(context, 0);

                views.setTextViewText(R.id.widget_large_main_title,
                    title.isEmpty() ? "Haberler yükleniyor…" : title);

                if (source != null && !source.isEmpty()) {
                    views.setTextViewText(R.id.widget_large_main_source, source);
                }
                if (time != null && !time.isEmpty()) {
                    views.setTextViewText(R.id.widget_large_main_time, " · " + time);
                }

                // SON DAKİKA rozeti
                String breakingFlag = WidgetDataHelper.getWidgetData(context, "isBreaking");
                if ("true".equals(breakingFlag)) {
                    views.setViewVisibility(R.id.widget_large_badge, View.VISIBLE);
                } else {
                    views.setViewVisibility(R.id.widget_large_badge, View.GONE);
                }

                // Ana haber tıklama
                if (link != null && !link.isEmpty()) {
                    Intent clickIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(link));
                    PendingIntent clickPendingIntent = PendingIntent.getActivity(
                        context, appWidgetId + 400, clickIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
                    );
                    views.setOnClickPendingIntent(R.id.widget_large_main_card, clickPendingIntent);
                }
            }

            // Alt haberler (index 1, 2, 3)
            setSubItem(context, views, articles, 1,
                R.id.widget_large_title2, R.id.widget_large_source2,
                R.id.widget_large_item2, appWidgetId);

            setSubItem(context, views, articles, 2,
                R.id.widget_large_title3, R.id.widget_large_source3,
                R.id.widget_large_item3, appWidgetId);

            setSubItem(context, views, articles, 3,
                R.id.widget_large_title4, R.id.widget_large_source4,
                R.id.widget_large_item4, appWidgetId);

            // Yenile butonu
            Intent refreshIntent = new Intent(context, NewsWidgetLarge.class);
            refreshIntent.setAction(ACTION_REFRESH);
            refreshIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId);
            PendingIntent refreshPendingIntent = PendingIntent.getBroadcast(
                context, appWidgetId + 500, refreshIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );
            views.setOnClickPendingIntent(R.id.widget_large_refresh, refreshPendingIntent);

        } catch (Exception e) {
            Log.e(TAG, "Error updating large widget", e);
        }

        appWidgetManager.updateAppWidget(appWidgetId, views);
    }

    private static void setSubItem(Context context, RemoteViews views, String[][] articles, int index,
            int titleId, int sourceId, int containerId, int appWidgetId) {
        if (articles.length > index) {
            String[] article = articles[index];
            String title = WidgetDataHelper.getTitle(article);
            String link = WidgetDataHelper.getLink(article);
            String source = WidgetDataHelper.getSourceFromData(context, index);

            views.setTextViewText(titleId, title.isEmpty() ? "" : title);
            if (source != null && !source.isEmpty()) {
                views.setTextViewText(sourceId, source);
            }

            views.setViewVisibility(containerId, View.VISIBLE);

            if (link != null && !link.isEmpty()) {
                Intent clickIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(link));
                PendingIntent clickPendingIntent = PendingIntent.getActivity(
                    context, appWidgetId + 400 + index, clickIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
                );
                views.setOnClickPendingIntent(containerId, clickPendingIntent);
            }
        } else {
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
            ComponentName thisWidget = new ComponentName(context, NewsWidgetLarge.class);
            int[] appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget);
            onUpdate(context, appWidgetManager, appWidgetIds);
        }
    }
}