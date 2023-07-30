import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/profile.dart';
import 'select_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  final formKey = GlobalKey<FormState>();
  Profile profile = Profile(email: '', password: '');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebase,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Error"),
              backgroundColor: Colors.red, // Change app bar color
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
                "Login to your Account",
                style: GoogleFonts.openSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.blue, // Change app bar color
            ),
            body: Padding(
              padding: const EdgeInsets.all(35.0),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enter Email
                      Text(
                        "Enter E-mail",
                        style: GoogleFonts.openSans(fontSize: 20),
                      ),
                      TextFormField(
                        validator: MultiValidator([
                          RequiredValidator(errorText: "Please Enter Email"),
                          EmailValidator(errorText: "Email type wrong"),
                        ]),
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (String? email) {
                          profile.email = email!;
                        },
                      ),
                      // Enter Password
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Enter Password",
                        style: GoogleFonts.openSans(fontSize: 20),
                      ),
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
                          child: Text(
                            "Login",
                            style: GoogleFonts.openSans(fontSize: 20),
                          ),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState?.save();
                              try {
                                await FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                  email: profile.email,
                                  password: profile.password,
                                )
                                    .then((value) {
                                  formKey.currentState?.reset();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return const SelectScreen(
                                          locationList: [],
                                        );
                                      },
                                    ),
                                  );
                                });
                              } on FirebaseAuthException catch (e) {
                                Fluttertoast.showToast(
                                  msg: "${e.message}",
                                  gravity: ToastGravity.CENTER,
                                );
                              }
                              if (kDebugMode) {
                                print("email = ${profile.email} password=${profile.password}");
                              }
                            }
                          },
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
