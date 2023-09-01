// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:type21/screens/reg_log_screen/home_screen.dart';

import 'field_screen/field_list.dart';
import 'map_screen_type2.dart';

final auth = FirebaseAuth.instance;

class SelectScreen extends StatelessWidget {
  const SelectScreen({Key? key, required this.locationList}) : super(key: key);

  final List<LatLng> locationList;

  void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Welcome to Application",
          style: GoogleFonts.openSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Builder(
            builder: (BuildContext builderContext) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.blue,
                    radius: 50,
                    child: FlutterLogo(size: 40.0),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Welcome, ${auth.currentUser?.email ?? ''}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    child: const Text("Sign Out"),
                    onPressed: () {
                      showDialog(
                        context: builderContext,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text('Sign Out'),
                            content: const Text(
                                'Are you sure you want to sign out?'),
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.pop(
                                      dialogContext); // Close the dialog
                                },
                              ),
                              TextButton(
                                child: const Text('Sign Out'),
                                onPressed: () async {
                                  Navigator.pop(
                                      dialogContext); // Close the dialog
                                  await _handleSignOut(
                                      context); // Call the asynchronous function
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: const Text('User Name'),
              accountEmail: Text(auth.currentUser?.email ?? ''),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: FlutterLogo(size: 80.0),
              ),
            ),
            ListTile(
              title: const Text('To Map Screen'),
              onTap: () {
                navigateToScreen(
                  context,
                  MapScreenType2(
                    polygons: locationList,
                    polygonArea: 0,
                    lengths: const [],
                    onPolygonAreaChanged: (double value) {},
                  ),
                );
              },
            ),
            /*ListTile(
              title: const Text('To Weather Screen'),
              onTap: () {
                navigateToScreen(context, WeatherScreen());
              },
            ),*/
            ListTile(
              title: const Text('To Field List Screen'),
              onTap: () {
                navigateToScreen(
                  context,
                  const FieldList(
                    fields: [],
                    monthlyTemperatureData: [],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      await auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
    }
  }
}
