// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:type21/auth_service.dart';
import 'package:type21/models/profile.dart';
import 'package:type21/screens/main/select_screen.dart';
import 'package:type21/screens/reg_log_screen/home_screen.dart';

final Future<FirebaseApp> _firebase = Firebase.initializeApp();

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Profile _profile = Profile(email: '', password: '');
  final AuthService _auth = AuthService();

  Future<void> _registerAccount() async {
    final BuildContext ctx = context;

    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      try {
        final user = await _auth.signUp(
            _profile.email, _profile.password); // Use AuthService for sign-up

        if (user != null) {
          Fluttertoast.showToast(
            msg: "Create Account Succeeded",
            gravity: ToastGravity.TOP,
          );
          Navigator.pushReplacement(
            ctx,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          Fluttertoast.showToast(
            msg: "Registration failed",
            gravity: ToastGravity.CENTER,
          );
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'email-already-in-use') {
          message = "Email นี้มีบัญชีผู้ใช้แล้ว โปรดใช้ Email อื่น.";
        } else if (e.code == 'weak-password') {
          message = "รหัสผ่านต้องมีความยาวอย่างน้อย 8 ตัวอักษร.";
        } else {
          message = e.message!;
        }
        Fluttertoast.showToast(
          msg: message,
          gravity: ToastGravity.CENTER,
        );
        if (kDebugMode) {
          print("email = ${_profile.email}, password = ${_profile.password}");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _firebase,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Error"),
              backgroundColor: Colors.red,
            ),
            body: Center(
              child: Text("${snapshot.error}"),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                "สร้างบัญชีผู้ใช้",
                style: GoogleFonts.openSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.blue,
            ),
            body: Padding(
              padding: const EdgeInsets.all(35.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("ป้อน E-mail", style: TextStyle(fontSize: 20)),
                      TextFormField(
                        validator: MultiValidator([
                          RequiredValidator(errorText: "กรุณาป้อน E-mail"),
                          EmailValidator(errorText: "รูปแบบ E-mailไม่ถูกต้อง"),
                        ]),
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (String? email) {
                          _profile.email = email!;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text("ป้อนรหัสผ่าน",
                          style: TextStyle(fontSize: 20)),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: MultiValidator([
                          RequiredValidator(errorText: "กรุณาป้อนรหัสผ่าน"),
                          MinLengthValidator(8,
                              errorText: 'รหัสผ่านต้องมีมากกว่า 8 ตัวอักษร'),
                        ]),
                        obscureText: true,
                        onSaved: (String? password) {
                          _profile.password = password!;
                        },
                      ),
                      const Text("ป้อนรหัสผ่านอีกครั้ง",
                          style: TextStyle(fontSize: 20)),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (val) {
                          if (val?.isEmpty ?? true) {
                            return "กรุณาป้อนรหัสผ่านอีกครั้ง";
                          } else if (val != _profile.password) {
                            return "รหัสผ่านไม่ตรงกัน!";
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                          ),
                          onPressed: _registerAccount,
                          child: const Text('สร้างบัญชี'),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      //_buildGoogleSigninButton(),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildGoogleSigninButton() {
    return SizedBox(
      width: double.infinity,
      child: SignInButton(
        Buttons.Google,
        text:"Sign in with Google",
        onPressed: () async {
          final user = await _auth.signInWithGoogle();
          if (user != null) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const SelectScreen(locationList: []),
            ));
          } else {
            Fluttertoast.showToast(
              msg: "Google Sign-In failed",
              gravity: ToastGravity.CENTER,
            );
          }
        },
      ),
    );
  }
}
