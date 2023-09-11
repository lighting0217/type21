import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:type21/models/profile.dart';
import 'package:type21/screens/main/select_screen.dart';

final Future<FirebaseApp> _firebaseInit = Firebase.initializeApp();

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Profile _profile = Profile(email: '', password: '');

  Future<void> _login() async {
    final BuildContext ctx = context;

    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _profile.email,
          password: _profile.password,
        );

        Navigator.of(ctx).pushReplacement(MaterialPageRoute(
          builder: (context) => const SelectScreen(locationList: []),
        ));
        Fluttertoast.showToast(
          msg: "Login Successful",
          gravity: ToastGravity.TOP,
        );
      } on FirebaseAuthException catch (e) {
        Fluttertoast.showToast(
          msg: e.message ?? "An error occurred.",
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
      future: _firebaseInit,
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
                "เข้าสู่ระบบ",
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
                      _buildEmailField(),
                      const SizedBox(height: 20),
                      _buildPasswordField(),
                      _buildLoginButton(),
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

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "ป้อน E-mail",
          style: GoogleFonts.openSans(fontSize: 20),
        ),
        TextFormField(
          validator: MultiValidator([
            RequiredValidator(errorText: "กรุณาป้อนE-mail"),
            EmailValidator(errorText: "Email ไม่ถูกต้อง"),
          ]),
          keyboardType: TextInputType.emailAddress,
          onSaved: (String? email) => _profile.email = email!,
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "ป้อนรหัสผ่าน",
          style: GoogleFonts.openSans(fontSize: 20),
        ),
        TextFormField(
          validator: RequiredValidator(errorText: "กรุณาป้อนรหัสผ่าน"),
          obscureText: true,
          onSaved: (String? password) => _profile.password = password!,
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _login,
        child: Text("Login", style: GoogleFonts.openSans(fontSize: 20)),
      ),
    );
  }
}
