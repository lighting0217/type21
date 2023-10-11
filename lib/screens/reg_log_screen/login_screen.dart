import 'register_screen.dart';
import '../../auth_service.dart';
import '../main/select_screen.dart';
import 'package:flutter/material.dart';
import '../../../library/colors_schema.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
// ignore_for_file: use_build_context_synchronously


final Future<FirebaseApp> _firebaseInit = Firebase.initializeApp();

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  bool _obscureText = true;

  Future<void> _login() async {
    final BuildContext ctx = context;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      final user = await _auth.signIn(_auth.email, _auth.password);
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        Navigator.of(ctx).pushReplacement(MaterialPageRoute(
          builder: (context) => const SelectScreen(locationList: []),
        ));
        Fluttertoast.showToast(
          msg: "เข้าสู่ระบบสําเร็จ",
          gravity: ToastGravity.TOP,
          textColor: myColorScheme.secondary,
            backgroundColor: myColorScheme.onError
        );
      } else {
        Fluttertoast.showToast(
          msg: "เข้าสู่ระบบไม่สําเร็จ",
          gravity: ToastGravity.CENTER,
          textColor: myColorScheme.error,
          backgroundColor: myColorScheme.onError
        );
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
              title: const Text("ข้อผิดพลาด"),
              backgroundColor: Colors.red,
            ),
            body: Center(
              child: Text("${snapshot.error}"),
            ),
            backgroundColor: myColorScheme.primary,
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
                backgroundColor: myColorScheme.primary,
              ),
              body: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: myGradient,
                ),
                child: Padding(
                  padding:  const EdgeInsets.all(35.0),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildEmailField(),
                          const SizedBox(height: 20),
                          _buildPasswordField(),
                          const SizedBox(height: 20),
                          _buildLoginButton(),
                          const SizedBox(height: 20),
                          //_buildGoogleSigninButton(),
                          //const SizedBox(height: 20,),
                          _buildDontHaveAccount(),
                        ],
                      ),
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
      },
    );
  }

  Widget _buildDontHaveAccount() {
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
           Text(
            "ยังไม่มีบัญชีผู้ใช้?",
            style: TextStyle(
              fontSize: 16,
              color: myColorScheme.onBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: myColorScheme.primary,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegisterScreen(),
                ),
              );
            },
            child:  Text(
              "สร้างบัญชี",
              style: TextStyle(
                color: myColorScheme.primary.withOpacity(0.8),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "ป้อน E-mail",
          style: GoogleFonts.openSans(fontSize: 20,backgroundColor: myColorScheme.surface,fontWeight: FontWeight.bold),
        ),
        TextFormField(
          decoration: _buildEmailInputDecoration(),
          validator: MultiValidator([
            RequiredValidator(errorText: "กรุณาป้อน E-mail"),
            EmailValidator(errorText: "Email ไม่ถูกต้อง"),
          ]),
          keyboardType: TextInputType.emailAddress,
          onSaved: (String? email) => _auth.email = email!,
        ),
      ],
    );
  }
InputDecoration _buildEmailInputDecoration() {
    return InputDecoration(
      fillColor: myColorScheme.onBackground,
      labelText: 'Email',
      hintText: 'ป้อน E-mail',
      border: const OutlineInputBorder(),
      prefixIcon: const Icon(Icons.email),
    );
  }
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "ป้อนรหัสผ่าน",
          style: GoogleFonts.openSans(fontSize: 20,backgroundColor: myColorScheme.surface),
        ),
        TextFormField(
          obscureText: _obscureText,
          decoration: _buildPasswordInputDecoration(),
          validator: RequiredValidator(errorText: "กรุณาป้อนรหัสผ่าน"),
          onSaved: (String? password) => _auth.password = password!,
        ),
      ],
    );
  }

  InputDecoration _buildPasswordInputDecoration() {
    return InputDecoration(
      fillColor: myColorScheme.onBackground,
      labelText: 'Password',
      hintText: 'ป้อนรหัสผ่านของคุณ',
      border: const OutlineInputBorder(),
      prefixIcon: const Icon(Icons.lock),
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    );
  }

  Widget _buildLoginButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: myColorScheme.onPrimary,
              backgroundColor: myColorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            onPressed: _login,
            child: const Text('เข้าสู่ระบบ'),
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildGoogleSigninButton() {
    return SizedBox(
      width: double.infinity,
      child: SignInButton(
        Buttons.Google,
        text: "Sign in with Google",
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
