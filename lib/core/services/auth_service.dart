import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter/foundation.dart';

/// Firebase Authentication ve Google Sign In servisi
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;

  // Mevcut kullanıcı
  User? get currentUser => _auth.currentUser;

  // Kullanıcı stream'i
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Google ile giriş yap
  Future<UserCredential?> signInWithGoogle() async {
    try {
      debugPrint('🔐 Google Sign In başlatılıyor...');

      if (!_isGoogleSignInInitialized) {
        await _googleSignIn.initialize();
        _isGoogleSignInInitialized = true;
      }

      // Google Sign In akışını başlat
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      debugPrint('✅ Google hesabı seçildi: ${googleUser.email}');

      // Google kimlik bilgilerini al
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final GoogleSignInClientAuthorization? clientAuthz =
          await googleUser.authorizationClient.authorizationForScopes([]);

      debugPrint('🔑 Google authentication token alındı');

      // Firebase credential oluştur
      final credential = GoogleAuthProvider.credential(
        accessToken: clientAuthz?.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('🔐 Firebase credential oluşturuldu');

      // Firebase ile giriş yap
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      debugPrint('✅ Firebase Authentication başarılı');
      debugPrint('👤 Kullanıcı: ${userCredential.user?.displayName}');
      debugPrint('📧 Email: ${userCredential.user?.email}');

      return userCredential;
    } catch (e) {
      debugPrint('❌ Google Sign In hatası: $e');
      rethrow;
    }
  }

  /// Çıkış yap
  Future<void> signOut() async {
    try {
      debugPrint('🔐 Çıkış yapılıyor...');

      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);

      debugPrint('✅ Çıkış başarılı');
    } catch (e) {
      debugPrint('❌ Çıkış hatası: $e');
      rethrow;
    }
  }

  /// Email ile giriş yap
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      debugPrint('🔐 Email ile giriş yapılıyor: $email');

      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      debugPrint('✅ Email ile giriş başarılı');
      return userCredential;
    } catch (e) {
      debugPrint('❌ Email ile giriş hatası: $e');
      rethrow;
    }
  }

  /// Email ile kayıt ol
  Future<UserCredential?> registerWithEmail(
    String email,
    String password,
  ) async {
    try {
      debugPrint('🔐 Email ile kayıt olunuyor: $email');

      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      debugPrint('✅ Email ile kayıt başarılı');
      return userCredential;
    } catch (e) {
      debugPrint('❌ Email ile kayıt hatası: $e');
      rethrow;
    }
  }

  /// Şifre sıfırlama emaili gönder
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      debugPrint('📧 Şifre sıfırlama emaili gönderiliyor: $email');

      await _auth.sendPasswordResetEmail(email: email);

      debugPrint('✅ Şifre sıfırlama emaili gönderildi');
    } catch (e) {
      debugPrint('❌ Şifre sıfırlama emaili gönderme hatası: $e');
      rethrow;
    }
  }

  /// Kullanıcı giriş yapmış mı?
  bool get isSignedIn => currentUser != null;

  /// Kullanıcı email doğrulaması yaptı mı?
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  /// Email doğrulama emaili gönder
  Future<void> sendEmailVerification() async {
    try {
      if (currentUser != null && !isEmailVerified) {
        debugPrint('📧 Email doğrulama emaili gönderiliyor...');
        await currentUser!.sendEmailVerification();
        debugPrint('✅ Email doğrulama emaili gönderildi');
      }
    } catch (e) {
      debugPrint('❌ Email doğrulama emaili gönderme hatası: $e');
      rethrow;
    }
  }

  /// Kullanıcı profili güncelle
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      if (currentUser != null) {
        debugPrint('👤 Profil güncelleniyor...');
        await currentUser!.updateDisplayName(displayName);
        await currentUser!.updatePhotoURL(photoURL);
        await currentUser!.reload();
        debugPrint('✅ Profil güncellendi');
      }
    } catch (e) {
      debugPrint('❌ Profil güncelleme hatası: $e');
      rethrow;
    }
  }
}
