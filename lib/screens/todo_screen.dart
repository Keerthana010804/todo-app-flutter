import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:confetti/confetti.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../services/notification_service.dart';
import '../widgets/task_item.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TaskService _taskService = TaskService();
  final TextEditingController _textController = TextEditingController();
  late ConfettiController _confettiController;
  
  List<Task> _activeTasks = [];
  List<Task> _completedTasks = [];
  bool _isLoading = true;

  // Form values
  TaskCategory _selectedCategory = TaskCategory.other;
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 1));
    _loadTasks();
  }

  @override
  void dispose() {
    _textController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final activeTasks = await _taskService.getActiveTasks();
      final completedTasks = await _taskService.getCompletedTasks();
      setState(() {
        _activeTasks = _taskService.sortTasksByImportanceAndDate(activeTasks);
        _completedTasks = completedTasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error loading tasks: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(milliseconds: 800),
        backgroundColor: Colors.grey.shade800,
      ),
    );
  }

  Future<void> _addTask() async {
    String taskTitle = _textController.text.trim();
    if (taskTitle.isEmpty) return;

    // Show date/time picker
    await _showTaskDialog(taskTitle: taskTitle);
  }

  Future<void> _showTaskDialog({String? taskTitle, Task? existingTask}) async {
    final isEditing = existingTask != null;
    final titleController = TextEditingController(text: isEditing ? existingTask!.title : taskTitle ?? '');
    
    setState(() {
      _selectedCategory = isEditing ? existingTask!.category : TaskCategory.other;
      _selectedPriority = isEditing ? existingTask!.priority : TaskPriority.medium;
      _selectedDueDate = isEditing ? existingTask!.dueDate : null;
      _selectedTime = isEditing && existingTask!.dueDate != null 
          ? TimeOfDay.fromDateTime(existingTask!.dueDate!) 
          : null;
    });

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isEditing ? 'Edit Task' : 'Add New Task'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: "Task Title",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TaskCategory>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: "Category",
                        border: OutlineInputBorder(),
                      ),
                      items: TaskCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: category.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(category.displayName),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => _selectedCategory = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TaskPriority>(
                      value: _selectedPriority,
                      decoration: InputDecoration(
                        labelText: "Priority",
                        border: OutlineInputBorder(),
                      ),
                      items: TaskPriority.values.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Row(
                            children: [
                              Icon(Icons.flag, size: 16, color: priority.color),
                              const SizedBox(width: 8),
                              Text(priority.displayName),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => _selectedPriority = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text("Due Date"),
                      subtitle: Text(_selectedDueDate != null 
                          ? "${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}"
                          : "No due date"),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDueDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (date != null) {
                          setDialogState(() => _selectedDueDate = date);
                        }
                      },
                    ),
                    if (_selectedDueDate != null)
                      ListTile(
                        title: const Text("Due Time"),
                        subtitle: Text(_selectedTime != null 
                            ? "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}"
                            : "No time set"),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime ?? TimeOfDay.now(),
                          );
                          if (time != null) {
                            setDialogState(() => _selectedTime = time);
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.trim().isEmpty) return;
                  
                  final task = Task(
                    id: isEditing ? existingTask!.id : DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text.trim(),
                    category: _selectedCategory,
                    priority: _selectedPriority,
                    dueDate: _selectedDueDate != null && _selectedTime != null
                        ? DateTime(
                            _selectedDueDate!.year,
                            _selectedDueDate!.month,
                            _selectedDueDate!.day,
                            _selectedTime!.hour,
                            _selectedTime!.minute,
                          )
                        : _selectedDueDate,
                    createdAt: isEditing ? existingTask!.createdAt : DateTime.now(),
                    isImportant: isEditing ? existingTask!.isImportant : false,
                  );

                  try {
                    if (isEditing) {
                      await _taskService.updateTask(task);
                      _showSnackBar("✅ Task Updated!");
                    } else {
                      await _taskService.saveTask(task);
                      await _scheduleNotification(task);
                      _showSnackBar("✅ Task Added!");
                    }
                    
                    _textController.clear();
                    await _loadTasks();
                    Navigator.pop(context);
                  } catch (e) {
                    _showSnackBar("Error: $e");
                  }
                },
                child: Text(isEditing ? "Update" : "Add"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _scheduleNotification(Task task) async {
    if (task.dueDate == null) return;
    
    try {
      if (kIsWeb || !(defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
        return;
      }
      
      await NotificationService().schedule(
        "🕒 Task Reminder",
        task.title,
        task.dueDate!,
      );
    } catch (e) {
      debugPrint('Schedule failed: $e');
    }
  }

  Future<void> _toggleImportant(Task task) async {
    final updatedTask = task.copyWith(isImportant: !task.isImportant);
    await _taskService.updateTask(updatedTask);
    await _loadTasks();
  }

  Future<void> _completeTask(Task task) async {
    _confettiController.play();
    await _taskService.completeTask(task);
    await _loadTasks();
    _showSnackBar("Task Completed! 🎉");
    
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: '🎉 Well Done!',
      desc: 'Task Completed Successfully!',
      btnOkOnPress: () {},
    ).show();
  }

  Future<void> _deleteTask(Task task) async {
    await _taskService.deleteTask(task.id);
    await _loadTasks();
    _showSnackBar("🗑️ Task Removed!");
  }

  Future<void> _clearCompletedTasks() async {
    await _taskService.clearCompletedTasks();
    await _loadTasks();
    _showSnackBar("✅ Cleared Completed Tasks!");
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text("Todo List"),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          body: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                labelText: "Enter a task",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          MaterialButton(
                            color: Colors.blueAccent,
                            textColor: Colors.white,
                            height: 50,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            onPressed: _addTask,
                            child: Icon(Icons.add),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: _activeTasks.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.task_alt, size: 64, color: Colors.grey),
                                    const SizedBox(height: 16),
                                    Text(
                                      "No tasks yet!\nAdd your first task above",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: _activeTasks.length,
                                itemBuilder: (context, index) {
                                  final task = _activeTasks[index];
                                  return TaskItem(
                                    task: task,
                                    onComplete: () => _completeTask(task),
                                    onDelete: () => _deleteTask(task),
                                    onToggleImportant: () => _toggleImportant(task),
                                    onEdit: () => _showTaskDialog(existingTask: task),
                                  );
                                },
                              ),
                      ),
                      if (_completedTasks.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("✅ Completed Tasks", 
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            TextButton(
                              onPressed: _clearCompletedTasks,
                              child: Text("Clear All"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 150,
                          child: ListView.builder(
                            itemCount: _completedTasks.length,
                            itemBuilder: (context, index) {
                              return Card(
                                color: Colors.green.shade50,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  title: Text(
                                    _completedTasks[index].title,
                                    style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
        ),
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.08,
            numberOfParticles: 120,
            maxBlastForce: 60,
            minBlastForce: 20,
            gravity: 0.2,
            shouldLoop: false,
            colors: [
              Colors.yellow.shade300,
              Colors.greenAccent,
              Colors.lightGreenAccent,
              Colors.amberAccent,
            ],
          ),
        )
      ],
    );
  }
}
