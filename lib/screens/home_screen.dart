import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Opens the Drawer
              },
            );
          },
        ),
        title: const Text(
          "Nexus",
          style: TextStyle(fontFamily: "Questrial"),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Options',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Profil'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to profile page
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings page
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () {
                Navigator.pop(context);
                // Handle logout logic
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Bento grid view at the top
          SizedBox(
            height: 300, // Adjust the height as needed
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 rows
                childAspectRatio: 1, // Square items
              ),
              itemCount: 6, // Adjust the number of items in the grid
              itemBuilder: (context, index) {
                if (index == 0) {
                  // This is where the "Signalement" button goes
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
                            color: Colors.black.withOpacity(0.2), // Shadow color
                            blurRadius: 8, // Spread the blur
                            offset: const Offset(2, 4), // Horizontal and vertical offset
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
                              size: 40.0, // Adjust the size of the icon if needed
                            ),
                            SizedBox(height: 8.0), // Add space between icon and text
                            Text(
                              "Signaler",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  // Other grid items with custom gradients and shadow
                  return Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: _getGradientColorsForIndex(index), // Custom gradient
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // Shadow color
                          blurRadius: 8, // Spread the blur
                          offset: const Offset(2, 4), // Horizontal and vertical offset
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.widgets, // Replace with any icon
                            color: Colors.white,
                            size: 40.0, // Adjust the size of the icon if needed
                          ),
                          SizedBox(height: 8.0), // Add space between icon and text
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
          ),
          // Other content below the grid (if needed)
          Expanded(
            child: Center(
              child: Text(
                'Contenu de la partie inférieure',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to return custom gradient colors for each bento item
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
        return [Colors.grey, Colors.blueGrey]; // Default gradient
    }
  }
}
