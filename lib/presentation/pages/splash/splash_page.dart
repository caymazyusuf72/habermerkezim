import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
    
    // Ana animasyon controller
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Rotasyon animasyonu (logo için)
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
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
                        AppTheme.lightBackground,
                        AppTheme.lightSurface,
                        AppTheme.lightSurfaceVariant,
                      ],
              ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Üst boşluk (esnek)
                          SizedBox(height: constraints.maxHeight * 0.15),
                          
                          // Logo ve App İsmi
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Transform.rotate(
                                angle: _rotationAnimation.value,
                                child: Column(
                                  children: [
                                    // App Icon/Logo - Sofistike tasarım
                                    Container(
                                      width: 140,
                                      height: 140,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme.sageGreen,
                                            AppTheme.sageGreenLight,
                                            AppTheme.sageGreenDark,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.sageGreen.withOpacity(0.4),
                                            blurRadius: 30,
                                            spreadRadius: 5,
                                            offset: const Offset(0, 15),
                                          ),
                                          BoxShadow(
                                            color: isDark 
                                                ? AppTheme.matBlack.withOpacity(0.5)
                                                : Colors.black.withOpacity(0.1),
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
                                                color: Colors.white.withOpacity(0.2),
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
                                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                        color: isDark ? Colors.white : AppTheme.sageGreenDark,
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
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            color: isDark 
                                                ? Colors.white.withOpacity(0.8) 
                                                : AppTheme.sageGreenDark.withOpacity(0.7),
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
                          
                          // Orta boşluk
                          SizedBox(height: constraints.maxHeight * 0.12),
                          
                          // Loading Indicator - Modern ve akıcı
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                // Özel loading animasyonu
                                Container(
                                  width: 60,
                                  height: 60,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Dış daire
                                      SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            AppTheme.sageGreen,
                                          ),
                                          backgroundColor: AppTheme.sageGreen.withOpacity(0.2),
                                        ),
                                      ),
                                      // İç nokta
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: AppTheme.sageGreen,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.sageGreen.withOpacity(0.6),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 20),
                                
                                Text(
                                  'Haberler yükleniyor...',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDark 
                                        ? Colors.white.withOpacity(0.7) 
                                        : AppTheme.sageGreenDark.withOpacity(0.6),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Alt boşluk (esnek)
                          SizedBox(height: constraints.maxHeight * 0.15),
                          
                          // Version/Copyright
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 32),
                              child: Text(
                                'v1.0.0',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDark ? Colors.white38 : Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Splash page ile ilgili utility sınıfı
class SplashUtils {
  SplashUtils._();
  
  /// Minimum splash süresi
  static const Duration minSplashDuration = Duration(seconds: 2);
  
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