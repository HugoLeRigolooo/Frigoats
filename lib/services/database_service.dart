import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/PlatsModel.dart';
import '../models/AlimentModel.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('frigoats.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // Version 3 pour inclure la table liste de courses
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Table des PLATS
    await db.execute('''
      CREATE TABLE plats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        duration TEXT,
        type TEXT,
        photo TEXT,
        prix INTEGER,
        ingredients TEXT
      )
    ''');

    // Table des ALIMENTS (Frigo)
    await db.execute('''
      CREATE TABLE aliments (
        id TEXT PRIMARY KEY,
        nom TEXT,
        quantite INTEGER,
        unite TEXT,
        datePeremption TEXT
      )
    ''');

    // Table LISTE DE COURSES
    await db.execute('''
      CREATE TABLE alimentsListeCourses (
        id TEXT PRIMARY KEY,
        nom TEXT,
        quantite INTEGER,
        unite TEXT,
        datePeremption TEXT
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE aliments (
          id TEXT PRIMARY KEY,
          nom TEXT,
          quantite INTEGER,
          unite TEXT,
          datePeremption TEXT
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE alimentsListeCourses (
          id TEXT PRIMARY KEY,
          nom TEXT,
          quantite INTEGER,
          unite TEXT,
          datePeremption TEXT
        )
      ''');
    }
  }

  // --- MÉTHODES PLATS ---
  Future<void> createPlat(PlatsModel plat) async {
    final db = await instance.database;
    await db.insert('plats', plat.toMap());
  }

  Future<List<PlatsModel>> readAllPlats() async {
    final db = await instance.database;
    final result = await db.query('plats');
    return result.map((json) => PlatsModel.fromMap(json)).toList();
  }

  Future<void> deletePlat(int id) async {
    final db = await instance.database;
    await db.delete('plats', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteMultiplePlats(List<int> ids) async {
    final db = await instance.database;
    Batch batch = db.batch();
    for (int id in ids) {
      batch.delete('plats', where: 'id = ?', whereArgs: [id]);
    }
    await batch.commit(noResult: true);
  }

  // --- MÉTHODES FRIGO ---
  Future<void> createAliment(Aliment aliment) async {
    final db = await instance.database;
    await db.insert('aliments', aliment.toMap());
  }

  Future<List<Aliment>> readAllAliments() async {
    final db = await instance.database;
    final result = await db.query('aliments', orderBy: 'datePeremption ASC');
    return result.map((json) => Aliment.fromMap(json)).toList();
  }

  Future<void> deleteAliment(String id) async {
    final db = await instance.database;
    await db.delete('aliments', where: 'id = ?', whereArgs: [id]);
  }

  // --- MÉTHODES LISTE DE COURSES ---
  Future<void> createAlimentListeCourses(Aliment aliment) async {
    final db = await instance.database;
    await db.insert('alimentsListeCourses', aliment.toMap());
  }

  Future<List<Aliment>> readAllAlimentsListeCourses() async {
    final db = await instance.database;
    final result = await db.query('alimentsListeCourses');
    return result.map((json) => Aliment.fromMap(json)).toList();
  }

  Future<void> deleteAlimentListeCourses(String id) async {
    final db = await instance.database;
    await db.delete('alimentsListeCourses', where: 'id = ?', whereArgs: [id]);
  }
}