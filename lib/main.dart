import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nexus/screens/auth_screen.dart';
import 'package:nexus/screens/home_screen.dart';
import 'package:nexus/screens/profil_screen.dart';
import 'package:nexus/screens/settings_screen.dart';
import 'package:nexus/screens/signalement_screen.dart';
import 'package:nexus/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const NexusApp());
}

class NexusApp extends StatelessWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nexus - Campus connecté',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainPage(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/auth': (context) => const AuthScreen(),
        '/signal': (context) => const SignalementScreen(),
        '/profile': (context) => const ProfilScreen(),
        '/settings': (context) => const SettingsScreen(),

      },
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseService().authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Affiche un indicateur de progression pendant le chargement
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasData) {
          // Si l'utilisateur est connecté, affiche l'écran principal
          return const HomeScreen();
        } else {
          // Sinon, affiche l'écran d'authentification
          return const AuthScreen();
        }
      },
    );
  }
}
