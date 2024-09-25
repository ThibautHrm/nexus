import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import pour gérer l'orientation
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nexus/screens/auth_screen.dart';
import 'package:nexus/screens/create_news_screen.dart';
import 'package:nexus/screens/forum_group_screen.dart';
import 'package:nexus/screens/home_screen.dart';
import 'package:nexus/screens/profil_screen.dart';
import 'package:nexus/screens/settings_screen.dart';
import 'package:nexus/screens/signalement_screen.dart';
import 'package:nexus/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase et Intl
  await Firebase.initializeApp();
  await initializeDateFormatting('fr', null);

  // Verrouiller l'application en mode portrait uniquement
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const NexusApp());
  });
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
        '/createNews': (context) => const AddNewsScreen(),
        '/group': (context) => const GroupScreen(),
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
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}
