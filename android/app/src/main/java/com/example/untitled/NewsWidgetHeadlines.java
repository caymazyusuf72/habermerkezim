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
 * Headlines Widget (4x1) — Kayan haber başlıkları
 * ViewFlipper ile her 5 saniyede otomatik geçiş
 * Fade in/out animasyonu
 */
public class NewsWidgetHeadlines extends AppWidgetProvider {
    private static final String TAG = "NewsWidgetHeadlines";
    private static final String ACTION_NEXT = "com.example.untitled.ACTION_HEADLINES_NEXT";

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }

    static void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.widget_headlines);

        try {
            String[][] articles = WidgetDataHelper.getArticles(context);

            // 5 haberi doldur
            int[][] viewIds = {
                {R.id.widget_headline_title1, R.id.widget_headline_source1},
                {R.id.widget_headline_title2, R.id.widget_headline_source2},
                {R.id.widget_headline_title3, R.id.widget_headline_source3},
                {R.id.widget_headline_title4, R.id.widget_headline_source4},
                {R.id.widget_headline_title5, R.id.widget_headline_source5},
            };

            for (int i = 0; i < viewIds.length; i++) {
                if (articles.length > i) {
                    String title = WidgetDataHelper.getTitle(articles[i]);
                    String source = WidgetDataHelper.getSourceFromData(context, i);

                    views.setTextViewText(viewIds[i][0],
                        title.isEmpty() ? "Haberler yükleniyor…" : title);
                    if (source != null && !source.isEmpty()) {
                        views.setTextViewText(viewIds[i][1], source);
                    }
                } else {
                    views.setTextViewText(viewIds[i][0], "");
                    views.setTextViewText(viewIds[i][1], "");
                }
            }

            // Tüm widget tıklanınca — ilk haberin linkine git veya uygulamayı aç
            if (articles.length > 0) {
                String link = WidgetDataHelper.getLink(articles[0]);
                if (link != null && !link.isEmpty()) {
                    Intent clickIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(link));
                    PendingIntent clickPendingIntent = PendingIntent.getActivity(
                        context, appWidgetId + 600, clickIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
                    );
                    views.setOnClickPendingIntent(R.id.widget_headlines_flipper, clickPendingIntent);
                }
            }

            // İleri ok butonu — uygulamayı aç
            Intent appIntent = new Intent(context, MainActivity.class);
            PendingIntent appPendingIntent = PendingIntent.getActivity(
                context, appWidgetId + 700, appIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );
            views.setOnClickPendingIntent(R.id.widget_headlines_next, appPendingIntent);

        } catch (Exception e) {
            Log.e(TAG, "Error updating headlines widget", e);
        }

        appWidgetManager.updateAppWidget(appWidgetId, views);
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);
        if (intent.getAction() == null) return;

        if (intent.getAction().equals(ACTION_NEXT) ||
            intent.getAction().equals(AppWidgetManager.ACTION_APPWIDGET_UPDATE)) {
            AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
            ComponentName thisWidget = new ComponentName(context, NewsWidgetHeadlines.class);
            int[] appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget);
            onUpdate(context, appWidgetManager, appWidgetIds);
        }
    }
}