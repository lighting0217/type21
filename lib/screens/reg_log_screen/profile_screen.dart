import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/profile.dart'; // Import Google Fonts

class ProfileScreen extends StatelessWidget {
  final Profile profile;

  const ProfileScreen({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts
              .openSans(), // Apply Google Fonts style to app bar title
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Edit Profile Screen',
              style: GoogleFonts.openSans(
                // Apply Google Fonts style to the text
                fontSize: 24, // You can adjust the font size as needed
                fontWeight: FontWeight.bold, // Apply bold style to the text
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Email: ${profile.email}',
              style: GoogleFonts
                  .openSans(), // Apply Google Fonts style to the text
            ),
            Text(
              'Password: ${profile.password}',
              style: GoogleFonts
                  .openSans(), // Apply Google Fonts style to the text
            ),
          ],
        ),
      ),
    );
  }
}
