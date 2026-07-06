import 'package:my_budget/src/data/models/savings_goal.dart';
import 'package:my_budget/src/data/models/transaction.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static const _databaseName = 'budget.db';
  static const _databaseVersion = 1;

  static const budgettransactionsTable = 'budgettransactions';
  static const savinggoalsTable = 'savinggoals';

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

  Future<String> databasePath() async {
    final db = await database;
    return db.path;
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

    await db.execute('''CREATE TABLE $savinggoalsTable(
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  category TEXT,
  currentAmount REAL NOT NULL,
  targetAmount REAL NOT NULL,
  dueDate TEXT NOT NULL,
  createdAt TEXT NOT NULL
)''');
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

  // goals methods
  Future<List<SavingGoal>> getGoals() async {
    final db = await database;

    final result = await db.query(savinggoalsTable, orderBy: 'createdAt DESC');

    return result.map((json) => SavingGoal.fromMap(json)).toList();
  }

  Future<SavingGoal?> getGoal(String id) async {
    final db = await database;

    final result = await db.query(
      savinggoalsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return SavingGoal.fromMap(result.first);
  }

  Future<void> insertGoal(SavingGoal goal) async {
    final db = await database;

    await db.insert(
      savinggoalsTable,
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateGoal(SavingGoal goal) async {
    final db = await database;

    await db.update(
      savinggoalsTable,
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<void> deleteGoal(String id) async {
    final db = await database;

    await db.delete(savinggoalsTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addFunds(String goalId, double amount) async {
    final goal = await getGoal(goalId);

    if (goal == null) return;

    await updateGoal(goal.copyWith(currentAmount: goal.currentAmount + amount));
  }

  // helper methods
  Future<double> getGoalProgress(String goalId) async {
    final goal = await getGoal(goalId);

    if (goal == null) return 0;

    return goal.currentAmount / goal.targetAmount;
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
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> reopen() async {
    _database = await _initDatabase();
  }
}
