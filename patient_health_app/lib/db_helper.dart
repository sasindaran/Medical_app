import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        // Create users table
        await db.execute('''
          CREATE TABLE users (
            username TEXT PRIMARY KEY,
            password TEXT,
            role TEXT
          )
        ''');

        // Create records table
        await db.execute('''
          CREATE TABLE records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT,
            visit_date TEXT,
            cause TEXT,
            prescription TEXT,
            FOREIGN KEY(user_id) REFERENCES users(username)
          )
        ''');

        // Create priority conditions table
        await db.execute('''
          CREATE TABLE priority_conditions (
            user_id TEXT PRIMARY KEY,
            treatment TEXT,
            prescription TEXT,
            FOREIGN KEY(user_id) REFERENCES users(username)
          )
        ''');

        // Insert default admin
        await db.insert('users', {
          'username': 'key_one',
          'password': 'root',
          'role': 'Admin',
        });
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE priority_conditions (
              user_id TEXT PRIMARY KEY,
              treatment TEXT,
              prescription TEXT,
              FOREIGN KEY(user_id) REFERENCES users(username)
            )
          ''');
        }
      },
    );
  }

  // Insert user
  Future<void> insertUser(String username, String password, String role) async {
    final db = await database;
    await db.insert(
      'users',
      {'username': username, 'password': password, 'role': role},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Validate login
  Future<Map<String, dynamic>?> validateUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Get users
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  // Delete user
  Future<void> deleteUser(String username) async {
    final db = await database;
    await db.delete('users', where: 'username = ?', whereArgs: [username]);
  }

  // Update password
  Future<void> updateUser(String username, String newPassword) async {
    final db = await database;
    await db.update(
      'users',
      {'password': newPassword},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  // Insert visit record
  Future<void> insertRecord(String username, String visitDate, String cause, String prescription) async {
    final db = await database;
    await db.insert(
      'records',
      {
        'user_id': username,
        'visit_date': visitDate,
        'cause': cause,
        'prescription': prescription,
      },
    );
  }

  // Get records by username
  Future<List<Map<String, dynamic>>> getRecordsByUsername(String username) async {
    final db = await database;
    return await db.query(
      'records',
      where: 'user_id = ?',
      whereArgs: [username],
      orderBy: 'id DESC',
    );
  }

  // Set priority condition
  Future<void> setPriorityCondition(String username, String treatment, String prescription) async {
    final db = await database;
    await db.insert(
      'priority_conditions',
      {
        'user_id': username,
        'treatment': treatment,
        'prescription': prescription,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get priority condition
  Future<Map<String, dynamic>?> getPriorityCondition(String username) async {
    final db = await database;
    final result = await db.query(
      'priority_conditions',
      where: 'user_id = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty ? result.first : null;
  }
}
