package com.example.untitled;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;
import android.widget.RemoteViews;

/**
 * Çoklu haber kartı widget'ı - en son 3 haberi listeler
 * WidgetDataHelper kullanarak veri okur
 */
public class NewsListWidgetProvider extends AppWidgetProvider {
    private static final String TAG = "NewsListWidget";

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }

    static void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.news_list_widget);

        try {
            String[][] articles = WidgetDataHelper.getArticles(context);

            setItem(context, views, R.id.widget_list_title_1, articles, 0, appWidgetId);
            setItem(context, views, R.id.widget_list_title_2, articles, 1, appWidgetId);
            setItem(context, views, R.id.widget_list_title_3, articles, 2, appWidgetId);

        } catch (Exception e) {
            Log.e(TAG, "Error updating list widget", e);
        }

        appWidgetManager.updateAppWidget(appWidgetId, views);
    }

    private static void setItem(Context context, RemoteViews views, int textViewId,
            String[][] articles, int index, int appWidgetId) {
        if (articles.length > index) {
            String title = WidgetDataHelper.getTitle(articles[index]);
            String link = WidgetDataHelper.getLink(articles[index]);

            views.setTextViewText(textViewId, title.isEmpty() ? "Haber bulunamadı" : title);

            if (link != null && !link.isEmpty()) {
                Intent clickIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(link));
                PendingIntent clickPendingIntent = PendingIntent.getActivity(
                    context, appWidgetId + 100 + index, clickIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
                );
                views.setOnClickPendingIntent(textViewId, clickPendingIntent);
            }
        } else {
            views.setTextViewText(textViewId, "");
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
