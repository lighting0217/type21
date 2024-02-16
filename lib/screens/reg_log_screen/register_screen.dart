import 'login_screen.dart';
import '../../auth_service.dart';
import '../main/select_screen.dart';
import 'package:flutter/material.dart';
import '../../../library/colors_schema.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

// ignore_for_file: use_build_context_synchronously
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  String? errorMessage;

  Future<void> _registerAccount() async {
    final BuildContext ctx = context;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      try {
        final user = await _auth.signUp(
          _auth.email,
          _auth.password,
          _auth.passwordConfirmation,
        );

        if (user != null) {
          Fluttertoast.showToast(
            msg: "สร้างบัญชีสำเร็จ",
            gravity: ToastGravity.TOP,
          );
          Navigator.pushReplacement(
            ctx,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } catch (e) {
        if (e is FirebaseAuthException) {
          String errorMessage = "";
          switch (e.code) {
            case 'email-already-in-use':
              errorMessage = "Email นี้มีบัญชีผู้ใช้แล้ว โปรดใช้ Email อื่น.";
              break;
            case 'weak-password':
              errorMessage = "รหัสผ่านต้องมีความยาวอย่างน้อย 8 ตัวอักษร.";
              break;
            case 'password-mismatch':
              errorMessage = "รหัสผ่านไม่ตรงกัน.";
              break;
            default:
              errorMessage = "Registration failed due to an unknown error.";
          }
          Fluttertoast.showToast(
            msg: errorMessage,
            textColor: myColorScheme.error,
            gravity: ToastGravity.CENTER,
            backgroundColor: myColorScheme.onError,
          );
          /*ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              duration: const Duration(seconds: 3),
            ),
          );*/
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "สร้างบัญชีผู้ใช้",
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
                      EmailValidator(errorText: "รูปแบบ E-mail ไม่ถูกต้อง"),
                    ]).call,
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (String? email) {
                      _auth.email = email!;
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
                  PasswordFormField(
                    onChanged: (value) {
                      _auth.setPassword(value);
                    },
                    labelText: 'รหัสผ่าน',
                    hintText: 'ป้อนรหัสผ่านของคุณ',
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  PasswordFormField(
                    onChanged: (value) {
                      _auth.setPasswordConfirmation(value);
                    },
                    labelText: 'ยืนยันรหัสผ่าน',
                    hintText: 'ป้อนรหัสผ่านอีกครั้ง',
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: myColorScheme.onPrimary,
                        backgroundColor: myColorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                      ),
                      onPressed: _registerAccount,
                      child: const Text('สร้างบัญชี'),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    errorMessage ?? '',
                    style: TextStyle(
                      color: myColorScheme.error,
                    ),
                  ),
                  _buildAlreadyHaveAccount(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlreadyHaveAccount() {
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text("มีบัญชีผู้ใช้แล้ว?",
              style: TextStyle(fontSize: 16, color: Colors.black)),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            child: Text(
              "เข้าสู่ระบบ",
              style: TextStyle(
                color: myColorScheme.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
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
                backgroundColor: myColorScheme.onError,
                textColor: myColorScheme.error);
          }
        },
      ),
    );
  }
}

class PasswordFormField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String labelText;
  final String hintText;

  const PasswordFormField({
    super.key,
    required this.onChanged,
    required this.labelText,
    required this.hintText,
  });

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: widget.onChanged,
      obscureText: _obscureText,
      validator: (value) {
        if (value!.isEmpty) {
          return 'กรุณาป้อน ${widget.labelText.toLowerCase()}';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
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
      ),
    );
  }
}
