import 'package:flutter/material.dart';
import 'package:nexus/services/firebase_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String confirmPassword = '';
  String nom = '';
  String errorMessage = '';

  final FirebaseService _firebaseService = FirebaseService();

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
      errorMessage = '';
    });
  }

  Future<void> submit() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid != null && isValid) {
      _formKey.currentState?.save();
      try {
        if (isLogin) {
          await _firebaseService.login(email, password);
          // Naviguer vers la page d'accueil
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          if (password != confirmPassword) {
            if (mounted) {
              setState(() {
                errorMessage = 'Les mots de passe ne correspondent pas.';
              });
            }
            return;
          }
          await _firebaseService.signUp(email, password, nom);
          // Naviguer vers la page d'accueil
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            errorMessage = e.toString();
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Taille de l'écran pour un design réactif
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Image de fond
          Container(
            height: size.height,
            width: size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.gif'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Container(
            height: size.height,
            width: size.width,
            color: Colors.black.withOpacity(0.2),
          ),
          // Contenu principal
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo ou titre de l'application
                  const Text(
                    'Nexus',
                    style: TextStyle(
                      fontFamily: 'Questrial',
                      fontSize: 48.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Formulaire dans une Card
                  Card(
                    color: Colors.white.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8.0,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            if (errorMessage.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline,
                                        color: Colors.white),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: Text(
                                        errorMessage,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.white),
                                      onPressed: () {
                                        if (mounted) {
                                          setState(() {
                                            errorMessage = '';
                                          });
                                        }
                                      },
                                    )
                                  ],
                                ),
                              ),
                            const SizedBox(height: 20),
                            if (!isLogin) ...[
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Nom complet',
                                  prefixIcon: Icon(Icons.person),
                                ),
                                onSaved: (value) => nom = value!.trim(),
                                validator: (value) {
                                  if (!isLogin &&
                                      (value == null || value.isEmpty)) {
                                    return 'Veuillez entrer votre nom.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              onSaved: (value) => email = value!.trim(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre email.';
                                }
                                if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                                  return 'Veuillez entrer un email valide.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Mot de passe',
                                prefixIcon: Icon(Icons.lock),
                              ),
                              obscureText: true,
                              onSaved: (value) => password = value!,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre mot de passe.';
                                }
                                if (value.length < 6) {
                                  return 'Le mot de passe doit contenir au moins 6 caractères.';
                                }
                                return null;
                              },
                            ),
                            if (!isLogin) ...[
                              const SizedBox(height: 20),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Confirmer le mot de passe',
                                  prefixIcon: Icon(Icons.lock),
                                ),
                                obscureText: true,
                                onSaved: (value) => confirmPassword = value!,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez confirmer votre mot de passe.';
                                  }
                                  return null;
                                },
                              ),
                            ],
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                isLogin ? 'Se connecter' : 'S\'inscrire',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey.shade100),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: toggleForm,
                              child: Text(
                                isLogin
                                    ? 'Pas de compte ? S\'inscrire'
                                    : 'Déjà inscrit ? Se connecter',
                                style:
                                    const TextStyle(color: Colors.blueAccent),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
