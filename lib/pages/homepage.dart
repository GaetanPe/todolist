import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/utils.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<Utils>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appState.title),
      ),
      body: ListView.builder(
        itemCount: appState.toDoList.length,
        itemBuilder: (context, index) {
          final task = appState.toDoList[index];
          final backgroundColor = _getBackgroundColor(task.deadline); 

          return Container(
            color: backgroundColor,
            child: ListTile(
              title: Text(
                task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),  
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.description, 
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (task.deadline != null)
                    Text(
                      'Deadline: ${DateFormat('dd/MM/yyyy').format(task.deadline!)}',
                      style: const TextStyle(fontSize:12, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/editTask',
                        arguments: task,
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      appState.removeTask(task);
                    },
                  ),
                ],
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      task.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(task.description),
                        if (task.deadline != null)
                          Text(
                            'Date: ${DateFormat('dd/MM/yyyy').format(task.deadline!)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Fermer'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/editTask');
        },
        tooltip: 'Ajouter une tâche',
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getBackgroundColor(DateTime? deadline) {
    if (deadline == null) {
      return Colors.white;
    }

    final currentDate = DateTime.now();
    final daysRemaining = deadline.difference(currentDate).inDays;

    if (daysRemaining > 3) {
      return Colors.green[100]!; 
    } else if (daysRemaining > 0 && daysRemaining <= 3) {
      return Colors.orange[100]!;
    } else if (daysRemaining <= 0) {
      return Colors.red[100]!;
    } else {
      return Colors.white;
    }
  }
}
