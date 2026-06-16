package com.example.untitled;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

/**
 * Widget provider'lar arası paylaşılan veri erişim yardımcısı.
 * SharedPreferences'tan Flutter tarafından kaydedilen verileri okur.
 */
public class WidgetDataHelper {
    private static final String TAG = "WidgetDataHelper";

    /**
     * Flutter / home_widget paketinden kaydedilen veriyi okur.
     * Önce "FlutterSharedPreferences" dosyasından "flutter.KEY" ile,
     * sonra direkt KEY ile, son olarak group prefs'ten dener.
     */
    public static String getWidgetData(Context context, String key) {
        try {
            SharedPreferences flutterPrefs = context.getSharedPreferences(
                "FlutterSharedPreferences",
                Context.MODE_PRIVATE
            );

            // 1. flutter.KEY ile dene
            String fullKey = "flutter." + key;
            String value = flutterPrefs.getString(fullKey, null);
            if (value != null && !value.isEmpty()) {
                return value;
            }

            // 2. Direkt KEY ile dene
            value = flutterPrefs.getString(key, null);
            if (value != null && !value.isEmpty()) {
                return value;
            }

            // 3. Group prefs ile dene
            SharedPreferences groupPrefs = context.getSharedPreferences(
                "group.com.habermerkezi.widget",
                Context.MODE_PRIVATE
            );
            value = groupPrefs.getString(key, "");
            if (value != null && !value.isEmpty()) {
                return value;
            }

            return "";
        } catch (Exception e) {
            Log.e(TAG, "Error getting widget data for key: " + key, e);
            return "";
        }
    }

    /**
     * SharedPreferences'a veri kaydeder (Flutter tarafında da okunabilir).
     */
    public static void saveWidgetData(Context context, String key, String value) {
        try {
            SharedPreferences flutterPrefs = context.getSharedPreferences(
                "FlutterSharedPreferences",
                Context.MODE_PRIVATE
            );
            flutterPrefs.edit()
                .putString("flutter." + key, value)
                .putString(key, value)
                .apply();

            SharedPreferences groupPrefs = context.getSharedPreferences(
                "group.com.habermerkezi.widget",
                Context.MODE_PRIVATE
            );
            groupPrefs.edit().putString(key, value).apply();
        } catch (Exception e) {
            Log.e(TAG, "Error saving widget data for key: " + key, e);
        }
    }

    /**
     * Articles dizisini SharedPreferences'tan okur ve parse eder.
     * Her makale: title|description|link|imageUrl formatında,
     * makaleler ||| ile ayrılmış.
     */
    public static String[][] getArticles(Context context) {
        String articlesJson = getWidgetData(context, "articles");
        if (articlesJson == null || articlesJson.isEmpty()) {
            return new String[0][];
        }

        String[] articleStrings = articlesJson.split("\\|\\|\\|");
        String[][] articles = new String[articleStrings.length][];
        for (int i = 0; i < articleStrings.length; i++) {
            articles[i] = articleStrings[i].split("\\|");
        }
        return articles;
    }

    /**
     * Belirli bir indeksteki makale verisini döner.
     * @return [title, description, link, imageUrl] veya null
     */
    public static String[] getArticle(Context context, int index) {
        String[][] articles = getArticles(context);
        if (articles.length > index) {
            return articles[index];
        }
        return null;
    }

    /** Makale başlığını döner */
    public static String getTitle(String[] article) {
        return (article != null && article.length > 0) ? article[0] : "";
    }

    /** Makale açıklamasını döner */
    public static String getDescription(String[] article) {
        return (article != null && article.length > 1) ? article[1] : "";
    }

    /** Makale linkini döner */
    public static String getLink(String[] article) {
        return (article != null && article.length > 2) ? article[2] : "";
    }

    /** Makale resim URL'ini döner */
    public static String getImageUrl(String[] article) {
        return (article != null && article.length > 3) ? article[3] : "";
    }

    /**
     * Kaynak adını başlıktan veya açıklamadan çıkarmaya çalışır.
     * Eğer bulamazsa "Haber Merkezi" döner.
     */
    public static String getSourceFromData(Context context, int index) {
        String sourcesData = getWidgetData(context, "sources");
        if (sourcesData != null && !sourcesData.isEmpty()) {
            String[] sources = sourcesData.split("\\|\\|\\|");
            if (sources.length > index) {
                return sources[index];
            }
        }
        return "Haber Merkezi";
    }

    /**
     * Zaman bilgisini SharedPreferences'tan alır.
     */
    public static String getTimeFromData(Context context, int index) {
        String timesData = getWidgetData(context, "times");
        if (timesData != null && !timesData.isEmpty()) {
            String[] times = timesData.split("\\|\\|\\|");
            if (times.length > index) {
                return times[index];
            }
        }
        return "";
    }
}