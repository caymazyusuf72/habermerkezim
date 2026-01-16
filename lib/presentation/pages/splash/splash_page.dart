import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';

import '../../themes/app_theme.dart';

/// Splash Screen - Uygulama başlangıcında gösterilen yükleme ekranı
/// Hive initialization ve ilk veri yükleme sırasında gösterilir
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _rotationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Ana animasyon controller - Hızlandırıldı
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Rotasyon animasyonu (logo için) - Hızlandırıldı
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 3000), // 3 saniye
      vsync: this,
    )..repeat();

    // Fade animasyonu (staggered)
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeInOutCubic),
    ));

    // Scale animasyonu
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));

    // Rotasyon animasyonu
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1, // Hafif rotasyon
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    // Slide animasyonu (alt başlık için)
    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
    ));

    // Animasyonları başlat
    _mainAnimationController.forward();
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.matBlack : AppTheme.lightBackground,
      body: AnimatedBuilder(
        animation: Listenable.merge([_mainAnimationController, _rotationController]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        AppTheme.matBlack,
                        AppTheme.matBlackSurface,
                        AppTheme.matBlackSurfaceVariant,
                      ]
                    : [
                        // SpringRed teması ile pastel kırmızımsı gradyan
                        AppTheme.springRed.withValues(alpha: 0.1),
                        AppTheme.springRedLight.withValues(alpha: 0.15),
                        AppTheme.springRed.withValues(alpha: 0.08),
                        AppTheme.lightBackground,
                      ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Üst boşluk (esnek)
                    const Spacer(flex: 3),
                    
                    // Logo ve App İsmi - Merkeze hizalı
                    Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Transform.rotate(
                            angle: _rotationAnimation.value,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // App Icon/Logo - Sofistike tasarım
                                Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isDark
                                        ? [
                                            AppTheme.sageGreen,
                                            AppTheme.sageGreenLight,
                                            AppTheme.sageGreenDark,
                                          ]
                                        : [
                                            // SpringRed teması ile logo rengi
                                            AppTheme.springRed,
                                            AppTheme.springRedLight,
                                            AppTheme.springRedDark,
                                          ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDark
                                            ? AppTheme.sageGreen.withValues(alpha: 0.4)
                                            : AppTheme.springRed.withValues(alpha: 0.4),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                        offset: const Offset(0, 15),
                                      ),
                                      BoxShadow(
                                        color: isDark
                                            ? AppTheme.matBlack.withValues(alpha: 0.5)
                                            : Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // İç gölge efekti
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      // Icon
                                      const Icon(
                                        Icons.article_rounded,
                                        size: 70,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 32),
                                
                                // App İsmi - Merriweather font
                                Text(
                                  'Haber Merkezi',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    color: isDark ? Colors.white : AppTheme.springRedDark,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                
                                const SizedBox(height: 12),
                                
                                // Alt başlık - Slide animasyonu ile
                                Transform.translate(
                                  offset: Offset(0, _slideAnimation.value),
                                  child: Opacity(
                                    opacity: _fadeAnimation.value,
                                    child: Text(
                                      'Güncel haberlerin merkezi',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.8)
                                            : AppTheme.springRedDark.withValues(alpha: 0.7),
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Orta boşluk
                    const Spacer(flex: 2),
                    
                    // Lottie Animasyonu - NEWS animasyonu
                    Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Lottie NEWS animasyonu
                            SizedBox(
                              width: 300,
                              height: 150,
                              child: _buildLottieAnimation(),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            Text(
                              'Haberler yükleniyor...',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.7)
                                    : AppTheme.springRedDark.withValues(alpha: 0.6),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Alt boşluk (esnek)
                    const Spacer(flex: 3),
                    
                    // Version/Copyright - Merkeze hizalı
                    Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: Text(
                            'v1.0.0',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.white38 : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Lottie animasyonunu güvenli şekilde yükler
  Widget _buildLottieAnimation() {
    try {
      return Lottie.asset(
        'animation/News.json',
        fit: BoxFit.contain,
        repeat: true,
        animate: true,
        errorBuilder: (context, error, stackTrace) {
          // Lottie yüklenemezse alternatif loading göster
          return SpinKitFadingCircle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : AppTheme.sageGreen,
            size: 50,
          );
        },
      );
    } catch (e) {
      // Hata durumunda alternatif loading göster
      return SpinKitFadingCircle(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : AppTheme.sageGreen,
        size: 50,
      );
    }
  }
}

/// Splash page ile ilgili utility sınıfı
class SplashUtils {
  SplashUtils._();
  
  /// Minimum splash süresi - Hızlandırıldı
  static const Duration minSplashDuration = Duration(milliseconds: 500);
  
  /// Splash'i göster ve minimum süre bekle
  static Future<void> showSplashWithMinimumDuration(
    Future<void> initializationTask,
  ) async {
    final splashFuture = Future.delayed(minSplashDuration);
    
    // İkisini paralel çalıştır ve ikisi de bitene kadar bekle
    await Future.wait([
      initializationTask,
      splashFuture,
    ]);
  }
}