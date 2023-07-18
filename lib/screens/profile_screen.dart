import 'package:flutter/material.dart';
import 'package:type21/models/profile.dart';

class ProfileScreen extends StatelessWidget {
  final Profile profile;

  const ProfileScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Edit Profile Screen'),
            Text('Email: ${profile.email}'),
            Text('Password: ${profile.password}'),
          ],
        ),
      ),
    );
  }
}
