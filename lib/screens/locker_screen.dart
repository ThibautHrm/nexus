import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour formater la date
import 'package:nexus/models/document_model.dart';
import 'package:nexus/screens/locker_detail.dart';
import 'package:nexus/services/firebase_service.dart';
import 'package:nexus/themes/app_colors.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Pour les images avec cache
import 'package:logger/logger.dart'; // Logger pour déboguer
import 'package:permission_handler/permission_handler.dart'; // Pour les permissions

final logger = Logger();

class LockerScreen extends StatefulWidget {
  const LockerScreen({super.key});

  @override
  LockerScreenState createState() => LockerScreenState();
}

class LockerScreenState extends State<LockerScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<DocumentModel> _documents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _checkPermissions() async {
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }

    if (await Permission.camera.isDenied) {
      await Permission.camera.request();
    }
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _firebaseService.getCurrentUser();
      if (user != null) {
        Stream<List<DocumentModel>> documentsStream =
            _firebaseService.getUserDocuments(user.uid);
        documentsStream.listen((documents) {
          setState(() {
            _documents = documents;
            _isLoading = false;
          });
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur lors du chargement des documents: $e'),
      ));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _scanDocument() async {
    await _checkPermissions();
    try {
      final scannedDocuments = await CunningDocumentScanner.getPictures();
      if (scannedDocuments != null && scannedDocuments.isNotEmpty) {
        File scannedFile = File(scannedDocuments.first);
        _uploadDocument(scannedFile);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur lors du scan du document: $e'),
      ));
    }
  }

  Future<void> _pickDocument() async {
    await _checkPermissions();
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File selectedFile = File(result.files.single.path!);
      _uploadDocument(selectedFile);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Aucun fichier sélectionné'),
      ));
    }
  }

  Future<void> _uploadDocument(File file) async {
    await _checkPermissions();
    String documentName = await _showDocumentNameDialog();
    if (documentName.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = _firebaseService.getCurrentUser();
        if (user != null) {
          logger.d("Début de l'upload du fichier...");
          await Future.delayed(const Duration(seconds: 1));
          String fileUrl = await _firebaseService.uploadFile(file, user.uid);

          if (fileUrl.isNotEmpty) {
            DocumentModel document = DocumentModel(
              id: '',
              nom: documentName,
              url: fileUrl,
              ownerId: user.uid,
              dateAjout: DateTime.now(),
            );

            await _firebaseService.addDocument(document);
            _loadDocuments();
            logger.d("Fichier uploadé avec succès.");
          } else {
            throw Exception("L'URL du fichier est vide ou invalide.");
          }
        }
      } catch (e) {
        logger.e("Erreur lors de l'upload du document : $e");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur lors de l\'upload du document: $e'),
        ));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _showDocumentNameDialog() async {
    String documentName = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Nom du document',
            style: TextStyle(
              fontFamily: 'Questrial',
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          content: TextField(
            onChanged: (value) {
              documentName = value;
            },
            decoration: InputDecoration(
              hintText: 'Entrez un nom',
              filled: true,
              fillColor: Colors.grey.shade200,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(fontFamily: 'Questrial'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Annuler',
                style: TextStyle(
                    fontFamily: 'Questrial',
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Confirmer',
                style: TextStyle(fontFamily: 'Questrial', color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
    return documentName;
  }

  Future<void> _deleteDocument(DocumentModel document) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Confirmer la suppression',
            style: TextStyle(
              fontFamily: 'Questrial',
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer ce document ?',
            style: TextStyle(
              fontFamily: 'Questrial',
              color: AppColors.textDark,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Annuler',
                style: TextStyle(
                    fontFamily: 'Questrial', color: AppColors.secondary),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Supprimer',
                style: TextStyle(fontFamily: 'Questrial', color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _firebaseService.deleteDocument(document.id, document.url);
        _loadDocuments();
      } catch (e) {
        logger.e("Erreur lors de la suppression du document : $e");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur lors de la suppression du document: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Mon Coffre-fort',
          style: TextStyle(
            fontFamily: 'Questrial',
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _documents.isEmpty
              ? const Center(
                  child: Text(
                    'Aucun document disponible',
                    style: TextStyle(fontFamily: 'Questrial'),
                  ),
                )
              : ListView.builder(
                  itemCount: _documents.length,
                  itemBuilder: (context, index) {
                    final document = _documents[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  DocumentDetailScreen(
                            documentUrl: document.url,
                            documentName: document.nom,
                          ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;
                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      ),
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12), // Taille augmentée
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 6,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: document.url,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.image_not_supported),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      document.nom,
                                      style: const TextStyle(
                                        fontFamily: 'Questrial',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Ajouté le ${DateFormat('dd/MM/yyyy').format(document.dateAjout)}',
                                      style: const TextStyle(
                                        fontFamily: 'Questrial',
                                        fontSize: 14,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteDocument(document),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _scanDocument,
            heroTag: 'scanDocument',
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.camera_alt, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _pickDocument,
            heroTag: 'uploadDocument',
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.file_upload, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
