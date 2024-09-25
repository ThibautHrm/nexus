import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexus/models/signalement_model.dart';
import 'package:nexus/models/user_model.dart';
import 'package:nexus/screens/create_signalement_screen.dart';
import 'package:nexus/screens/edit_signalement_screen.dart';
import 'package:nexus/services/firebase_service.dart';
import 'package:nexus/themes/app_colors.dart';

class SignalementScreen extends StatefulWidget {
  const SignalementScreen({super.key});

  @override
  SignalementScreenState createState() => SignalementScreenState();
}

class SignalementScreenState extends State<SignalementScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  UserModel? _currentUser;
  List<SignalementModel> _signalements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSignalements();
  }

  Future<void> _loadSignalements() async {
    setState(() {
      _isLoading = true;
    });

    var user = _firebaseService.getCurrentUser();
    if (user != null) {
      _currentUser = await _firebaseService.getUser(user.uid);

      if (_currentUser != null) {
        if (_currentUser!.role == 'staff') {
          _signalements = await _firebaseService.getAllSignalements();
        } else {
          _signalements =
              await _firebaseService.getSignalementsByUser(user.uid);
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showSignalementDetails(SignalementModel signalement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (_, controller) {
            // Initialiser le statut sélectionné
            String selectedStatus = signalement.statut;

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Container(
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    controller: controller,
                    children: [
                      // Title Section (with icon and title)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _getCategorieIcon(signalement.categorie),
                            color: AppColors.primary,
                            size: 40,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                signalement.titre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: AppColors.textDark,
                                  fontFamily: "Questrial",
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Description Section
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          signalement.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textDark,
                            fontFamily: "Questrial",
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Date and Status Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 18, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Text(
                                _formatDate(signalement.dateCreation),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontFamily: "Questrial",
                                ),
                              ),
                            ],
                          ),

                          // Button to update status for staff
                          if (_currentUser?.role == 'staff') ...[
                            TextButton(
                              onPressed: () => _showStyledStatusDialog(
                                  context, signalement, setModalState),
                              child: Text(
                                selectedStatus,
                                style: TextStyle(
                                  color: _getStatutColor(selectedStatus),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Questrial",
                                ),
                              ),
                            ),
                          ] else ...[
                            // Badge de statut pour les non-staff users
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatutColor(signalement.statut),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                signalement.statut,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Questrial",
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Buttons for Edit and Delete
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _editSignalement(signalement);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.edit, color: Colors.white),
                            label: const Text(
                              "Modifier",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Questrial",
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteSignalement(signalement.id);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.delete, color: Colors.white),
                            label: const Text(
                              "Supprimer",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Questrial",
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

// Show a stylized dialog to select status
  void _showStyledStatusDialog(BuildContext context,
      SignalementModel signalement, StateSetter setModalState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: AppColors.backgroundLight,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Mettre à jour le statut',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.textDark,
                    fontFamily: "Questrial",
                  ),
                ),
                const SizedBox(height: 20),
                Divider(color: Colors.grey[300]),
                SimpleDialogOption(
                  onPressed: () {
                    setModalState(() {
                      signalement.statut = 'en attente';
                    });
                    _updateSignalementStatus(signalement.id, 'en attente');
                    Navigator.pop(context);
                  },
                  child: Text(
                    'En attente',
                    style: TextStyle(
                      color: _getStatutColor('en attente'),
                      fontWeight: FontWeight.bold,
                      fontFamily: "Questrial",
                    ),
                  ),
                ),
                Divider(color: Colors.grey[300]),
                SimpleDialogOption(
                  onPressed: () {
                    setModalState(() {
                      signalement.statut = 'en cours';
                    });
                    _updateSignalementStatus(signalement.id, 'en cours');
                    Navigator.pop(context);
                  },
                  child: Text(
                    'En cours',
                    style: TextStyle(
                      color: _getStatutColor('en cours'),
                      fontWeight: FontWeight.bold,
                      fontFamily: "Questrial",
                    ),
                  ),
                ),
                Divider(color: Colors.grey[300]),
                SimpleDialogOption(
                  onPressed: () {
                    setModalState(() {
                      signalement.statut = 'résolu';
                    });
                    _updateSignalementStatus(signalement.id, 'résolu');
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Résolu',
                    style: TextStyle(
                      color: _getStatutColor('résolu'),
                      fontWeight: FontWeight.bold,
                      fontFamily: "Questrial",
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      // Rafraîchir la vue une fois que le dialog est fermé
      setModalState(() {});
    });
  }

// Fonction pour mettre à jour le statut du signalement
  Future<void> _updateSignalementStatus(
      String signalementId, String newStatus) async {
    await _firebaseService.updateSignalementStatut(signalementId, newStatus);
    _loadSignalements(); // Rafraîchir les signalements après la mise à jour
  }

  Future<void> _deleteSignalement(String id) async {
    await _firebaseService.deleteSignalement(id);
    _loadSignalements();
  }

  void _editSignalement(SignalementModel signalement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSignalementScreen(signalement: signalement),
      ),
    ).then((_) {
      _loadSignalements();
    });
  }

  IconData _getCategorieIcon(String categorie) {
    switch (categorie.toLowerCase()) {
      case 'infrastructure':
        return Icons.business;
      case 'sécurité':
        return Icons.security;
      case 'maintenance':
        return Icons.build;
      case 'harcèlement':
        return Icons.report_gmailerrorred;
      case 'autre':
        return Icons.help_outline;
      default:
        return Icons.report_problem;
    }
  }

  Color _getStatutColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'en attente':
        return AppColors.primary;
      case 'en cours':
        return AppColors.secondary;
      case 'résolu':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  Widget _buildSignalementItem(SignalementModel signalement) {
    return GestureDetector(
      onTap: () => _showSignalementDetails(signalement),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: SizedBox(
          height: 150,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec icône de catégorie et titre
                Row(
                  children: [
                    Icon(
                      _getCategorieIcon(signalement.categorie),
                      color: AppColors.primary,
                      size: 36,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          signalement.titre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: "Questrial",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Description du signalement avec ellipsis
                Flexible(
                  child: Text(
                    signalement.description,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.black87,
                      fontFamily: "Questrial",
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 12),

                // Footer avec la date et le statut
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(signalement.dateCreation),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    // Badge de statut
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatutColor(signalement.statut),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        signalement.statut,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Questrial",
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Signalements',
          style: TextStyle(
            fontFamily: "Questrial",
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _signalements.isEmpty
              ? const Center(
                  child: Text(
                    "Aucun signalement disponible.",
                    style: TextStyle(
                      fontFamily: "Questrial",
                      color: AppColors.textDark,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _signalements.length,
                  itemBuilder: (context, index) {
                    return _buildSignalementItem(_signalements[index]);
                  },
                ),
      floatingActionButton: _currentUser?.role != 'staff'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateSignalementScreen(),
                  ),
                ).then((_) {
                  _loadSignalements();
                });
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
