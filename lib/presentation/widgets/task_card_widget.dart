import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleComplete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleComplete,
  });

  Future<bool?> _showConfirmationDialog(BuildContext context, String action) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action == 'delete' ? 'Delete Task' : 'Complete Task'),
        content: Text(action == 'delete' ? 'Are you sure you want to delete this task?' : 'Mark this task as ${task.isCompleted ? 'incomplete' : 'complete'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              action == 'delete' ? 'Delete' : 'Yes',
              style: TextStyle(
                color: action == 'delete' ? Colors.red : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swipe left to delete
          return await _showConfirmationDialog(context, 'delete');
        } else if (direction == DismissDirection.startToEnd) {
          // Swipe right to toggle completion
          return await _showConfirmationDialog(context, 'complete');
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete();
        } else if (direction == DismissDirection.startToEnd) {
          onToggleComplete();
        }
      },
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        color: Colors.green,
        child: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Complete',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerRight,
        color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Text(
              'Delete',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete, color: Colors.white),
          ],
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ListTile(
          onTap: onTap,
          title: TaskTitle(
            title: task.title,
            isCompleted: task.isCompleted,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.description.isEmpty ? 'No description' : task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              TaskStatus(isCompleted: task.isCompleted),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final shouldDelete = await _showConfirmationDialog(context, 'delete');
                  if (shouldDelete == true) {
                    onDelete();
                  }
                },
              ),
              TaskCompletionCheckbox(
                isCompleted: task.isCompleted,
                onToggleComplete: onToggleComplete,
              ),
            ],
          ),
          isThreeLine: true,
        ),
      ),
    );
  }
}

class TaskTitle extends StatefulWidget {
  final String title;
  final bool isCompleted;

  const TaskTitle({
    super.key,
    required this.title,
    required this.isCompleted,
  });

  @override
  State<TaskTitle> createState() => _TaskTitleState();
}

class _TaskTitleState extends State<TaskTitle> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.title,
      style: TextStyle(
        decoration: widget.isCompleted ? TextDecoration.lineThrough : null,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class TaskStatus extends StatefulWidget {
  final bool isCompleted;

  const TaskStatus({
    super.key,
    required this.isCompleted,
  });

  @override
  State<TaskStatus> createState() => _TaskStatusState();
}

class _TaskStatusState extends State<TaskStatus> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.isCompleted ? 'Completed' : 'Pending',
      style: TextStyle(
        color: widget.isCompleted ? Colors.green : Colors.orange,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class TaskCompletionCheckbox extends StatefulWidget {
  final bool isCompleted;
  final VoidCallback onToggleComplete;

  const TaskCompletionCheckbox({
    super.key,
    required this.isCompleted,
    required this.onToggleComplete,
  });

  @override
  State<TaskCompletionCheckbox> createState() => _TaskCompletionCheckboxState();
}

class _TaskCompletionCheckboxState extends State<TaskCompletionCheckbox> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.isCompleted;
  }

  @override
  void didUpdateWidget(TaskCompletionCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCompleted != widget.isCompleted) {
      _isChecked = widget.isCompleted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: _isChecked,
      onChanged: (_) {
        setState(() {
          _isChecked = !_isChecked;
        });
        widget.onToggleComplete();
      },
    );
  }
}
