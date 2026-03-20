import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expense_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    // Users table
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        firebase_uid $textType UNIQUE,
        name $textType,
        email $textType,
        profile_picture_path TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id $idType,
        user_id $intType,
        amount $realType,
        category $textType,
        date TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Income table
    await db.execute('''
      CREATE TABLE income (
        id $idType,
        user_id $intType,
        amount $realType,
        source $textType,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Budgets table
    await db.execute('''
      CREATE TABLE budgets (
        id $idType,
        user_id $intType,
        category $textType,
        budget_amount $realType,
        month $intType,
        year $intType,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  // ========== USER OPERATIONS ==========

  Future<int> createUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByFirebaseUid(String firebaseUid) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'firebase_uid = ?',
      whereArgs: [firebaseUid],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<int> updateUser(int id, Map<String, dynamic> user) async {
    final db = await database;
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateUserProfilePicture(int userId, String picturePath) async {
    final db = await database;
    return await db.update(
      'users',
      {'profile_picture_path': picturePath},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // ========== EXPENSE OPERATIONS ==========

  Future<int> createExpense(Map<String, dynamic> expense) async {
    final db = await database;
    return await db.insert('expenses', expense);
  }

  Future<List<Map<String, dynamic>>> getExpensesByUserId(int userId) async {
    final db = await database;
    return await db.query(
      'expenses',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
  }

  Future<double> getTotalExpensesByUserId(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE user_id = ?',
      [userId],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== INCOME OPERATIONS ==========

  Future<int> createIncome(Map<String, dynamic> income) async {
    final db = await database;
    return await db.insert('income', income);
  }

  Future<List<Map<String, dynamic>>> getIncomeByUserId(int userId) async {
    final db = await database;
    return await db.query(
      'income',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
  }

  Future<double> getTotalIncomeByUserId(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM income WHERE user_id = ?',
      [userId],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<int> deleteIncome(int id) async {
    final db = await database;
    return await db.delete(
      'income',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== BUDGET OPERATIONS ==========

  Future<int> createBudget(Map<String, dynamic> budget) async {
    final db = await database;
    return await db.insert('budgets', budget);
  }

  Future<List<Map<String, dynamic>>> getBudgetsByUserId(int userId, int month, int year) async {
    final db = await database;
    return await db.query(
      'budgets',
      where: 'user_id = ? AND month = ? AND year = ?',
      whereArgs: [userId, month, year],
    );
  }

  Future<int> updateBudget(int id, Map<String, dynamic> budget) async {
    final db = await database;
    return await db.update(
      'budgets',
      budget,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteBudgetsByUserId(int userId, int month, int year) async {
    final db = await database;
    return await db.delete(
      'budgets',
      where: 'user_id = ? AND month = ? AND year = ?',
      whereArgs: [userId, month, year],
    );
  }

  // ========== TRANSACTION HISTORY (Combined Income + Expenses) ==========

  Future<List<Map<String, dynamic>>> getAllTransactionsByUserId(int userId) async {
    final db = await database;
    
    // Get all expenses
    final expenses = await db.query(
      'expenses',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    // Get all income
    final incomes = await db.query(
      'income',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    // Combine and format
    List<Map<String, dynamic>> transactions = [];
    
    for (var expense in expenses) {
      transactions.add({
        'type': 'expense',
        'amount': expense['amount'],
        'category': expense['category'],
        'date': expense['date'],
        'note': expense['note'] ?? '',
      });
    }
    
    for (var income in incomes) {
      transactions.add({
        'type': 'income',
        'amount': income['amount'],
        'category': income['source'],
        'date': income['date'],
        'note': 'Income from ${income['source']}',
      });
    }
    
    // Sort by date (newest first)
    transactions.sort((a, b) => 
      DateTime.parse(b['date']).compareTo(DateTime.parse(a['date']))
    );
    
    return transactions;
  }

  // ========== UTILITY ==========

  Future close() async {
    final db = await database;
    db.close();
  }

  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete('budgets');
    await db.delete('income');
    await db.delete('expenses');
    await db.delete('users');
  }
}