import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nexus/models/news_model.dart';
import 'package:nexus/screens/create_news_screen.dart';
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
    _loadNews(emplacement: emplacementQuery);
  }

  Future<void> _saveSelectedEmplacement(String emplacement) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Enregistrer l'emplacement tel quel
    await prefs.setString('selectedEmplacement', emplacement);
  }

  Future<void> _loadNews({String? emplacement}) async {
    try {
      List<NewsModel> news =
          await _firebaseService.getAllNews(emplacement: emplacement);

      setState(() {
        _newsList = news;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _newsList = [];
        _isLoading = false;
      });
    }
  }

  // Widget pour afficher une news individuelle
  Widget _buildNewsItem(NewsModel news) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
          leading: news.imageUrl.isNotEmpty
              ? Image.network(
                  news.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
              : null,
          title: Text(news.titre),
          subtitle: Text(news.description),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewsDetailScreen(news: news),
              ),
            );
          }),
    );
  }

  // Widget pour le filtre par emplacement
  Widget _buildEmplacementFilter() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DropdownButton<String>(
        value: _selectedEmplacement,
        isExpanded: true,
        items: _emplacements.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        // Lors du changement de l'emplacement sélectionné
        onChanged: (newValue) {
          setState(() {
            _selectedEmplacement = newValue!;
            _isLoading = true;
          });
          _saveSelectedEmplacement(_selectedEmplacement);
          String? emplacementQuery =
              _selectedEmplacement == 'Tous' ? null : _selectedEmplacement;
          _loadNews(emplacement: emplacementQuery);
        },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
        title: const Text(
          "Nexus",
          style: TextStyle(fontFamily: "Questrial"),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
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
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_rounded,
                              color: Colors.white,
                              size: 40.0,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              "Signaler",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.widgets,
                            color: Colors.white,
                            size: 40.0,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            "Item $index",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          _buildEmplacementFilter(),
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

  // Gestion des dégradés
  List<Color> _getGradientColorsForIndex(int index) {
    switch (index) {
      case 1:
        return [Colors.purple, Colors.pink];
      case 2:
        return [Colors.orange, Colors.deepOrange];
      case 3:
        return [Colors.green, Colors.lightGreen];
      case 4:
        return [Colors.amber, Colors.amberAccent];
      case 5:
        return [Colors.teal, Colors.cyan];
      default:
        return [Colors.grey, Colors.blueGrey];
    }
  }
}
