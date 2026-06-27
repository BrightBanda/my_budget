import 'package:my_budget/src/data/models/transaction.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static const _databaseName = 'budget.db';
  static const _databaseVersion = 1;

  static const budgettransactionsTable = 'budgettransactions';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();

    return openDatabase(
      join(dbPath, _databaseName),
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $budgettransactionsTable(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<List<BudgetTransaction>> getTransactions() async {
    final db = await database;

    final result = await db.query(
      budgettransactionsTable,
      orderBy: 'date DESC',
    );

    return result.map((json) => BudgetTransaction.fromMap(json)).toList();
  }

  Future<BudgetTransaction?> getTransaction(String id) async {
    final db = await database;

    final result = await db.query(
      budgettransactionsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return BudgetTransaction.fromMap(result.first);
  }

  Future<void> insertTransaction(BudgetTransaction budgettransaction) async {
    final db = await database;

    await db.insert(
      budgettransactionsTable,
      budgettransaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTransaction(BudgetTransaction budgettransaction) async {
    final db = await database;

    await db.update(
      budgettransactionsTable,
      budgettransaction.toMap(),
      where: 'id = ?',
      whereArgs: [budgettransaction.id],
    );
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;

    await db.delete(budgettransactionsTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalIncome() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM $budgettransactionsTable
      WHERE type = 'income'
    ''');

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalExpenses() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM $budgettransactionsTable
      WHERE type = 'expense'
    ''');

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getBalance() async {
    final income = await getTotalIncome();
    final expenses = await getTotalExpenses();

    return income - expenses;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
