import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Add the Google services Gradle plugin
    id("com.google.gms.google-services")
}

// Load keystore properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.untitled"
    compileSdk = 36  // Android 15 - Paket uyumluluğu için gerekli
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
        freeCompilerArgs += listOf("-Xlint:-options")
    }

    defaultConfig {
        // Application ID - Haber Merkezim
        // Not: namespace com.example.untitled olarak kalıyor çünkü Java dosyaları bu package'da
        // Ancak applicationId farklı olabilir (store'da görünen ID)
        applicationId = "com.habermerkezi.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // minSdk 21 = Android 5.0 (Lollipop) - %99+ cihaz desteği
        // minSdk 23 = Android 6.0 (Marshmallow) - home_widget ve glance paketleri için gerekli
        minSdk = flutter.minSdkVersion  // Android 6.0+ (Marshmallow) - %98+ cihaz desteği
        targetSdk = 34  // Android 14 - En son özellikler için
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Multi-dex desteği (eski cihazlar için)
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            var keyAliasValue = System.getenv("ANDROID_KEY_ALIAS") ?: keystoreProperties.getProperty("keyAlias")
            var keyPasswordValue = System.getenv("ANDROID_KEY_PASSWORD") ?: keystoreProperties.getProperty("keyPassword")
            var storeFileValue = System.getenv("ANDROID_KEYSTORE_PATH") ?: keystoreProperties.getProperty("storeFile")
            var storePasswordValue = System.getenv("ANDROID_STORE_PASSWORD") ?: keystoreProperties.getProperty("storePassword")

            if (!keyAliasValue.isNullOrBlank() &&
                !keyPasswordValue.isNullOrBlank() &&
                !storeFileValue.isNullOrBlank() &&
                !storePasswordValue.isNullOrBlank()
            ) {
                keyAlias = keyAliasValue
                keyPassword = keyPasswordValue
                storeFile = file(storeFileValue)
                storePassword = storePasswordValue
            }
        }
    }

    buildTypes {
        release {
            val hasEnvVars = !System.getenv("ANDROID_KEY_ALIAS").isNullOrBlank() && 
                             !System.getenv("ANDROID_KEY_PASSWORD").isNullOrBlank() && 
                             !System.getenv("ANDROID_KEYSTORE_PATH").isNullOrBlank() && 
                             !System.getenv("ANDROID_STORE_PASSWORD").isNullOrBlank()

            signingConfig = if (keystorePropertiesFile.exists() || hasEnvVars) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // Minification ve resource shrinking kapatıldı - text rendering sorununu önlemek için
            isMinifyEnabled = false
            isShrinkResources = false
            // ProGuard kuralları artık kullanılmıyor
            // proguardFiles(
            //     getDefaultProguardFile("proguard-android-optimize.txt"),
            //     "proguard-rules.pro"
            // )
        }
    }
}

dependencies {
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.8.0"))
    
    // Firebase products - BoM kullanıldığında version belirtmeye gerek yok
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-storage")
    
    // Core library desugaring - Java 8+ API'lerini eski Android sürümlerinde kullanmak için
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    
    // Multi-dex desteği - 64K method limitini aşmak için
    implementation("androidx.multidex:multidex:2.0.1")
}

configurations.all {
    resolutionStrategy {
        force("androidx.glance:glance-appwidget:1.1.1")
        force("androidx.glance:glance:1.1.1")
        force("androidx.glance:glance-material3:1.1.1")
    }
}

flutter {
    source = "../.."
}
