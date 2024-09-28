import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:final65111064/web/database_helper.dart'; // นำเข้าคลาส DatabaseHelper

class AddPlantScreen extends StatefulWidget {
  @override
  _AddPlantScreenState createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plantNameController = TextEditingController();
  final _plantScientificController = TextEditingController();
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _plantNameController.dispose();
    _plantScientificController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _savePlant() async {
    if (_formKey.currentState!.validate()) {
      String? fileName;
      if (_selectedImage != null) {
        fileName = path.basename(_selectedImage!.path);
      }

      final plantData = {
        'plantName': _plantNameController.text,
        'plantScientific': _plantScientificController.text,
        'plantImage': fileName ?? 'tree1.jpg' 
      };

      // เรียกใช้งาน DatabaseHelper เพื่อเพิ่มข้อมูลลงในฐานข้อมูล
      await DatabaseHelper().insertPlant(plantData);

      // แสดงข้อความแจ้งเตือนและกลับไปยังหน้ารายการพรรณไม้
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Plant added successfully!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Plant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                _selectedImage == null
                    ? Text('No image selected.')
                    : Image.file(
                        _selectedImage!,
                        height: 150,
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton.icon(
                      icon: Icon(Icons.photo),
                      label: Text('Gallery'),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.camera),
                      label: Text('Camera'),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _savePlant,
                  child: Text('Save Plant'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
