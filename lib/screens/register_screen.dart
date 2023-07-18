// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps, library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../models/profile.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  final formKey = GlobalKey<FormState>();
  late final VoidCallback? onPressed;
  Profile profile = Profile(email: '', password: '');

  @override
  Widget build(BuildContext context) {
    //
    return FutureBuilder(
        future: firebase,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: const Text("Error"),
              ),
              body: Center(
                child: Text("${snapshot.error}"),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                appBar: AppBar(
                  title: const Text("Create Account"),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(35.0),
                  child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Enter Email
                          const Text("Enter E-mail", style: TextStyle(fontSize: 20)),
                          TextFormField(
                            validator: MultiValidator([
                              RequiredValidator(errorText: "Pleasr Enter Email"),
                              EmailValidator(errorText: "Emai type worng")
                            ]),
                            keyboardType: TextInputType.emailAddress,
                            onSaved: (String? email) {
                              profile.email = email!;
                            },
                          ),
                          //Enter Password
                          const SizedBox(
                            height: 20,
                          ),
                          const Text("Enter Password", style: TextStyle(fontSize: 20)),
                          TextFormField(
                            validator: RequiredValidator(errorText: "Please Enter Password"),
                            obscureText: true,
                            onSaved: (String? password) {
                              profile.password = password!;
                            },
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              child: const Text(" Register", style: TextStyle(fontSize: 20)),
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  formKey.currentState?.save();
                                  try {
                                    await FirebaseAuth.instance
                                        .createUserWithEmailAndPassword(
                                            email: profile.email, password: profile.password)
                                        .then((value) {
                                      formKey.currentState?.reset();
                                      Fluttertoast.showToast(
                                          msg: " Create Account Succeed",
                                          gravity: ToastGravity.TOP);
                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context) {
                                        return const HomeScreen();
                                      }));
                                    });
                                  } on FirebaseAuthException catch (e) {
                                    print(e.code);
                                    String message;
                                    if (e.code == ' email-already-in-use') {
                                      message = "มีอีเมลนี้ในระบบแล้ว โปรดใช้อีเมลอื่น";
                                    } else if (e.code == ' weak-password') {
                                      message = "รหัสผ่านต้องมีความยาวมากกว่า 6 ตัวอักษร";
                                    } else {
                                      message = e.message!;
                                    }
                                    Fluttertoast.showToast(
                                        msg: message, gravity: ToastGravity.CENTER);
                                  }
                                  print("email = ${profile.email} password=${profile.password}");
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ));
          }
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
    //
  }
}
