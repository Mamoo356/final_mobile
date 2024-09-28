import 'package:flutter/material.dart';
import 'package:final65111064/web/database_helper.dart'; // นำเข้า DatabaseHelper

class SearchLandUseScreen extends StatefulWidget {
  @override
  _SearchLandUseScreenState createState() => _SearchLandUseScreenState();
}

class _SearchLandUseScreenState extends State<SearchLandUseScreen> {
  final _searchController = TextEditingController();
  String? _selectedComponent;
  String? _selectedLandUseType;
  List<Map<String, dynamic>> _landUses = [];

  List<String> components = [
    'Leaf',
    'Flower',
    'Fruit',
    'Stem',
    'Root'
  ];

  List<String> landUseTypes = [
    'Food',
    'Medicine',
    'Insecticide',
    'Construction',
    'Culture'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchLandUses() async {
    final db = await DatabaseHelper().database;
    final plantName = _searchController.text;

    // ค้นหาข้อมูลการใช้ประโยชน์จากพรรณไม้
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT lu.LandUseDescription, p.plantName, p.plantScientific
      FROM LandUse lu
      JOIN plant p ON lu.plantID = p.plantID
      JOIN plantComponent c ON lu.componetID = c.componetID
      JOIN LandUseType lut ON lu.LandUseTypeID = lut.LandUseTypeID
      WHERE p.plantName LIKE ? 
      OR c.componentName = ? 
      OR lut.LandUseTypeName = ?
    ''', ['%$plantName%', _selectedComponent ?? '', _selectedLandUseType ?? '']);

    setState(() {
      _landUses = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Land Use'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(labelText: 'Search by Plant Name'),
            ),
            SizedBox(height: 16.0),
            DropdownButton<String>(
              value: _selectedComponent,
              hint: Text('Select Plant Component'),
              items: components.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedComponent = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            DropdownButton<String>(
              value: _selectedLandUseType,
              hint: Text('Select Land Use Type'),
              items: landUseTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLandUseType = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _searchLandUses,
              child: Text('Search'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _landUses.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_landUses[index]['plantName']),
                    subtitle: Text(_landUses[index]['LandUseDescription']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
