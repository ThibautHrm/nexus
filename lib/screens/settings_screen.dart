import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.grey[100],
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Page de Paramètres',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
