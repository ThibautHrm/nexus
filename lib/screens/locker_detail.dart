import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:nexus/themes/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;
import 'package:logger/logger.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

final logger = Logger();

class DocumentDetailScreen extends StatefulWidget {
  final String documentUrl;
  final String documentName;

  const DocumentDetailScreen({
    super.key,
    required this.documentUrl,
    required this.documentName,
  });

  @override
  DocumentDetailScreenState createState() => DocumentDetailScreenState();
}

class DocumentDetailScreenState extends State<DocumentDetailScreen> {
  bool _isLoading = false;

  // Méthode pour nettoyer l'URL et obtenir l'extension correcte
  String _extractFileNameFromUrl(String url, String name) {
    // Extraire la partie avant "?" pour se débarrasser des paramètres de requête
    String cleanUrl = url.split('?').first;

    // Obtenir l'extension du fichier
    String fileExtension = path.extension(cleanUrl);

    // Si l'extension est absente, par exemple si l'URL n'en contient pas, définir une extension par défaut
    if (fileExtension.isEmpty) {
      fileExtension = '.pdf'; // Par défaut, PDF ou tout autre format attendu
    }

    // Retourner le nom de fichier nettoyé avec l'extension correcte
    return '$name$fileExtension';
  }

  // Méthode pour télécharger temporairement le document avant de le partager
  Future<String?> _downloadDocument(BuildContext context) async {
    try {
      setState(() {
        _isLoading = true; // Activer l'indicateur de chargement
      });

      // Obtenir le répertoire temporaire
      Directory tempDir = await getTemporaryDirectory();

      // Extraire le nom du fichier avec son extension
      String fileName =
          _extractFileNameFromUrl(widget.documentUrl, widget.documentName);

      // Définir le chemin du fichier
      String filePath = path.join(tempDir.path, fileName);

      Dio dio = Dio();
      await dio.download(
        widget.documentUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            logger.d(
                "Téléchargé: ${(received / total * 100).toStringAsFixed(0)}%");
          }
        },
      );

      return filePath;
    } catch (e) {
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur lors du téléchargement: $e'),
      ));
      return null;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Méthode pour partager le document téléchargé
  Future<void> _shareDocument(BuildContext context) async {
    String? filePath = await _downloadDocument(context);
    if (filePath != null) {
      XFile fileToShare = XFile(filePath);
      Share.shareXFiles([fileToShare],
          text: 'Voici le document ${widget.documentName}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          widget.documentName,
          style: const TextStyle(
            color: AppColors.textDark,
            fontFamily: 'Questrial',
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.documentUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported,
                        size: 100,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: AppColors.primary,
                      size: 50,
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: () =>
                        _shareDocument(context), // Partage du document
                    icon: const Icon(
                      Icons.share,
                      color: AppColors.backgroundLight,
                    ),
                    label: const Text(
                      'Partager',
                      style: TextStyle(
                        color: AppColors.backgroundLight,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
