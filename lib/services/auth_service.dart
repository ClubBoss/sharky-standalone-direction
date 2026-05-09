import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService extends ChangeNotifier {
  FirebaseAuth? _auth;
  GoogleSignIn? _googleSignIn;

  FirebaseAuth? get _authOrNull {
    if (_auth != null) return _auth;
    if (Firebase.apps.isEmpty) return null;
    _auth = FirebaseAuth.instance;
    return _auth;
  }

  GoogleSignIn? get _googleSignInOrNull {
    if (_googleSignIn != null) return _googleSignIn;
    _googleSignIn = GoogleSignIn();
    return _googleSignIn;
  }

  User? get currentUser => _authOrNull?.currentUser;
  String? get uid => currentUser?.uid;
  String? get email => currentUser?.email;
  bool get isSignedIn => currentUser != null;

  Future<String?> signInAnonymously() async {
    final auth = _authOrNull;
    if (auth == null) return null;
    try {
      final cred = await auth.signInAnonymously();
      final user = cred.user;
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('anon_uid', user.uid);
      }
      notifyListeners();
      return user?.uid;
    } catch (_) {
      return null;
    }
  }

  Future<bool> signInWithGoogle() async {
    final auth = _authOrNull;
    final googleSignIn = _googleSignInOrNull;
    if (auth == null || googleSignIn == null) return false;
    try {
      final user = await googleSignIn.signIn();
      if (user == null) return false;
      final auth = await user.authentication;
      final cred = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      await _authOrNull?.signInWithCredential(cred);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> signInWithApple() async {
    final auth = _authOrNull;
    if (auth == null) return false;
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCred = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );
      await auth.signInWithCredential(oauthCred);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    final auth = _authOrNull;
    if (auth == null) return false;
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        try {
          await auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          notifyListeners();
          return true;
        } catch (_) {}
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> signOut() async {
    await _authOrNull?.signOut();
    await _googleSignInOrNull?.signOut();
    notifyListeners();
  }
}
