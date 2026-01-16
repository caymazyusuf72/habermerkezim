import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase Authentication ve Google Sign In servisi
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Mevcut kullanıcı
  User? get currentUser => _auth.currentUser;

  // Kullanıcı stream'i
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Google ile giriş yap
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('🔐 Google Sign In başlatılıyor...');
      
      // Google Sign In akışını başlat
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('❌ Google Sign In iptal edildi');
        return null;
      }

      print('✅ Google hesabı seçildi: ${googleUser.email}');

      // Google kimlik bilgilerini al
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print('🔑 Google authentication token alındı');

      // Firebase credential oluştur
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🔐 Firebase credential oluşturuldu');

      // Firebase ile giriş yap
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      print('✅ Firebase Authentication başarılı');
      print('👤 Kullanıcı: ${userCredential.user?.displayName}');
      print('📧 Email: ${userCredential.user?.email}');

      return userCredential;
    } catch (e) {
      print('❌ Google Sign In hatası: $e');
      rethrow;
    }
  }

  /// Çıkış yap
  Future<void> signOut() async {
    try {
      print('🔐 Çıkış yapılıyor...');
      
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      
      print('✅ Çıkış başarılı');
    } catch (e) {
      print('❌ Çıkış hatası: $e');
      rethrow;
    }
  }

  /// Email ile giriş yap
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      print('🔐 Email ile giriş yapılıyor: $email');
      
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('✅ Email ile giriş başarılı');
      return userCredential;
    } catch (e) {
      print('❌ Email ile giriş hatası: $e');
      rethrow;
    }
  }

  /// Email ile kayıt ol
  Future<UserCredential?> registerWithEmail(String email, String password) async {
    try {
      print('🔐 Email ile kayıt olunuyor: $email');
      
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('✅ Email ile kayıt başarılı');
      return userCredential;
    } catch (e) {
      print('❌ Email ile kayıt hatası: $e');
      rethrow;
    }
  }

  /// Şifre sıfırlama emaili gönder
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      print('📧 Şifre sıfırlama emaili gönderiliyor: $email');
      
      await _auth.sendPasswordResetEmail(email: email);
      
      print('✅ Şifre sıfırlama emaili gönderildi');
    } catch (e) {
      print('❌ Şifre sıfırlama emaili gönderme hatası: $e');
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
        print('📧 Email doğrulama emaili gönderiliyor...');
        await currentUser!.sendEmailVerification();
        print('✅ Email doğrulama emaili gönderildi');
      }
    } catch (e) {
      print('❌ Email doğrulama emaili gönderme hatası: $e');
      rethrow;
    }
  }

  /// Kullanıcı profili güncelle
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      if (currentUser != null) {
        print('👤 Profil güncelleniyor...');
        await currentUser!.updateDisplayName(displayName);
        await currentUser!.updatePhotoURL(photoURL);
        await currentUser!.reload();
        print('✅ Profil güncellendi');
      }
    } catch (e) {
      print('❌ Profil güncelleme hatası: $e');
      rethrow;
    }
  }
}