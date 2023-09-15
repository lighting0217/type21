// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/profile.dart';
import 'home_screen.dart';

final Future<FirebaseApp> _firebase = Firebase.initializeApp();

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final Profile _profile = Profile(email: '', password: '');

  Future<void> _registerAccount() async {
    final BuildContext ctx = context;

    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _profile.email,
          password: _profile.password,
        );
        Fluttertoast.showToast(
          msg: "Create Account Succeeded",
          gravity: ToastGravity.TOP,
        );
        Navigator.pushReplacement(
          ctx,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
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
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text("ป้อนรหัสผ่าน",
                          style: TextStyle(fontSize: 20)),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
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
                            backgroundColor: Colors.blue, // Text color
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(10), // Rounded corners
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15), // Button padding
                          ),
                          onPressed: _registerAccount,
                          child: const Text('สร้างบัญชี'),
                        ),
                      ),
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
}
