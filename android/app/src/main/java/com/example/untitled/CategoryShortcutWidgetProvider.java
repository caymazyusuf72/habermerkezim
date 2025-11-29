package com.example.untitled;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.widget.RemoteViews;

/**
 * Kategori kısayol widget'ı - Genel, Teknoloji, Ekonomi sekmelerine kısayol
 */
public class CategoryShortcutWidgetProvider extends AppWidgetProvider {

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }

    static void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.category_shortcut_widget);

        setClick(context, views, R.id.widget_cat_genel, "genel");
        setClick(context, views, R.id.widget_cat_teknoloji, "teknoloji");
        setClick(context, views, R.id.widget_cat_ekonomi, "ekonomi");

        appWidgetManager.updateAppWidget(appWidgetId, views);
    }

    private static void setClick(Context context, RemoteViews views, int viewId, String category) {
        Intent intent = new Intent(context, MainActivity.class);
        intent.putExtra("category", category);
        PendingIntent pendingIntent = PendingIntent.getActivity(
            context, category.hashCode(), intent,
            PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );
        views.setOnClickPendingIntent(viewId, pendingIntent);
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);

        if (intent.getAction() == null) return;

        if (intent.getAction().equals(AppWidgetManager.ACTION_APPWIDGET_UPDATE)) {
            AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
            ComponentName thisWidget = new ComponentName(context, CategoryShortcutWidgetProvider.class);
            int[] appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget);
            onUpdate(context, appWidgetManager, appWidgetIds);
        }
    }
}