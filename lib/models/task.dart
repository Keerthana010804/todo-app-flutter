import 'package:flutter/material.dart';

enum TaskCategory {
  work('Work', Colors.blue),
  personal('Personal', Colors.green),
  shopping('Shopping', Colors.orange),
  health('Health', Colors.red),
  other('Other', Colors.grey);

  const TaskCategory(this.displayName, this.color);
  final String displayName;
  final Color color;
}

enum TaskPriority {
  low('Low', Colors.green),
  medium('Medium', Colors.orange),
  high('High', Colors.red);

  const TaskPriority(this.displayName, this.color);
  final String displayName;
  final Color color;
}

class Task {
  final String id;
  final String title;
  final bool isImportant;
  final DateTime? dueDate;
  final TaskCategory category;
  final TaskPriority priority;
  final DateTime createdAt;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.isImportant = false,
    this.dueDate,
    this.category = TaskCategory.other,
    this.priority = TaskPriority.medium,
    required this.createdAt,
    this.isCompleted = false,
  });

  Task copyWith({
    String? id,
    String? title,
    bool? isImportant,
    DateTime? dueDate,
    TaskCategory? category,
    TaskPriority? priority,
    DateTime? createdAt,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isImportant: isImportant ?? this.isImportant,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isImportant': isImportant,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'category': category.name,
      'priority': priority.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      isImportant: json['isImportant'] ?? false,
      dueDate: json['dueDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['dueDate'])
          : null,
      category: TaskCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TaskCategory.other,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
