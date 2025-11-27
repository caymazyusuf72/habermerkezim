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
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animasyon controller'ı başlat
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Fade animasyonu
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Scale animasyonu
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    ));

    // Animasyonu başlat
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : Colors.white,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        AppTheme.darkBackground,
                        AppTheme.darkSurface,
                      ]
                    : [
                        Colors.white,
                        AppTheme.lightBackground,
                      ],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Spacer for centering
                  const Spacer(flex: 2),
                  
                  // Logo ve App İsmi
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        children: [
                          // App Icon/Logo
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryBlue,
                                  AppTheme.secondaryBlue,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryBlue.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.newspaper,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // App İsmi
                          Text(
                            'Haber Merkezi',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: isDark ? Colors.white : AppTheme.primaryBlue,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Alt başlık
                          Text(
                            'Güncel haberlerin merkezi',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isDark ? Colors.white70 : Colors.grey.shade600,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Spacer
                  const Spacer(flex: 1),
                  
                  // Loading Indicator
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        SpinKitThreeBounce(
                          color: isDark ? Colors.white : AppTheme.primaryBlue,
                          size: 30.0,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Text(
                          'Haberler yükleniyor...',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white60 : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Bottom spacer
                  const Spacer(flex: 1),
                  
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