import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskService {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  static const String _tasksKey = 'tasks';
  static const String _completedTasksKey = 'completed_tasks';

  Future<List<Task>> getActiveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? tasksJson = prefs.getStringList(_tasksKey);
    
    if (tasksJson == null) return [];
    
    return tasksJson
        .map((json) => Task.fromJson(jsonDecode(json)))
        .where((task) => !task.isCompleted)
        .toList();
  }

  Future<List<Task>> getCompletedTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? tasksJson = prefs.getStringList(_completedTasksKey);
    
    if (tasksJson == null) return [];
    
    return tasksJson
        .map((json) => Task.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> saveTask(Task task) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tasksJson = prefs.getStringList(_tasksKey) ?? [];
    
    tasksJson.add(jsonEncode(task.toJson()));
    await prefs.setStringList(_tasksKey, tasksJson);
  }

  Future<void> updateTask(Task updatedTask) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tasksJson = prefs.getStringList(_tasksKey) ?? [];
    
    for (int i = 0; i < tasksJson.length; i++) {
      Task task = Task.fromJson(jsonDecode(tasksJson[i]));
      if (task.id == updatedTask.id) {
        tasksJson[i] = jsonEncode(updatedTask.toJson());
        break;
      }
    }
    
    await prefs.setStringList(_tasksKey, tasksJson);
  }

  Future<void> completeTask(Task task) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Remove from active tasks
    List<String> activeTasksJson = prefs.getStringList(_tasksKey) ?? [];
    activeTasksJson.removeWhere((json) {
      Task t = Task.fromJson(jsonDecode(json));
      return t.id == task.id;
    });
    await prefs.setStringList(_tasksKey, activeTasksJson);
    
    // Add to completed tasks
    List<String> completedTasksJson = prefs.getStringList(_completedTasksKey) ?? [];
    Task completedTask = task.copyWith(isCompleted: true);
    completedTasksJson.add(jsonEncode(completedTask.toJson()));
    await prefs.setStringList(_completedTasksKey, completedTasksJson);
  }

  Future<void> deleteTask(String taskId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Remove from active tasks
    List<String> activeTasksJson = prefs.getStringList(_tasksKey) ?? [];
    activeTasksJson.removeWhere((json) {
      Task task = Task.fromJson(jsonDecode(json));
      return task.id == taskId;
    });
    await prefs.setStringList(_tasksKey, activeTasksJson);
    
    // Remove from completed tasks
    List<String> completedTasksJson = prefs.getStringList(_completedTasksKey) ?? [];
    completedTasksJson.removeWhere((json) {
      Task task = Task.fromJson(jsonDecode(json));
      return task.id == taskId;
    });
    await prefs.setStringList(_completedTasksKey, completedTasksJson);
  }

  Future<void> clearCompletedTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedTasksKey);
  }

  List<Task> sortTasksByImportanceAndDate(List<Task> tasks) {
    final sortedTasks = List<Task>.from(tasks);
    sortedTasks.sort((a, b) {
      // Important tasks first
      if (a.isImportant != b.isImportant) {
        return a.isImportant ? -1 : 1;
      }
      
      // Then by priority
      if (a.priority != b.priority) {
        return b.priority.index.compareTo(a.priority.index);
      }
      
      // Then by due date (earliest first)
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      if (a.dueDate != null) return -1;
      if (b.dueDate != null) return 1;
      
      // Finally by creation date
      return a.createdAt.compareTo(b.createdAt);
    });
    return sortedTasks;
  }
}
