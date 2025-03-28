import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import '../../data/models/task_model.dart';

class DatabaseInitializer {
  static Database? _sqliteDatabase;

  /// Centralized Initialization for Hive or SQLite
  static Future<void> initialize({required bool useSQLite}) async {
    if (useSQLite) {
      _sqliteDatabase = await _initSQLite();
    } else {
      await _initHive();
    }
  }

  /// Initialize Encrypted SQLite
  static Future<Database> _initSQLite() async {
    final path = join(await getDatabasesPath(), 'tasks_encrypted.db');
    const storage = FlutterSecureStorage();

    // Retrieve or create the encryption key
    String? passphrase = await storage.read(key: 'sqlite_passphrase');
    if (passphrase == null) {
      passphrase = 'super_secure_key'; // In production, generate securely!
      await storage.write(key: 'sqlite_passphrase', value: passphrase);
    }

    return await openDatabase(
      path,
      password: passphrase,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          """CREATE TABLE tasks(
            id TEXT PRIMARY KEY, 
            title TEXT, 
            description TEXT,
            isCompleted INTEGER,
            userId TEXT,
            createdAt INTEGER,
            updatedAt INTEGER
          )""",
        );
      },
    );
  }

  /// Initialize Hive (with TaskModel registration)
  static Future<void> _initHive() async {
    await Hive.initFlutter();

    // Register TaskModel Adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskModelAdapter());
    }

    // Open Hive Box
    await Hive.openBox<TaskModel>('tasks');
  }

  /// Provide Access to SQLite
  static Database get sqliteDatabase {
    if (_sqliteDatabase == null) {
      throw Exception("SQLite has not been initialized. Call initialize().");
    }
    return _sqliteDatabase!;
  }
}
