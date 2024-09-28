import 'package:flutter/material.dart';
import 'package:final65111064/web/database_helper.dart'; // นำเข้า DatabaseHelper

class AddLandUseScreen extends StatefulWidget {
  @override
  _AddLandUseScreenState createState() => _AddLandUseScreenState();
}

class _AddLandUseScreenState extends State<AddLandUseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _landUseDescriptionController = TextEditingController();

  // ตัวแปรสำหรับ Dropdown Menu
  int? _selectedPlantComponent;
  int? _selectedLandUseType;
  List<Map<String, dynamic>> _plantComponents = [];
  List<Map<String, dynamic>> _landUseTypes = [];

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  // ฟังก์ชันสำหรับดึงข้อมูลชิ้นส่วนของพรรณไม้และประเภทการใช้ประโยชน์
  Future<void> _fetchDropdownData() async {
    final db = await DatabaseHelper().database;
    final plantComponents = await db.query('plantComponent');
    final landUseTypes = await db.query('LandUseType');

    setState(() {
      _plantComponents = plantComponents;
      _landUseTypes = landUseTypes;
    });
  }

  // ฟังก์ชันสำหรับบันทึกข้อมูลการใช้ประโยชน์
  Future<void> _saveLandUse() async {
    if (_formKey.currentState!.validate()) {
      final landUseData = {
        'plantID': 1, // ตัวอย่าง: ใส่ plantID ที่ต้องการ
        'componetID': _selectedPlantComponent,
        'LandUseTypeID': _selectedLandUseType,
        'LandUseDescription': _landUseDescriptionController.text
      };

      await DatabaseHelper().insertLandUse(landUseData);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Land Use added successfully!')));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _landUseDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Land Use'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Dropdown สำหรับเลือกชิ้นส่วนของพรรณไม้
                DropdownButtonFormField<int>(
                  value: _selectedPlantComponent,
                  hint: Text('Select Plant Component'),
                  items: _plantComponents.map((component) {
                    return DropdownMenuItem<int>(
                      value: component['componetID'],
                      child: Text(component['componentName']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPlantComponent = value;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a plant component' : null,
                ),
                SizedBox(height: 16.0),

                // Dropdown สำหรับเลือกประเภทการใช้ประโยชน์
                DropdownButtonFormField<int>(
                  value: _selectedLandUseType,
                  hint: Text('Select Land Use Type'),
                  items: _landUseTypes.map((useType) {
                    return DropdownMenuItem<int>(
                      value: useType['LandUseTypeID'],
                      child: Text(useType['LandUseTypeName']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLandUseType = value;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a land use type' : null,
                ),
                SizedBox(height: 16.0),

                // TextFormField สำหรับคำอธิบายการใช้ประโยชน์
                TextFormField(
                  controller: _landUseDescriptionController,
                  decoration: InputDecoration(labelText: 'Land Use Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),

                // ปุ่มบันทึกข้อมูล
                ElevatedButton(
                  onPressed: _saveLandUse,
                  child: Text('Save Land Use'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
