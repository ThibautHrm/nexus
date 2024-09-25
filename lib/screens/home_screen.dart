import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:nexus/models/news_model.dart';
import 'package:nexus/screens/news_details_screen.dart';
import 'package:nexus/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  List<NewsModel> _newsList = [];
  bool _isLoading = true;
  String _selectedEmplacement = 'Tous';
  final List<String> _emplacements = [
    'Tous',
    'Angers',
    'Arras',
    'Auxerre',
    'Bordeaux',
    'Chartres',
    'Grenoble',
    'Lille',
    'Lyon',
    'Montpellier',
    'Nantes',
    'Paris',
    'Reims',
    'Rennes',
    'Saint-Étienne',
    'Toulouse',
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedEmplacement();
  }

  // Chargement de l'emplacement sélectionné
  Future<void> _loadSelectedEmplacement() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? emplacement = prefs.getString('selectedEmplacement');
    if (emplacement != null && !_emplacements.contains(emplacement)) {
      emplacement = 'Tous';
    }
    setState(() {
      _selectedEmplacement = emplacement ?? 'Tous';
      _isLoading = true;
    });
    String? emplacementQuery =
        _selectedEmplacement == 'Tous' ? null : _selectedEmplacement;
    await _loadNews(emplacement: emplacementQuery);
  }

  // Sauvegarde de l'emplacement sélectionné
  Future<void> _saveSelectedEmplacement(String emplacement) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedEmplacement', emplacement);
  }

  // Chargement des news en fonction de l'emplacement
  Future<void> _loadNews({String? emplacement}) async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<NewsModel> news =
          await _firebaseService.getAllNews(emplacement: emplacement);

      setState(() {
        _newsList = news;
        _isLoading = false;
      });
    } catch (e) {
      _newsList = [];
      _isLoading = false;
    }
  }

  // Widget pour afficher une news individuelle
  Widget _buildNewsItem(NewsModel news) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewsDetailScreen(news: news)),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image avec Hero Animation
            Hero(
              tag: 'newsImage_${news.id}',
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: news.imageUrl.isNotEmpty
                    ? Image.network(
                        news.imageUrl,
                        height: 180,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 180,
                            color: Colors.grey[300],
                            child: const Center(
                                child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 180,
                            color: Colors.grey,
                            child: const Icon(Icons.broken_image, size: 100),
                          );
                        },
                      )
                    : Container(
                        height: 180,
                        color: Colors.grey,
                        child: const Icon(Icons.image, size: 100),
                      ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Text(
                news.titre,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: Text(
                news.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 16.0, color: Colors.grey[600]),
                  const SizedBox(width: 4.0),
                  Text(
                    news.emplacement,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Icon(Icons.calendar_today,
                      size: 16.0, color: Colors.grey[600]),
                  const SizedBox(width: 4.0),
                  Text(
                    DateFormat.yMMMd('fr_FR').format(news.dateCreation),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }

  // Widget pour le filtre par emplacement
  Widget _buildEmplacementFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _emplacements.map((String emplacement) {
          bool isSelected = _selectedEmplacement == emplacement;
          return GestureDetector(
            onTap: () async {
              setState(() {
                _selectedEmplacement = emplacement;
                _isLoading = true;
              });
              await _saveSelectedEmplacement(_selectedEmplacement);
              String? emplacementQuery =
                  _selectedEmplacement == 'Tous' ? null : _selectedEmplacement;
              await _loadNews(emplacement: emplacementQuery);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Center(
                child: Text(
                  emplacement,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Widget pour afficher un message lorsqu'il n'y a pas de news
  Widget _buildNoNewsMessage() {
    return Center(
      child: Text(
        'Aucune news disponible pour cet emplacement.',
        style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
      ),
    );
  }

  // Widget pour la grille en haut
  Widget _buildTopGrid() {
    return SizedBox(
      height: 300,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
        ),
        itemCount: 6, // Nombre d'éléments dans la grille
        itemBuilder: (context, index) {
          if (index == 0) {
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/signal');
              },
              child: Container(
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Colors.red, Colors.redAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_rounded,
                        color: Colors.white,
                        size: 40.0,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        "Signaler",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          if (index == 1) {
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/createNews');
              },
              child: Container(
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.greenAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.newspaper_rounded,
                        color: Colors.white,
                        size: 40.0,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        "Ajouter News",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          if (index == 2) {
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/group');
              },
              child: Container(
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.newspaper_rounded,
                        color: Colors.white,
                        size: 40.0,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        "Forum",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: _getGradientColorsForIndex(index),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.widgets,
                      color: Colors.white,
                      size: 40.0,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      "Item $index",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // Gestion des dégradés
  List<Color> _getGradientColorsForIndex(int index) {
    switch (index) {
      case 2:
        return [Colors.purple, Colors.pink];
      case 3:
        return [Colors.orange, Colors.deepOrange];
      case 4:
        return [Colors.amber, Colors.amberAccent];
      case 5:
        return [Colors.teal, Colors.cyan];
      default:
        return [Colors.grey, Colors.blueGrey];
    }
  }

  // Widget pour le Drawer
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.grey[100],
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey[100],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FittedBox(
                fit: BoxFit.contain,
                child: SvgPicture.asset(
                  'assets/images/epsilogo.svg',
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profil'),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: () {
              FirebaseService().logout();
              Navigator.pushReplacementNamed(context, '/auth');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz),
          ),
        ],
        title: const Text(
          "Nexus",
          style: TextStyle(fontFamily: "Questrial"),
        ),
        centerTitle: true,
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildTopGrid(),
          const SizedBox(height: 20),
          _buildEmplacementFilter(),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _newsList.isEmpty
                    ? _buildNoNewsMessage()
                    : ListView.builder(
                        itemCount: _newsList.length,
                        itemBuilder: (context, index) {
                          return _buildNewsItem(_newsList[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
