import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final VoidCallback onToggleImportant;
  final VoidCallback onEdit;

  const TaskItem({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onDelete,
    required this.onToggleImportant,
    required this.onEdit,
  });

  @override
Widget build(BuildContext context) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeInOut,
    margin: const EdgeInsets.symmetric(vertical: 6),
    child: Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TITLE + STAR
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          task.isImportant ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    task.isImportant ? Icons.star : Icons.star_border,
                    color: task.isImportant ? Colors.amber : Colors.grey,
                  ),
                  iconSize: 22,
                  onPressed: onToggleImportant,
                ),
              ],
            ),

            const SizedBox(height: 6),

            /// CATEGORY + PRIORITY + DUE DATE (SINGLE LINE, AUTO-WRAP)
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                /// CATEGORY
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: task.category.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: task.category.color),
                  ),
                  child: Text(
                    task.category.displayName,
                    style: TextStyle(
                      fontSize: 11,
                      color: task.category.color,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                /// PRIORITY
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: task.priority.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: task.priority.color),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flag, size: 12, color: task.priority.color),
                      const SizedBox(width: 4),
                      Text(
                        task.priority.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          color: task.priority.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                /// DUE DATE
                if (task.dueDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule, size: 12, color: Colors.grey[700]),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(task.dueDate!),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            /// ACTION BUTTONS (UNCHANGED)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  iconSize: 20,
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  iconSize: 20,
                  onPressed: () {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.question,
                      animType: AnimType.bottomSlide,
                      title: 'Complete Task',
                      desc: 'Are you sure you want to complete this task?',
                      btnOkOnPress: onComplete,
                      btnCancelOnPress: () {},
                    ).show();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  iconSize: 20,
                  onPressed: () {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.warning,
                      animType: AnimType.bottomSlide,
                      title: 'Delete Task',
                      desc: 'Are you sure you want to delete this task?',
                      btnOkOnPress: onDelete,
                      btnCancelOnPress: () {},
                    ).show();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}


  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);
    
    if (taskDate == today) {
      return 'Today ${_formatTime(date)}';
    } else if (taskDate == today.add(Duration(days: 1))) {
      return 'Tomorrow ${_formatTime(date)}';
    } else if (taskDate == today.subtract(Duration(days: 1))) {
      return 'Yesterday ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year} ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
