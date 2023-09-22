import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// This class provides authentication services using Firebase Authentication and Google Sign-In.
/// It contains methods for signing up and signing in with email and password, signing in with Google,
/// and signing out. It also has setters for user profile data such as email, password, and password confirmation.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  // User profile data
  String? email;
  String? password;
  String? passwordConfirmation;

  /// Sets the email for the user profile.
  void setEmail(String value) {
    email = value;
  }

  /// Sets the password for the user profile.
  void setPassword(String value) {
    password = value;
  }

  /// Sets the password confirmation for the user profile.
  void setPasswordConfirmation(String value) {
    passwordConfirmation = value;
  }

  /// Signs up the user with the given email and password.
  /// Returns the user if successful, otherwise returns null.
  /// Throws a FirebaseAuthException with code 'password-mismatch' and message 'รหัสผ่านไม่ตรงกัน' if the password and password confirmation do not match.
  Future<User?> signUp(
      String? email, String? password, String? passwordConfirmation) async {
    try {
      if (password != passwordConfirmation) {
        throw FirebaseAuthException(
          code: 'password-mismatch',
          message: 'รหัสผ่านไม่ตรงกัน',
        );
      }
      var result = await _auth.createUserWithEmailAndPassword(
          email: email!, password: password!);
      return result.user;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return null;
    }
  }

  /// Signs in the user with the given email and password.
  /// Returns the user if successful, otherwise returns null.
  Future<User?> signIn(
    String? email,
    String? password,
  ) async {
    try {
      var result = await _auth.signInWithEmailAndPassword(
          email: email!, password: password!);
      return result.user;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return null;
    }
  }

  /// Signs in the user with Google.
  /// Returns the user if successful, otherwise returns null.
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        var result = await _auth.signInWithCredential(credential);
        return result.user;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return null;
    }
  }

  /// Signs out the user.
  Future<void> signOut() async {
    await googleSignIn.signOut();
    await _auth.signOut();
  }
}
