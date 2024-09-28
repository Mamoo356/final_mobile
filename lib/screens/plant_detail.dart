import 'package:flutter/material.dart';
import 'package:final65111064/web/database_helper.dart'; // นำเข้า DatabaseHelper

class PlantDetailScreen extends StatefulWidget {
  final int plantId; // รับ plantId จากหน้าก่อนหน้า

  PlantDetailScreen({required this.plantId});

  @override
  _PlantDetailScreenState createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plantNameController = TextEditingController();
  final _plantScientificController = TextEditingController();
  late Future<Map<String, dynamic>?> plantDetails;

  @override
  void initState() {
    super.initState();
    plantDetails = fetchPlantDetails();
  }

  Future<Map<String, dynamic>?> fetchPlantDetails() async {
    final db = await DatabaseHelper().database;
    final plant = await db.query(
      'plant',
      where: 'plantID = ?',
      whereArgs: [widget.plantId],
    );
    if (plant.isNotEmpty) {
      return plant.first;
    }
    return null;
  }

  Future<void> _updatePlant() async {
    if (_formKey.currentState!.validate()) {
      final updatedPlantData = {
        'plantName': _plantNameController.text,
        'plantScientific': _plantScientificController.text,
      };

      final db = await DatabaseHelper().database;
      await db.update(
        'plant',
        updatedPlantData,
        where: 'plantID = ?',
        whereArgs: [widget.plantId],
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Plant updated successfully!')));
      Navigator.pop(context); // กลับไปหน้าก่อนหน้าเมื่อบันทึกสำเร็จ
    }
  }

  @override
  void dispose() {
    _plantNameController.dispose();
    _plantScientificController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Plant Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: plantDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Plant not found.'));
          } else {
            final plant = snapshot.data!;
            _plantNameController.text = plant['plantName'];
            _plantScientificController.text = plant['plantScientific'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      controller: _plantNameController,
                      decoration: InputDecoration(labelText: 'Plant Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the plant name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _plantScientificController,
                      decoration: InputDecoration(labelText: 'Scientific Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the scientific name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    // แสดงภาพพรรณไม้
                    Text('Plant Image:'),
                    Image.asset(
                      'assets/images/${plant['plantImage']}', // ใช้ Image.asset แทน File
                      height: 300,
                      width: 300,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _updatePlant,
                      child: Text('Update Plant'),
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
}
