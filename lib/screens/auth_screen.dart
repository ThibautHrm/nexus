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
    return Scaffold(
      appBar: AppBar(
        title: Text('Nexus - ${isLogin ? 'Connexion' : 'Inscription'}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (errorMessage.isNotEmpty)
              Container(
                color: Colors.amberAccent,
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline),
                    const SizedBox(width: 8.0),
                    Expanded(child: Text(errorMessage)),
                    IconButton(
                      icon: const Icon(Icons.close),
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
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    if (!isLogin) ...[
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Nom complet'),
                        onSaved: (value) => nom = value!.trim(),
                        validator: (value) {
                          if (!isLogin && (value == null || value.isEmpty)) {
                            return 'Veuillez entrer votre nom.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Email'),
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
                      decoration:
                          const InputDecoration(labelText: 'Mot de passe'),
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
                            labelText: 'Confirmer le mot de passe'),
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
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: submit,
                      child: Text(isLogin ? 'Se connecter' : 'S\'inscrire'),
                    ),
                    TextButton(
                      onPressed: toggleForm,
                      child: Text(isLogin
                          ? 'Pas de compte ? S\'inscrire'
                          : 'Déjà inscrit ? Se connecter'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
