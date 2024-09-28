import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'plant_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // สร้างตารางสำหรับฐานข้อมูล
    await db.execute('''
      CREATE TABLE plant (
        plantID INTEGER PRIMARY KEY AUTOINCREMENT,
        plantName TEXT,
        plantScientific TEXT,
        plantImage TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE plantComponent (
        componetID INTEGER PRIMARY KEY AUTOINCREMENT,
        componentName TEXT,
        componentIcon TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE LandUseType (
        LandUseTypeID INTEGER PRIMARY KEY AUTOINCREMENT,
        LandUseTypeName TEXT,
        LandUseTypeDescription TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE LandUse (
        LandUseID INTEGER PRIMARY KEY AUTOINCREMENT,
        plantID INTEGER,
        componetID INTEGER,
        LandUseTypeID INTEGER,
        LandUseDescription TEXT,
        FOREIGN KEY(plantID) REFERENCES plant(plantID),
        FOREIGN KEY(componetID) REFERENCES plantComponent(componetID),
        FOREIGN KEY(LandUseTypeID) REFERENCES LandUseType(LandUseTypeID)
      )
    ''');

    // ใส่ข้อมูลเริ่มต้นในฐานข้อมูล
    await _insertInitialData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // จัดการกับการอัพเกรดฐานข้อมูล เช่น เพิ่มคอลัมน์ใหม่ หรือลบข้อมูลเก่า
    if (oldVersion < 2) {
      // ตัวอย่าง: เพิ่มคอลัมน์ใหม่ในตาราง plant
      await db.execute('ALTER TABLE plant ADD COLUMN newColumn TEXT');
    }
  }

  Future<void> _insertInitialData(Database db) async {
    // ข้อมูลเริ่มต้นสำหรับตาราง plant
    await db.insert('plant', {
      'plantName': 'Mango',
      'plantScientific': 'Mangifera indica',
      'plantImage': 'tree1.jpg'
    });

    await db.insert('plant', {
      'plantName': 'Neem',
      'plantScientific': 'Azadirachta indica',
      'plantImage': 'tree1.jpg'
    });

    await db.insert('plant', {
      'plantName': 'Bamboo',
      'plantScientific': 'Bambusa vulgaris',
      'plantImage': 'tree1.jpg'
    });

    await db.insert('plant', {
      'plantName': 'Ginger',
      'plantScientific': 'Zingiber officinale',
      'plantImage': 'tree1.jpg'
    });

    // ข้อมูลเริ่มต้นสำหรับตาราง plantComponent
    await db.insert('plantComponent', {
      'componentName': 'Leaf',
      'componentIcon': 'icon.jpg'
    });

    await db.insert('plantComponent', {
      'componentName': 'Flower',
      'componentIcon': 'icon.jpg'
    });

    await db.insert('plantComponent', {
      'componentName': 'Fruit',
      'componentIcon': 'icon.jpg'
    });

    await db.insert('plantComponent', {
      'componentName': 'Stem',
      'componentIcon': 'icon.jpg'
    });

    await db.insert('plantComponent', {
      'componentName': 'Root',
      'componentIcon': 'icon.jpg'
    });

    // ข้อมูลเริ่มต้นสำหรับตาราง LandUseType
    await db.insert('LandUseType', {
      'LandUseTypeName': 'Food',
      'LandUseTypeDescription': 'Used as food or ingredients'
    });

    await db.insert('LandUseType', {
      'LandUseTypeName': 'Medicine',
      'LandUseTypeDescription': 'Used for medicinal purposes'
    });

    await db.insert('LandUseType', {
      'LandUseTypeName': 'Insecticide',
      'LandUseTypeDescription': 'Used to repel insects'
    });

    await db.insert('LandUseType', {
      'LandUseTypeName': 'Construction',
      'LandUseTypeDescription': 'Used in building materials'
    });

    await db.insert('LandUseType', {
      'LandUseTypeName': 'Culture',
      'LandUseTypeDescription': 'Used in traditional practices'
    });

    // ข้อมูลเริ่มต้นสำหรับตาราง LandUse
    await db.insert('LandUse', {
      'plantID': 1,
      'componetID': 3,
      'LandUseTypeID': 1,
      'LandUseDescription': 'Mango fruit is eaten fresh or dried'
    });

    await db.insert('LandUse', {
      'plantID': 2,
      'componetID': 1,
      'LandUseTypeID': 2,
      'LandUseDescription': 'Neem leaves are used to treat skin infections'
    });

    await db.insert('LandUse', {
      'plantID': 3,
      'componetID': 4,
      'LandUseTypeID': 4,
      'LandUseDescription': 'Bamboo stems are used in building houses'
    });

    await db.insert('LandUse', {
      'plantID': 4,
      'componetID': 5,
      'LandUseTypeID': 2,
      'LandUseDescription': 'Ginger roots are used for digestive issues'
    });
  }

  // ฟังก์ชันสำหรับการเพิ่มข้อมูลพรรณไม้
  Future<void> insertPlant(Map<String, dynamic> plantData) async {
    final db = await database;
    await db.insert('plant', plantData);
  }

  // ฟังก์ชันสำหรับการเพิ่มข้อมูลชิ้นส่วนพรรณไม้
  Future<void> insertComponent(Map<String, dynamic> componentData) async {
    final db = await database;
    await db.insert('plantComponent', componentData);
  }

  // ฟังก์ชันสำหรับการเพิ่มข้อมูลประเภทการใช้ประโยชน์
  Future<void> insertLandUseType(Map<String, dynamic> landUseTypeData) async {
    final db = await database;
    await db.insert('LandUseType', landUseTypeData);
  }

  // ฟังก์ชันสำหรับการเพิ่มข้อมูลการใช้ประโยชน์
  Future<void> insertLandUse(Map<String, dynamic> landUseData) async {
    final db = await database;
    await db.insert('LandUse', landUseData);
  }

  // ฟังก์ชันสำหรับการดึงข้อมูลพรรณไม้ทั้งหมด
  Future<List<Map<String, dynamic>>> getAllPlants() async {
    final db = await database;
    return await db.query('plant');
  }

  // ฟังก์ชันสำหรับการดึงข้อมูลพรรณไม้ตาม plantID
  Future<Map<String, dynamic>?> getPlantById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'plant',
      where: 'plantID = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // ฟังก์ชันสำหรับการอัพเดตข้อมูลพรรณไม้
  Future<void> updatePlant(int id, Map<String, dynamic> newData) async {
    final db = await database;
    await db.update(
      'plant',
      newData,
      where: 'plantID = ?',
      whereArgs: [id],
    );
  }

  // ฟังก์ชันสำหรับการลบข้อมูลพรรณไม้
  Future<void> deletePlant(int id) async {
    final db = await database;
    await db.delete('plant', where: 'plantID = ?', whereArgs: [id]);
  }
}
