import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:final65111064/web/database_helper.dart' as db_helper;
import 'package:path_provider/path_provider.dart';
import 'screens/add_plant.dart' as plant_screen;
import 'screens/add_landuse.dart';
import 'screens/view_edit_plant.dart';
import 'screens/search_landuse.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Database App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomeScreen(), // ตั้งค่าให้เปิดหน้า HomeScreen ก่อน
      routes: {
        '/add_land_use': (context) => AddLandUseScreen(),
        '/view_edit_plant': (context) => ViewEditPlantScreen(),
        '/search_land_use': (context) => SearchLandUseScreen(),
        '/plant_list': (context) => PlantListPage(), // เพิ่มหน้า Plant List สำหรับ navigation
      },
    );
  }
}

class PlantListPage extends StatelessWidget { // แก้ไขให้ PlantListPage เป็น StatelessWidget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant List'),
      ),
      body: Center(
        child: Text('Plant List Page'),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> randomPlants;

  @override
  void initState() {
    super.initState();
    randomPlants = fetchRandomPlants();
  }

  Future<List<Map<String, dynamic>>> fetchRandomPlants() async {
    final db = await db_helper.DatabaseHelper().database;
    final List<Map<String, dynamic>> plants = await db.query('plant');

    if (plants.length > 3) {
      plants.shuffle(Random());
      return plants.take(3).toList();
    } else {
      return plants;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Welcome to Plant Database App!',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/add_land_use');
            },
            child: Text('Add Land Use'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/view_edit_plant');
            },
            child: Text('View & Edit Plants'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/search_land_use');
            },
            child: Text('Search Land Use'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/plant_list');
            },
            child: Text('Plant List'),
          ),
          SizedBox(height: 20),
          Text(
            'Random Plants:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: randomPlants,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No plants found.'));
              } else {
                final plants = snapshot.data!;
                return Expanded(
                  child: ListView.builder(
                    itemCount: plants.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: FutureBuilder<Widget>(
                          future: _buildPlantImage(plants[index]['plantImage']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Container(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Icon(Icons.image_not_supported);
                            } else {
                              return snapshot.data ?? Icon(Icons.image_not_supported);
                            }
                          },
                        ),
                        title: Text(plants[index]['plantName']),
                        subtitle: Text(plants[index]['plantScientific']),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<Widget> _buildPlantImage(String? plantImage) async {
    if (plantImage != null && plantImage.isNotEmpty) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$plantImage';

        if (File(path).existsSync()) {
          return Image.file(
            File(path),
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.image_not_supported);
            },
          );
        } else {
          return Image.asset(
            'assets/images/$plantImage',
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.image_not_supported);
            },
          );
        }
      } catch (e) {
        return Icon(Icons.image_not_supported);
      }
    } else {
      return Icon(Icons.image_not_supported);
    }
  }
}
