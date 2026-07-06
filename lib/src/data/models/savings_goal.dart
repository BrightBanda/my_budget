class SavingGoal {
  final String id;
  final String title;
  final String? category;
  final double currentAmount;
  final double targetAmount;
  final DateTime dueDate;
  final DateTime createdAt;

  const SavingGoal({
    required this.id,
    required this.title,
    this.category,
    required this.currentAmount,
    required this.targetAmount,
    required this.dueDate,
    required this.createdAt,
  });

  double get progress => currentAmount / targetAmount;
  bool get isCompleted => currentAmount >= targetAmount;
  int get daysLeft => dueDate.difference(DateTime.now()).inDays;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'currentAmount': currentAmount,
      'targetAmount': targetAmount,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SavingGoal.fromMap(Map<String, dynamic> map) {
    return SavingGoal(
      id: map['id'] as String,
      title: map['title'] as String,
      category: map['category'] as String?,
      currentAmount: (map['currentAmount'] as num).toDouble(),
      targetAmount: (map['targetAmount'] as num).toDouble(),
      dueDate: DateTime.parse(map['dueDate'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  SavingGoal copyWith({
    String? id,
    String? title,
    String? category,
    double? currentAmount,
    double? targetAmount,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return SavingGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      currentAmount: currentAmount ?? this.currentAmount,
      targetAmount: targetAmount ?? this.targetAmount,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
