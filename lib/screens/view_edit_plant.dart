import 'package:flutter/material.dart';
import 'package:final65111064/web/database_helper.dart'; // นำเข้า DatabaseHelper
import 'plant_detail.dart'; // นำเข้าหน้าจอ PlantDetailScreen

class ViewEditPlantScreen extends StatefulWidget {
  @override
  _ViewEditPlantScreenState createState() => _ViewEditPlantScreenState();
}

class _ViewEditPlantScreenState extends State<ViewEditPlantScreen> {
  late Future<List<Map<String, dynamic>>> plantList;

  @override
  void initState() {
    super.initState();
    plantList = fetchPlants();
  }

  Future<List<Map<String, dynamic>>> fetchPlants() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query('plant');
    return maps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View & Edit Plants'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: plantList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No plants found.'));
          } else {
            final plants = snapshot.data!;
            return ListView.builder(
              itemCount: plants.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(plants[index]['plantName']),
                  subtitle: Text(plants[index]['plantScientific']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlantDetailScreen(plantId: plants[index]['plantID']),
                      ),
                    ).then((_) {
                      setState(() {
                        plantList = fetchPlants(); // Refresh list after editing
                      });
                    });
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
