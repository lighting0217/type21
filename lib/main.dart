import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'screens/main/select_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/reg_log_screen/login_screen.dart';
import 'screens/reg_log_screen/register_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Fluttertoast.showToast;
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user != null) {
      if (kDebugMode) {
        print('User is authenticated. UID: ${user.uid}');
      }
    } else {
      if (kDebugMode) {
        print('User is not authenticated.');
      }
    }
  });

  final FirebaseAuth auth = FirebaseAuth.instance;
  final prefs = await SharedPreferences.getInstance();

  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  bool isFirebaseUserLoggedIn = auth.currentUser != null;

  runApp(MaterialApp(
    home: isLoggedIn && isFirebaseUserLoggedIn
        ? const SelectScreen(
            locationList: [],
          )
        : const LoginScreen(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Archtitec',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final User? user = snapshot.data;
            if (user == null) {
              return const LoginScreen();
            }
            return const RegisterScreen();
          }
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}

class PermissionHandlerScreen extends StatefulWidget {
  const PermissionHandlerScreen({Key? key}) : super(key: key);

  @override
  State<PermissionHandlerScreen> createState() =>
      _PermissionHandlerScreenState();
}

class _PermissionHandlerScreenState extends State<PermissionHandlerScreen> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.locationWhenInUse,
    ].request();

    if (statuses[Permission.location]!.isDenied ||
        statuses[Permission.locationWhenInUse]!.isDenied) {
      _handleDeniedPermission();
    }

    if (statuses[Permission.location]!.isPermanentlyDenied ||
        statuses[Permission.locationWhenInUse]!.isPermanentlyDenied) {
      openAppSettings();
    }

    if (statuses[Permission.location]!.isGranted &&
        statuses[Permission.locationWhenInUse]!.isGranted) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }
  }

  void _handleDeniedPermission() {
    if (kDebugMode) {
      print("Permission is denied.");
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
