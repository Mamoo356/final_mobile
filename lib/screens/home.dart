import 'package:flutter/material.dart';
import 'dart:math'; // ใช้สำหรับสุ่ม
import 'package:final65111064/web/database_helper.dart'; // นำเข้า DatabaseHelper
import 'screens/add_plant.dart';
import 'screens/add_landuse.dart';
import 'screens/search_landuse.dart';
import 'screens/view_edit_plant.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _randomPlants = []; // รายชื่อพรรณไม้ที่สุ่มเลือกมา
  bool _isDbReady = false;

  @override
  void initState() {
    super.initState();
    _checkDatabase(); // ตรวจสอบฐานข้อมูลเมื่อเปิดหน้า Home
  }

  Future<void> _checkDatabase() async {
    try {
      final db = await DatabaseHelper().database; // ตรวจสอบการเชื่อมต่อกับฐานข้อมูล
      if (db != null) {
        setState(() {
          _isDbReady = true;
        });
        _fetchRandomPlants(); // ดึงข้อมูลพรรณไม้แบบสุ่ม
      }
    } catch (e) {
      // สร้างฐานข้อมูลใหม่หากยังไม่มี
      await DatabaseHelper().database;
      setState(() {
        _isDbReady = true;
      });
      _fetchRandomPlants(); // ดึงข้อมูลพรรณไม้แบบสุ่ม
    }
  }

  Future<void> _fetchRandomPlants() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> allPlants = await db.query('plant');
    final random = Random();
    final randomPlants = <Map<String, dynamic>>[];

    if (allPlants.length > 3) {
      while (randomPlants.length < 3) {
        final randomPlant = allPlants[random.nextInt(allPlants.length)];
        if (!randomPlants.contains(randomPlant)) {
          randomPlants.add(randomPlant);
        }
      }
    } else {
      randomPlants.addAll(allPlants); // แสดงข้อมูลทั้งหมดหากมีน้อยกว่า 3
    }

    setState(() {
      _randomPlants = randomPlants;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: _isDbReady
          ? Column(
              children: [
                _buildPlantList(), // แสดงรายชื่อพรรณไม้แบบสุ่ม
                _buildMenuButtons(), // ปุ่มสำหรับเชื่อมโยงไปหน้าจออื่นๆ
              ],
            )
          : Center(
              child: CircularProgressIndicator(), // แสดง Loading ขณะกำลังตรวจสอบฐานข้อมูล
            ),
    );
  }

  Widget _buildPlantList() {
    return _randomPlants.isEmpty
        ? Text('No plants available.')
        : Column(
            children: _randomPlants.map((plant) {
              return ListTile(
                leading: Image.asset(
                  'assets/images/${plant['plantImage']}', // แสดงรูปพรรณไม้
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(plant['plantName']),
                subtitle: Text(plant['plantScientific']),
              );
            }).toList(),
          );
  }

  Widget _buildMenuButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddPlantScreen()),
            );
          },
          child: Text('Add Plant'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddLandUseScreen()),
            );
          },
          child: Text('Add Land Use'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchLandUseScreen()),
            );
          },
          child: Text('Search Land Use'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ViewEditPlantScreen()),
            );
          },
          child: Text('View & Edit Plant'),
        ),
      ],
    );
  }
} 