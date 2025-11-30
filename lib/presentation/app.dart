import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/providers.dart';
import 'themes/app_theme.dart';
import 'pages/home/home_page.dart';
import 'pages/splash/splash_page.dart';

/// Ana uygulama widget'ı - Haber Merkezi
/// Riverpod ile state management ve theme management
class HaberMerkeziApp extends ConsumerWidget {
  const HaberMerkeziApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Theme durumunu izle
    final themeState = ref.watch(themeProvider);
    final themeMode = themeState.themeMode;
    final fontScale = themeState.fontScale;
    final colorTheme = themeState.colorTheme;
    
    // App initialization durumunu izle
    final appInitialization = ref.watch(appInitializationProvider);

    return MaterialApp(
      title: 'Haber Merkezim',
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false, // Performans overlay'i (gerekirse true yapılabilir)
      
      // Tema ayarları - font scale ve color theme ile birlikte
      theme: AppTheme.getLightTheme(fontScale, colorTheme),
      darkTheme: AppTheme.getDarkTheme(fontScale, colorTheme),
      themeMode: themeMode,
      
      // Localization ayarları
      locale: const Locale('tr', 'TR'),
      
      // Ana sayfa - initialization durumuna göre
      home: appInitialization.when(
        data: (_) {
          print('✅ App initialization tamamlandi, HomePage gosteriliyor');
          return const HomePage();
        },
        loading: () {
          print('⏳ App initialization devam ediyor, SplashPage gosteriliyor');
          return const SplashPage();
        },
        error: (error, stackTrace) {
          print('❌ App initialization hatasi: $error');
          return ErrorPage(
            error: error,
            onRetry: () {
              ref.invalidate(appInitializationProvider);
            },
          );
        },
      ),
      
      // Route ayarları (gelecekte navigation için)
      routes: {
        '/home': (context) => const HomePage(),
        '/splash': (context) => const SplashPage(),
      },
      
      // App boyut ve orientation ayarları
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            // Font scale'i provider'dan alınan değerle sınırla (deprecated textScaleFactor yerine textScaler)
            textScaler: TextScaler.linear(fontScale.clamp(0.8, 1.6)),
          ),
          child: child!,
        );
      },
    );
  }
}

/// Hata sayfası - uygulama başlatılamadığında gösterilir
class ErrorPage extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const ErrorPage({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hata ikonu
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade400,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Başlık
              Text(
                'Bir sorun oluştu',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Açıklama
              Text(
                'Haber Merkezi başlatılırken bir hata oluştu. Lütfen tekrar deneyin.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Hata detayı (debug modda)
              if (error.toString().isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade700,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              const SizedBox(height: 40),
              
              // Yeniden dene butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Yeniden Dene'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // İptal butonu
              TextButton(
                onPressed: () {
                  // Uygulamayı kapat
                  SystemNavigator.pop();
                },
                child: Text(
                  'Uygulamayı Kapat',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}