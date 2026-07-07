import 'package:flutter/material.dart';
import 'package:karafarini/features/auth/data/auth_services.dart';
import 'package:karafarini/core/theme/app_theme.dart';

class HomeTestPage extends StatefulWidget {
  const HomeTestPage({super.key});

  @override
  State<HomeTestPage> createState() => _HomeTestPageState();
}

class _HomeTestPageState extends State<HomeTestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        centerTitle: true,
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.primaryLight,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            AuthService.instance.signOut();
          },
          child: Text('Sign Out'),
        ),
      ),
    );
  }
}
