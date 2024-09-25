import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart'; // Import du package
import 'package:nexus/services/firebase_service.dart';
import 'package:nexus/themes/app_colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool isLoading = false; // Pour gérer l'état de chargement
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String confirmPassword = '';
  String nom = '';
  String errorMessage = '';
  final FirebaseService _firebaseService = FirebaseService();

  int _nexusClickCount = 0;
  bool _showGifBackground = false;

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
      setState(() {
        isLoading = true; // Commencer le chargement
      });

      try {
        if (isLogin) {
          await _firebaseService.login(email, password);
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
            setState(() {
              isLoading = false; // Fin du chargement en cas d'erreur
            });
            return;
          }
          await _firebaseService.signUp(email, password, nom);
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
      } finally {
        setState(() {
          isLoading = false; // Fin du chargement après l'opération
        });
      }
    }
  }

  void _onNexusTitleTap() {
    _nexusClickCount++;
    if (_nexusClickCount == 5) {
      setState(() {
        _showGifBackground = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          if (_showGifBackground)
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
          if (_showGifBackground)
            Container(
              height: size.height,
              width: size.width,
              color: Colors.black.withOpacity(0.2),
            ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _onNexusTitleTap,
                    child: const Text(
                      'Nexus',
                      style: TextStyle(
                        fontFamily: 'Questrial',
                        fontSize: 48.0,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
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
                                  labelStyle: TextStyle(
                                    color: AppColors.secondary,
                                    fontFamily: "Questrial",
                                  ),
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
                                labelStyle: TextStyle(
                                  color: AppColors.secondary,
                                  fontFamily: "Questrial",
                                ),
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
                                labelStyle: TextStyle(
                                  color: AppColors.secondary,
                                  fontFamily: "Questrial",
                                ),
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
                                  labelStyle: TextStyle(
                                    color: AppColors.secondary,
                                    fontFamily: "Questrial",
                                  ),
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
                              onPressed: isLoading
                                  ? null
                                  : submit, // Désactive le bouton pendant le chargement
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: isLoading
                                  ? LoadingAnimationWidget.staggeredDotsWave(
                                      color: Colors.white,
                                      size: 30,
                                    ) // Afficher l'indicateur de chargement
                                  : Text(
                                      isLogin ? 'Se connecter' : 'S\'inscrire',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
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
                                    const TextStyle(color: AppColors.secondary),
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
