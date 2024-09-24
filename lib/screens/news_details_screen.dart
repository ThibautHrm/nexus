// lib/screens/news_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:nexus/models/news_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsModel news;

  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    // Formater la date
    final String formattedDate =
        DateFormat.yMMMMd('fr_FR').format(news.dateCreation);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          news.titre,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share('${news.titre}\n\n${news.description}');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image avec Hero Animation
            Hero(
              tag: 'newsImage_${news.id}',
              child: news.imageUrl.isNotEmpty
                  ? Image.network(
                      news.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          height: 200,
                          color: Colors.grey[300],
                          child:
                              const Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey,
                          child: const Icon(Icons.broken_image, size: 100),
                        );
                      },
                    )
                  : Container(
                      height: 200,
                      color: Colors.grey,
                      child: const Icon(Icons.image, size: 100),
                    ),
            ),
            const SizedBox(height: 16.0),
            // Contenu de la news
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre de la news
                  Text(
                    news.titre,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // Informations (date et emplacement)
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16.0, color: Colors.grey[600]),
                      const SizedBox(width: 4.0),
                      Text(
                        formattedDate,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16.0),
                      Icon(Icons.location_on,
                          size: 16.0, color: Colors.grey[600]),
                      const SizedBox(width: 4.0),
                      Text(
                        news.emplacement,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  // Description de la news
                  Text(
                    news.description,
                    style: const TextStyle(fontSize: 18.0, height: 1.5),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
