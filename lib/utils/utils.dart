// utils.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Task {
  String title;
  String description;
  DateTime? deadline;  
  Task({required this.title, required this.description, this.deadline});

  // Convertir une tâche en Map pour l'enregistrer dans la base de données
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'deadline': deadline?.toIso8601String(),
    };
  }

  // Convertir une Map en tâche
  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'],
      description: map['description'],
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
    );
  }
}

class Utils extends ChangeNotifier {
  String _title = 'Accueil';
  late Database _database;
  String get title => _title;

  void updateTitle(String newTitle) {
    _title = newTitle;
    notifyListeners();
  }

  List<Task> toDoList = [];

  Utils() {
    _initDatabase();
  }

  // Initialiser la base de données
  Future<void> _initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'tasks.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY, title TEXT, description TEXT, deadline TEXT)',
        );
      },
      version: 1,
    );
    await _loadTasks();
  }

  // Charger les tâches depuis la base de données
  Future<void> _loadTasks() async {
    final List<Map<String, dynamic>> maps = await _database.query('tasks');
    toDoList = List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
    notifyListeners();
  }

  // Ajouter une tâche dans la liste et la base de données
  Future<void> addTask(String title, String description, DateTime? deadline) async {
    final task = Task(title: title, description: description, deadline: deadline);
    await _database.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    toDoList.add(task);
    notifyListeners();
  }

  // Mettre à jour une tâche dans la liste et la base de données
  Future<void> updateTask(Task task, String title, String description, DateTime? deadline) async {
    final updatedTask = Task(title: title, description: description, deadline: deadline);
    await _database.update(
      'tasks',
      updatedTask.toMap(),
      where: 'title = ?',
      whereArgs: [task.title],
    );
  
    final index = toDoList.indexOf(task);
    if (index != -1) {
      toDoList[index] = updatedTask;
      notifyListeners();
    }
  }

  // Supprimer une tâche de la liste et de la base de données
  Future<void> removeTask(Task task) async {
    await _database.delete(
      'tasks',
      where: 'title = ?',
      whereArgs: [task.title],
    );
    toDoList.remove(task);
    notifyListeners();
  }
}
